

SET NOCOUNT ON

DECLARE @Subject nvarchar(200) 
DECLARE @Body    nvarchar(4000)
DECLARE @JobType nvarchar(200) 

IF EXISTS(select * from tempdb..sysobjects where name like '%#AutoCreateStats%')
DROP TABLE #AutoCreateStats

CREATE TABLE [dbo].[#AutoCreateStats]
(Instance_Name varchar(256),
DBName sysname,
ConfiguredValue varchar(256),
ExpectedValue varchar(256),
CheckWarning varchar(256))

--db's with auto Create Stats Off

INSERT INTO #AutoCreateStats (Instance_Name,DBName, ConfiguredValue, ExpectedValue, CheckWarning)

select @@Servername as Instance_Name,
  name  -- \n\
, 'Configured: ' + cast(is_auto_create_stats_on as varchar(20)) as ConfiguredValue  -- \n\
, 'Expected: ' + cast(isnull(dbExc.IntParam1, isnull(srvExc.IntParam1,1)) as varchar(20)) as ExpectedValue  -- \n\
, 'AutoCreateStatsOff '  as CheckWarning  -- \n\
from sys.databases d  -- \n\
left join DBA..dbaApprovedExceptions dbExc  -- \n\
on d.name = dbExc.ObjectName  collate database_default  -- \n\
and dbExc.ExceptionType = 'dbAutoCreateStats'  -- \n\
left join DBA..dbaApprovedExceptions srvExc  -- \n\
on srvExc.ExceptionType = 'srvDbAutoCreateStats'  -- \n\
and  lower(srvExc.ObjectName) = lower(cast (serverproperty('servername') as varchar(128))) collate database_default  -- \n\
where is_auto_create_stats_on != isnull(dbExc.IntParam1, isnull(srvExc.IntParam1,1))  -- \n\
and isnull(dbExc.IntParam1, isnull(srvExc.IntParam1,-9)) != -1  -- \n\

select * from #AutoCreateStats