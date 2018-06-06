

SET NOCOUNT ON

DECLARE @Subject nvarchar(200) 
DECLARE @Body    nvarchar(4000)
DECLARE @JobType nvarchar(200) 

IF EXISTS(select * from tempdb..sysobjects where name like '%#tempdb%')
DROP TABLE #tempdb

CREATE TABLE [dbo].[#tempdb]
(Instance_Name varchar(256),
DBName sysname,
ConfiguredValue varchar(256),
ExpectedValue varchar(256),
CheckWarning varchar(256))

-- Check for too few tempdb data files

IF (select cpu_count from sys.dm_os_sys_info) > 8

INSERT INTO #tempdb (Instance_Name, DBName, ConfiguredValue, ExpectedValue, CheckWarning)  
select  @@servername as Instance_Name
, 'Tempdb' as Dbname
,'Current Number of Files: ' + CAST(COUNT(*) AS varchar(20)) ConfiguredValue ,  
'Expected Number of Files: ' + CAST(isnull(srvExc.IntParam1,8) AS varchar(20)) ExpectedValue -- Counting CPU
, 'TempdbFiles ' as Sql_Alert  
from sys.master_files m  
cross join sys.dm_os_sys_info s  
left join DBA..dbaApprovedExceptions srvExc  
on srvExc.ExceptionType = 'tempdbDataFileCount'  
and  lower(srvExc.ObjectName) = lower(cast (serverproperty('servername') as varchar(128))) collate database_default 
where m.database_id = DB_ID('tempdb') 
and m.[type] = 0 -- 'ROWS' 
group by cpu_count, srvExc.IntParam1  
having COUNT(*) < isnull(srvExc.IntParam1,8)  
and isnull(srvExc.IntParam1,-9) != -1  

Else 


INSERT INTO #tempdb (Instance_Name, DBName, ConfiguredValue, ExpectedValue, CheckWarning)  
select  @@servername as Instance_Name
, 'Tempdb' as Dbname
,'Current Number of Files: ' + CAST(COUNT(*) AS varchar(20)) ConfiguredValue ,  
'Expected Number of Files: ' + CAST(isnull(srvExc.IntParam1,cpu_count) AS varchar(20)) ExpectedValue -- Counting CPU
, 'TempdbFiles ' as Sql_Alert  
from sys.master_files m  
cross join sys.dm_os_sys_info s  
left join DBA..dbaApprovedExceptions srvExc  
on srvExc.ExceptionType = 'tempdbDataFileCount'  
and  lower(srvExc.ObjectName) = lower(cast (serverproperty('servername') as varchar(128))) collate database_default 
where m.database_id = DB_ID('tempdb') 
and m.[type] = 0 -- 'ROWS' 
group by cpu_count, srvExc.IntParam1  
having COUNT(*) < isnull(srvExc.IntParam1,cpu_count)  
and isnull(srvExc.IntParam1,-9) != -1  

BEGIN

DECLARE @tableHTML  NVARCHAR(Max) ;
SET @tableHTML =
     N'<head>
<style type="text/css">
   body { font-family: Verdana, Arial, Helvetica, sans-serif;color: #333;
          font-size: 12px;font-style: Normal;font-weight: Normal;
          line-height: Normal;text-align: left;background-color: #fff;}
   p { line-height: 135%;}
   h3 {font-family: Verdana, Arial, Helvetica, sans-serif;color: #00008B;font-size: 12px;
       font-style: Normal;font-weight: bold;line-height: Normal;text-align: justify;}
   table.center { width:80%; margin-left:15%; margin-right:15%;}
   td {font-family: Verdana, Arial, Helvetica, sans-serif;color: black;font-size: 11px;}
   th {font-family: Verdana, Arial, Helvetica, sans-serif;color: white;
       background-color: #0070C0;font-size: 11px; font-weight: bold;text-align:
       left;border: None;border-right: None;border-left: None;border-top: None;
       vertical-align: top;padding-bottom: 3px;padding-top: 3px;padding-left: 2px;
       padding-right: 2px;}
   .textSmall { font-family: Verdana, Arial, Helvetica, sans-serif; color: #333333;
                font-size: 10px; font-style: Normal; line-height: Normal; font-weight: Normal;
                text-align: justify;margin-left:15%; margin-right:15%;}
   .textNormal{font-family: Verdana, Arial, Helvetica, sans-serif; color: #333333;
               font-size: 12px;font-style: Normal;font-weight: Normal;line-height: 135%;
               text-align: justify;margin-left:15%; margin-right:15%;}
</style>
</head><body>
  <div class="textNormal"></div>
<h3>Alert: Missing backups and Data Base Configuration. <br><br></h3>
<div class="testNormal"> </div><br>
   <table class="center" border=3>
     <tr>
       <th>InstanceName</th> 
       <th>Dbname</th>      
    <th>ConfiguredValue</th>
       <th>ExpectedValue</th>
          <th>CheckWarning</th>
      </tr>'+CAST ( ( SELECT td = Instance_Name,       '',
      td = DBName,       '',
      td = ConfiguredValue, '',
      td = ExpectedValue, '',
         td = CheckWarning, ''
                     FROM #tempdb                              
               FOR XML PATH('tr'), TYPE 
     ) AS NVARCHAR(Max) ) +'</table><br/><br/><div> </br></br>' 


end

select * from #tempdb
