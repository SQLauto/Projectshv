

SET NOCOUNT ON

DECLARE @Subject nvarchar(200) 
DECLARE @Body    nvarchar(4000)
DECLARE @JobType nvarchar(200) 

IF EXISTS(select * from tempdb..sysobjects where name like '%#fullbkps%')
DROP TABLE #fullbkps

CREATE TABLE [dbo].[#fullbkps]
(Instance_Name varchar(256),
DBName sysname,
ConfiguredValue varchar(256),
ExpectedValue varchar(256),
CheckWarning varchar(256))

 -- check for full Backups
INSERT INTO #fullbkps (Instance_Name, DBName, ConfiguredValue, ExpectedValue, CheckWarning)  

select  @@servername as Instance_Name-- \n\
,db.[name] as Dbname,  -- \n\
--'Last Backup Date: ' + cast(isnull(convert(varchar(30), Last_bk.Last_bk_Date, 121),'No Backup') as varchar(50)) as ConfiguredValue,  -- \n\
'days since Last Backup: ' + CAST(isnull(cast(Datediff(MINUTE,Last_bk.Last_bk_Date,getDate()) / 60.0 / 24.0 as decimal(16,2)),'-1') as varchar(50)) daysSinceLastBk,-- \n\
'Max time Expected since Last full Backup: ' + CAST(CAST(isnull(dbExc.IntParam1, isnull(srvExc.IntParam1,6.2*1440))/60.0/24.0 as decimal(16,2)) as varchar(30)) + ' days' as ExpectedValue -- \n\
, 'FullBackup ' as CheckWarning  -- \n\
from master.sys.databases as db with (Nolock)  -- \n\
left join  -- \n\
(       -- \n\
       select       database_name,      Max(Backup_finish_Date) as Last_bk_Date  -- \n\
       from msdb..Backupset b with (Nolock)   -- \n\
       where  [type]= 'D' -- \n\
       group by database_name -- \n\
) as Last_bk  -- \n\
on db.[name] = Last_bk.database_name  -- \n\
left join  -- \n\
DBA.dbo.dbaApprovedExceptions dbExc -- \n\
on db.[name] = dbExc.[ObjectName]  collate database_default  -- \n\
and dbExc.ExceptionType = 'dbFullBackup'  -- \n\
left join DBA..dbaApprovedExceptions srvExc  -- \n\
on srvExc.ExceptionType = 'srvDbFullBackup'  -- \n\
and  lower(srvExc.ObjectName) = lower(cast (serverproperty('servername') as varchar(128))) collate database_default  -- \n\
where -- \n\
isnull(Datediff(MINUTE,Last_bk.Last_bk_Date,getDate()),99999) > isnull(dbExc.IntParam1, isnull(srvExc.IntParam1,6.2*1440)) -- \n\
and db.name Not in ('model','tempdb')  -- \n\
and db.[state] = 0 -- online  -- \n\
and isnull(dbExc.IntParam1, isnull(srvExc.IntParam1,-9)) != -1  -- \n\
order by db.[name] -- \n\

select * from #fullbkps