USE DBA
GO
SET NOCOUNT ON
go
Create table #LongJobs
(
Instance_Name varchar(256),
job_name varchar(256),
StartExecution varchar(256),
ExecutionTime varchar(256),
MaxTime varchar(256))

BULK INSERT #LongJobs FROM 'F:\Monitor\LongRunningJobs\LongRunning_SSCVPIDERA01\Longrunning_Report.txt' WITH ( FIELDTERMINATOR = '|', ROWTERMINATOR = '\n')

-- This is to validate if some job is running for long time.

IF (SELECT COUNT (*) 
    FROM #LongJobs a
    INNER JOIN dba_Sms_Job_Notification b
    ON a.job_name = b.jobname) > 0


	-- Create table to save Jobs, NumberId and Contact Number

IF OBJECT_ID('dba_Sms_Job_Notification') IS NULL 
		BEGIN
			CREATE TABLE [dba_Sms_Job_Notification](
	        [Jobname] [sysname] NOT NULL,
	        [NumberIDs] [varchar](512) NULL,
	        [Contact_Number_Name] [varchar](1024) NULL,
	        [EnableAlert] [bit] NULL) 
	        ON [PRIMARY]
     END 


BEGIN

  -- Declare variables
 DECLARE @VAR_ADDRESS nVARCHAR(MAX);
 DECLARE @BODYTEXT  nVARCHAR(MAX);

   -- No counting of rows
    SET NOCOUNT ON;

	 -- Get email list
    DECLARE VAR_CURSOR CURSOR FOR   


-- Read Job and Number ID Filtering by Column EnableAlert
	   
    SELECT  b.NumberIDs, -- + '; salvador_sandoval@ryder.com',
	        +'Server:  || ' + @@SERVERNAME + ' ||  '  +'  Job name: '  + + '  || ' +  b.jobname + ' ||'
	FROM #LongJobs a
    INNER JOIN dba..dba_Sms_Job_Notification b
    ON a.job_name = b.jobname
	WHERE b.EnableAlert = '1'

    -- Open cursor
    OPEN VAR_CURSOR;

    -- Get first row
    FETCH NEXT FROM VAR_CURSOR INTO @VAR_ADDRESS,@BODYTEXT


		-- While there is data
    WHILE (@@fetch_status = 0)
    BEGIN
      
	   -- Send the email

EXEC msdb.dbo.sp_send_dbmail 
     @recipients = @VAR_ADDRESS,
     @subject ='LONG RUNNING JOBS ALERT',
     @body = @BODYTEXT,
     @body_format = 'HTML',
	 @profile_name ='Ryder DBA'; 

	    -- Grab the next record
        FETCH NEXT FROM VAR_CURSOR 
            INTO @VAR_ADDRESS, @BODYTEXT

              END

    -- Close cursor
    CLOSE VAR_CURSOR;

    -- Release memory
    DEALLOCATE VAR_CURSOR;   
	END