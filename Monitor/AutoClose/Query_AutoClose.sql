SET NOCOUNT ON

DECLARE @Subject nvarchar(200) 
DECLARE @Body    nvarchar(4000)
DECLARE @JobType nvarchar(200) 

--IF EXISTS(select * from tempdb..sysobjects where name like '%#AutoClose%')
--DROP TABLE #AutoClose

CREATE TABLE [dbo].[#AutoClose]
(Instance_Name varchar(256),
DBName sysname,
ConfiguredValue varchar(256),
ExpectedValue varchar(256),
CheckWarning varchar(256))


-- Auto Close

INSERT INTO #AutoClose (Instance_Name,DBName, ConfiguredValue, ExpectedValue, CheckWarning)

select 
 @@Servername as Instance_Name,
 name  -- \n\
, 'Configured: ' + cast(is_auto_close_on as varchar(20)) as ConfiguredValue  -- \n\
, 'Expected: ' + cast(isnull(dbExc.IntParam1, isnull(srvExc.IntParam1,0)) as varchar(20)) as ExpectedValue  -- \n\
, 'AutoCloseON '  as CheckWarning  -- \n\
 from sys.databases d  -- \n\
left join DBA..dbaApprovedExceptions dbExc  -- \n\
on d.name = dbExc.ObjectName  collate database_default   -- \n\
and dbExc.ExceptionType = 'dbAutoClose'  -- \n\
left join DBA..dbaApprovedExceptions srvExc  -- \n\
on srvExc.ExceptionType = 'srvDbAutoClose'  -- \n\
and  lower(srvExc.ObjectName) = lower(cast (serverproperty('servername') as varchar(128))) collate database_default  -- \n\
 where  is_auto_close_on != isnull(dbExc.IntParam1, isnull(srvExc.IntParam1,0))  -- \n\
 and isnull(dbExc.IntParam1, isnull(srvExc.IntParam1,-9)) != -1  -- \n\

select * from #AutoClose