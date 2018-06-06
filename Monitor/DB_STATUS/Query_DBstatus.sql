

SET NOCOUNT ON

DECLARE @Subject nvarchar(200) 
DECLARE @Body    nvarchar(4000)
DECLARE @JobType nvarchar(200) 

IF EXISTS(select * from tempdb..sysobjects where name like '%#DBstatus%')
DROP TABLE #DBstatus

CREATE TABLE [dbo].[#DBstatus]
(Instance_Name varchar(256),
DBName sysname,
ConfiguredValue varchar(256),
ExpectedValue varchar(256),
CheckWarning varchar(256))

-- check for db's with Non compliant status

 INSERT INTO #DBstatus (Instance_Name, DBName, ConfiguredValue, ExpectedValue, CheckWarning)

select @@servername as Instance_Name
,d.name  -- \n\
, 'Configured: ' + CAST(d.state_desc  as varchar(50) ) msg1 -- \n\
,   -- \n\
'Expected: ' +  -- \n\
case isnull(dbExc.IntParam1, isnull(srvExc.IntParam1,0))  -- \n\
when 0 then 'ONLINE' -- \n\
when 1 then 'RESTORING'-- \n\
when 2 then 'RECOVERING'-- \n\
when 3 then 'RECOVERY_PENDING'-- \n\
when 4 then 'SUSPECT'-- \n\
when 5 then 'EMERGENCY'-- \n\
when 6 then 'OFFLINE'-- \n\
else 'UNKNoWN: ' + cast(isnull(dbExc.IntParam1, isnull(srvExc.IntParam1,0)) as varchar(20))  -- \n\
end as msg2 -- \n\
, 'DatabaseStatus '  as CheckWarning  -- \n\
from sys.databases d  -- \n\
left join DBA..dbaApprovedExceptions dbExc  -- \n\
on d.name = dbExc.ObjectName  collate database_default  -- \n\
and dbExc.ExceptionType = 'dbDatabaseStatus'  -- \n\
left join DBA..dbaApprovedExceptions srvExc  -- \n\
on srvExc.ExceptionType = 'srvDbDatabaseStatus'  -- \n\
and  lower(srvExc.ObjectName) = lower(cast (serverproperty('servername') as varchar(128))) collate database_default  -- \n\
where d.state != isnull(dbExc.IntParam1, isnull(srvExc.IntParam1,0)) /*  0 = ONLINE ,1 = RESTORING,2 = RECOVERING,3 = RECOVERY_PENDING,4 = SUSPECT,5 = EMERGENCY,6 = OFFLINE  */   -- \n\
and isnull(dbExc.IntParam1, isnull(srvExc.IntParam1,-9)) != -1  -- \n\

select * from #DBstatus