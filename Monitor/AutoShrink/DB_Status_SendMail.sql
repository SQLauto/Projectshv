SET NOCOUNT ON
--DROP TABLE ##DB_ONLINE_Status
go
CREATE TABLE [dbo].[#AutoShrinkON]
(Instance_Name varchar(256),
 DBName sysname,
 ConfiguredValue varchar(256),
 ExpectedValue varchar(256),
 CheckWarning varchar(256))

BULK INSERT #AutoShrinkON FROM 'F:\Monitor\AutoShrink\AutoShrink_Report.txt' WITH ( FIELDTERMINATOR = '|', ROWTERMINATOR = '\n')



--alter table ##DB_ONLINE_Status add Ignore varchar(10) default('') with values


if (select count(*) from #AutoShrinkON) <>0

BEGIN

DECLARE @tableHTML  NVARCHAR(MAX) ;
SET @tableHTML =
    N'<head>
<style type="text/css">
  body { font-family: Verdana, Arial, Helvetica, sans-serif;color: #333;
         font-size: 12px;font-style: normal;font-weight: normal;
         line-height: normal;text-align: left;background-color: #fff;}
  p { line-height: 135%;}
  h3 {font-family: Verdana, Arial, Helvetica, sans-serif;color: #00008B;font-size: 12px;
      font-style: normal;font-weight: bold;line-height: normal;text-align: justify;}
  table.center { width:80%; margin-left:15%; margin-right:15%;}
  td {font-family: Verdana, Arial, Helvetica, sans-serif;color: black;font-size: 11px;}
  th {font-family: Verdana, Arial, Helvetica, sans-serif;color: white;
      background-color: #0070C0;font-size: 11px; font-weight: bold;text-align:
      left;border: none;border-right: none;border-left: none;border-top: none;
      vertical-align: top;padding-bottom: 3px;padding-top: 3px;padding-left: 2px;
      padding-right: 2px;}
  .textSmall { font-family: Verdana, Arial, Helvetica, sans-serif; color: #333333;
               font-size: 10px; font-style: normal; line-height: normal; font-weight: normal;
               text-align: justify;margin-left:15%; margin-right:15%;}
  .textNormal{font-family: Verdana, Arial, Helvetica, sans-serif; color: #333333;
              font-size: 12px;font-style: normal;font-weight: normal;line-height: 135%;
              text-align: justify;margin-left:15%; margin-right:15%;}
</style>
</head><body>
  <div class="textNormal"></div>
<h3>Hello SQLites,<br><br></h3>
<div class="testNormal"> Please check out the Database status below</div><br>
  <table class="center" border=1>
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
                     FROM #AutoShrinkON                   
                    
              FOR XML PATH('tr'), TYPE 
    ) AS NVARCHAR(MAX) ) +'</table><br/><br/><div>Please validate the database</br></br>Thank You.</div></br><h3>regards,<br>SQL Server Administrator.</h3>' 


Declare @mail_address NVARCHAR(MAX);


SELECT @mail_address =REPLACE(REPLACE(REPLACE(bulkcolumn, CHAR(10), ''), CHAR(13), ''), CHAR(9), '') 
FROM OPENROWSET(   BULK  N'F:\Monitor\Email.txt', SINGLE_CLOB)  AS TextFile

--SELECT @mail_address = 'hugo_vaquera@ryder.com;salvador_sandoval@ryder.com'
EXEC msdb.dbo.sp_send_dbmail @recipients=@mail_address ,
    @subject = 'PROD - Database Status Alert (AUTO SHRINK)',
    @body = @tableHTML,
    @body_format = 'HTML',@profile_name ='Ryder DBA'; 
END
ELSE
BEGIN
DROP TABLE #AutoShrinkON                   
END