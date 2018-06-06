

SET NOCOUNT ON

DECLARE @Subject nvarchar(200) 
DECLARE @Body    nvarchar(4000)
DECLARE @JobType nvarchar(200) 


--DataFilePercentGrowthEnabled

IF EXISTS(select * from tempdb..sysobjects where name like '%#PercentGrowth%')
DROP TABLE #PercentGrowth 

CREATE TABLE [dbo].[#PercentGrowth ]
(Instance_Name varchar(256),
DBName sysname,
DataFile varchar(256),
PhysicalName varchar(256),
ConfiguredValue varchar(256),
ExpectedValue varchar(256),
CheckWarning varchar(256))


INSERT INTO #PercentGrowth( Instance_Name,DBName, DataFile , PhysicalName, ConfiguredValue, ExpectedValue, CheckWarning )


select @@Servername as Instance_Name,
db_name(database_id) as DBName,   
 'file name: ' + name as DataFile,  -- \n\
'physical name: ' + [physical_name] AS PhysicalName,
'Percentage Growth:  ' + cast(growth as varchar(20)) + ' %' as ConfiguredValue   
, 'Expected Percentage Growth: ' + cast(isnull(dbExc.IntParam1, isnull(srvExc.IntParam1,-1)) as varchar(20)) as ExpectedValue   
, 'DataFilePercentGrowthEnabled '  as CheckWarning   
 from sys.master_files d   
 left join DBA..dbaApprovedExceptions dbExc   
on d.name = dbExc.ObjectName  collate database_default    
and dbExc.ExceptionType = 'dbPercentGrowth'   
left join DBA..dbaApprovedExceptions srvExc   
on srvExc.ExceptionType = 'srvPercentGrowth'   
and  lower(srvExc.ObjectName) = lower(cast (serverproperty('servername') as varchar(128))) collate database_default   
 where  is_percent_growth != isnull(dbExc.IntParam1, isnull(srvExc.IntParam1,0))   
 and isnull(dbExc.IntParam1, isnull(srvExc.IntParam1,-9)) != -1   


BEGIN

DECLARE @tableHTML2  NVARCHAR(Max) ;
SET @tableHTML2 =
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
<h3> Alert: Wrong Data Files Configuration  <br><br></h3>
<div class="testNormal"> </div><br>
   <table class="center" border=1>
     <tr>
       <th>InstanceName</th> 
       <th>Dbname</th>      
    <th>DataFile</th>
       <th>PhysicalName</th>
          <th>ConfiguredValue</th>
          <th>ExpectedValue</th>
          <th>CheckWarning</th>
          </tr>'+CAST ( ( SELECT td = Instance_Name,       '',
      td = DBName,       '',
      td = DataFile, '',
      td = PhysicalName, '',
         td = ConfiguredValue, '',
         td = ExpectedValue, '',
         td = CheckWarning, ''
                    FROM #PercentGrowth                              
               FOR XML PATH('tr'), TYPE 
     ) AS NVARCHAR(Max) ) +'</table><br/><br/><div> </br></br>' 

END

select * from #PercentGrowth
