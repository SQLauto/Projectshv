

SET NOCOUNT ON

DECLARE @Subject nvarchar(200) 
DECLARE @Body    nvarchar(4000)
DECLARE @JobType nvarchar(200) 


-- long running query

IF EXISTS(select * from tempdb..sysobjects where name like '%#LongRunningQuery%')
DROP TABLE #LongRunningQuery 

CREATE TABLE [dbo].[#LongRunningQuery]
(Instance_Name varchar(256),
DBName sysname,
Session_Id varchar(256),
Query_Begin_Time varchar(256),
MinutesPast varchar(256),
Login_Name varchar(256),
Host_Name varchar(256),
Program_Name varchar(256),
MaxTimeMinutes varchar(256),
CheckWarning varchar(256))

INSERT INTO #LongRunningQuery (Instance_Name,DBName,Session_Id,Query_Begin_Time,MinutesPast,Login_Name,Host_Name,Program_Name,MaxTimeMinutes,CheckWarning)

SELECT @@servername as Instance_Name, -- \n\
       db_name(re.database_id) dbName
,'Session ' + CAST(se.[session_id] AS VARCHAR(128)) AS [Session_id]  -- \n\
, 'Query Begin Time: ' + CONVERT(VARCHAR(30),re.start_time,121) Query_Begin_Time -- \n\
, 'Minutes Past: ' + CAST(DATEDIFF(MINUTE, re.start_time, GETDATE()) AS VARCHAR(20)) MinutesPast -- \n\
, 'Login: ' + CAST(se.[login_name] AS VARCHAR(128)) AS  [Login_Name]  -- \n\
, 'Host: ' + CAST( se.[host_name] AS VARCHAR(128))  AS  [Host_Name]  -- \n\
, 'Program: ' + CAST(  se.[program_name] AS VARCHAR(128))  AS  [Program_Name]  -- \n\
, 'Max Agreed Time For Query Execution is: ' + CAST(ISNULL(ex2.IntParam1, ISNULL(ex.IntParam1,30)) AS  VARCHAR(128)) MaxTimeMinutes -- \n\
, 'LongRunningQuery ' as CheckWarning 
 FROM sys.dm_exec_requests re -- \n\
INNER JOIN sys.dm_exec_sessions se  -- \n\
ON re.session_id = se.session_id -- \n\
LEFT JOIN DBA..dbaApprovedExceptions ex  -- \n\
ON lower(ex.ObjectName) = LOWER(CAST (SERVERPROPERTY('servername') AS VARCHAR(128))) COLLATE database_default  -- \n\
AND ExceptionType = 'srvLongRunningQuery'  -- \n\
LEFT JOIN DBA..dbaApprovedExceptions ex2  -- \n\
ON lower(ex2.ObjectName) = CAST( se.[host_name] AS VARCHAR(128)) + ';' + CAST(se.[login_name] AS VARCHAR(128)) + ';' +CAST(se.[program_name] AS VARCHAR(128)) COLLATE database_default  -- \n\
AND ex2.ExceptionType = 'sessionLongRunningQuery'  -- \n\
where re.session_id > 50 -- \n\
AND re.Status <> 'BACKGROUND'
AND DATEDIFF(MINUTE, start_time, GETDATE()) >= ISNULL(ex2.IntParam1, ISNULL(ex.IntParam1,30))   -- max age for active transaction in minutes 30 min-- \n\
AND ISNULL(ex2.IntParam1, -9) != -1   -- \n\
ORDER BY DATEDIFF(MINUTE, re.start_time, GETDATE())  DESC -- \n\



select * from #LongRunningQuery
