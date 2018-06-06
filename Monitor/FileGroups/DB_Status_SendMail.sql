USE DBA 
SET NOCOUNT ON
--DROP TABLE ##DB_ONLINE_Status
go
CREATE TABLE [dbo].[#FileGroups]
(Instance_Name varchar(256),
 DBName sysname,
 FileGroupName varchar(256),
 FileName varchar(256),
 TotalGB varchar(256),
 UsedDB varchar(256),
 Auto_Growth varchar(256),
 MaxSizeGB varchar(256),
 PercentageUsed varchar(256),
 CheckWarning varchar(256))

BULK INSERT #FileGroups FROM 'F:\Monitor\FileGroups\Query_FileGroups_Reports.txt' WITH ( FIELDTERMINATOR = '|', ROWTERMINATOR = '\n')



--alter table ##DB_ONLINE_Status add Ignore varchar(10) default('') with values


if (select count(*) from #FileGroups) <>0


BEGIN

DECLARE @tableHTML3  NVARCHAR(Max) ;
SET @tableHTML3 =
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
<h3> Alert:  File Groups Getting Full <br><br></h3>
<div class="testNormal"> </div><br>
   <table class="center" border=1>
     <tr>
       <th>InstanceName</th> 
       <th>Dbname</th>      
    <th>FileGroupName</th>
       <th>FileName</th>
          <th>TotalGB</th>
          <th>UsedDB</th>
          <th>Auto_Growth</th>
          <th>MaxSizeGB</th>
          <th>PercentageUsed</th>
          <th>CheckWarning</th>
          </tr>'+CAST ( ( SELECT td = Instance_Name,       '',
      td = DBName,       '',
      td = FileGroupName, '',
      td = FileName, '',
         td = TotalGB, '',
         td = UsedDB, '',
      td = Auto_Growth, '',
         td = MaxSizeGB, '',
         td = PercentageUsed, '',
         td = CheckWarning, ''
                     FROM #FullFileGroup                              
               FOR XML PATH('tr'), TYPE 
     ) AS NVARCHAR(Max) ) +'</table><br/><br/><div> </br></br>' 



Declare @mail_address NVARCHAR(MAX);


SELECT @mail_address =REPLACE(REPLACE(REPLACE(bulkcolumn, CHAR(10), ''), CHAR(13), ''), CHAR(9), '') 
FROM OPENROWSET(   BULK  N'F:\Monitor\Email.txt', SINGLE_CLOB)  AS TextFile

--SELECT @mail_address = 'hugo_vaquera@ryder.com;salvador_sandoval@ryder.com'
EXEC msdb.dbo.sp_send_dbmail @recipients=@mail_address ,
    @subject = 'PROD - Database Status Alert (File Groups Getting Full)',
    @body = @tableHTML,
    @body_format = 'HTML',@profile_name ='Ryder DBA'; 


END
ELSE
BEGIN
DROP TABLE #FileGroups                   
END