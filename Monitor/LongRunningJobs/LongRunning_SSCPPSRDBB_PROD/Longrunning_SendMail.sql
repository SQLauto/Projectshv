

SET NOCOUNT ON

go
Create table #LongJobs
(
Instance_Name varchar(256),
job_name varchar(256),
StartExecution varchar(256),
ExecutionTime varchar(256),
MaxTime varchar(256))

BULK INSERT #LongJobs FROM 'F:\Monitor\LongRunningJobs\LongRunning_SSCPPSRDBB_PROD\Longrunning_Report.txt' WITH ( FIELDTERMINATOR = '|', ROWTERMINATOR = '\n')


Create table #OperatorFromFile
(
Name varchar(256),
job_name varchar(256),
email_address nvarchar(max),
Operator_Name varchar(256),
)


BULK INSERT #OperatorFromFile FROM 'F:\Monitor\LongRunningJobs\LongRunning_SSCPPSRDBB_PROD\Longrunning_Operators.txt' WITH ( FIELDTERMINATOR = '|', ROWTERMINATOR = '\n')


if (select count(*) from #LongJobs) > 0

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
 <h3>Hello Team,<br><br></h3>
 <div class="testNormal"> Please check out the Application job status below</div><br>
   <table class="center" border=1>
     <tr>
       <th>Instance Name</th> 
	   <th>Job Name</th> 
       <th>Start Execution Date</th>      
       <th>Execution Time</th>
       <th>Max Threshold Min</th>
       </tr>'+CAST ( ( SELECT 
					   td = Instance_Name,       '',
					   td = job_name,       '',
					   td = StartExecution,       '',
					   td = cast(ExecutionTime as varchar), '',
					   td = cast(MaxTime as varchar)
       FROM #LongJobs                   
                     
               FOR XML PATH('tr'), TYPE 
     ) AS NVARCHAR(MAX) ) +'</table><br/><br/><div>Please validate the job and take actions.</br></br>Thank You.</div></br><h3>regards,<br>SQL Server Administrator.</h3>' 


Create table #Operator
(
name varchar(512),
job_id varchar(512),
Email_address varchar(512),
Operator varchar(512)
)

Insert into #Operator
select * from #OperatorFromFile


  -- Declare variables
 DECLARE @VAR_ADDRESS nVARCHAR(MAX);


   -- No counting of rows
    SET NOCOUNT ON;


	 -- Get email list
    DECLARE VAR_CURSOR CURSOR FOR   
	   
    SELECT distinct a.email_address + '; oscar_espinoza@ryder.com; Christian_Tafur@ryder.com; salvador_sandoval@ryder.com;David_Hetherington@ryder.com; Vijendra_Shrivastava@ryder.com'
	FROM #Operator a
	INNER JOIN #LongJobs b
	ON a.name = b.job_name

    -- Open cursor
    OPEN VAR_CURSOR;

    -- Get first row
    FETCH NEXT FROM VAR_CURSOR 
        INTO @VAR_ADDRESS;

		-- While there is data
    WHILE (@@fetch_status = 0)
    BEGIN
      
	   -- Send the email

EXEC msdb.dbo.sp_send_dbmail 
     @recipients = @VAR_ADDRESS,
     @subject = 'SSCPPSRDBB\PROD - Long Running Jobs',
     @body = @tableHTML,
     @body_format = 'HTML',
	 @profile_name ='Ryder DBA'; 

	    -- Grab the next record
        FETCH NEXT FROM VAR_CURSOR 
            INTO @VAR_ADDRESS;

              END

    -- Close cursor
    CLOSE VAR_CURSOR;

    -- Release memory
    DEALLOCATE VAR_CURSOR;   

   -- Assig Owner if job has null Operator 
     
IF (SELECT count (*) 
	FROM #Operator a
	INNER JOIN #LongJobs b
	ON a.name = b.job_name) = 0

BEGIN

SET @VAR_ADDRESS = 'Ryder_DBA@ryder.com'
EXEC msdb.dbo.sp_send_dbmail 
     @recipients = @VAR_ADDRESS,
     @subject = 'SSCPPSRDBB\PROD - Long Running Jobs',
     @body = @tableHTML,
     @body_format = 'HTML',
     @profile_name ='Ryder DBA'; 

END
END
