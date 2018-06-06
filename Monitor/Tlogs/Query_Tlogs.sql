

SET NOCOUNT ON

DECLARE @Subject nvarchar(200) 
DECLARE @Body    nvarchar(4000)
DECLARE @JobType nvarchar(200) 

IF EXISTS(select * from tempdb..sysobjects where name like '%#tlogs%')
DROP TABLE #tlogs

CREATE TABLE [dbo].[#tlogs]
(Instance_Name varchar(256),
DBName sysname,
ConfiguredValue varchar(256),
ExpectedValue varchar(256),
CheckWarning varchar(256))

-- Databases with No up-to-Date tlog Backup;
INSERT INTO #tlogs (Instance_Name, DBName, ConfiguredValue, ExpectedValue, CheckWarning)  

select  @@SERVERNAME as Instance_Name -- \n\
,db.[name] as Dbname-- \n\
--,'Last tlog Backup Date: ' + cast(isnull(convert(varchar(30), Last_bk.Last_bk_Date, 121),'No Backup') as varchar(50)) as ConfiguredValue  -- \n\
,'Min Since Last Backup: ' + CAST(isnull(cast(Datediff(MINUTE,Last_bk.Last_bk_Date,getDate())  as decimal(16,2)),'-1') as varchar(50)) minutesSinceLastBk -- \n\
,'Max time Expected since Last tlog Backup: ' + CAST(CAST(isnull(dbExc.IntParam1, isnull(srvExc.IntParam1,240)) as decimal(16,2)) as varchar(30)) + ' minutes' as ExpectedValue -- \n\
, 'LogBackup ' as CheckWarning  -- \n\
from master.sys.databases as db with (Nolock)  -- \n\
left join  -- \n\
(       -- \n\
       select       database_name,      Max(Backup_finish_Date) as Last_bk_Date  -- \n\
       from msdb..Backupset b with (Nolock)   -- \n\
       where  [type]= 'L' -- \n\
       group by database_name -- \n\
) as Last_bk  -- \n\
on db.[name] = Last_bk.database_name  collate database_default  -- \n\
left join  -- \n\
DBA.dbo.dbaApprovedExceptions dbExc -- \n\
on db.[name] = dbExc.[ObjectName]  collate database_default  -- \n\
and dbExc.ExceptionType = 'dbTLogBackup'  -- \n\
left join DBA..dbaApprovedExceptions srvExc  -- \n\
on srvExc.ExceptionType = 'srvDbTLogBackup'  -- \n\
and  lower(srvExc.ObjectName) = lower(cast (serverproperty('servername') as varchar(128))) collate database_default  -- \n\
where -- \n\
isnull(Datediff(MINUTE,Last_bk.Last_bk_Date,getDate()),99999) > isnull(dbExc.IntParam1, isnull(srvExc.IntParam1,240)) -- \n\
and db.name Not in ('model','tempdb')  -- \n\
and db.[state] = 0 -- online  -- \n\
and db.recovery_model_desc != 'SIMPLE'  -- \n\
and db.is_read_only = 0  -- \n\
and isnull(dbExc.IntParam1, isnull(srvExc.IntParam1,-9)) != -1  -- \n\
order by db.[name] -- \n\

select * from #tlogs