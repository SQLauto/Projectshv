

SET NOCOUNT ON

DECLARE @Subject nvarchar(200) 
DECLARE @Body    nvarchar(4000)
DECLARE @JobType nvarchar(200) 

IF EXISTS(select * from tempdb..sysobjects where name like '%#RecoveryModel%')
DROP TABLE #RecoveryModel

CREATE TABLE [dbo].[#RecoveryModel]
(Instance_Name varchar(256),
DBName sysname,
ConfiguredValue varchar(256),
ExpectedValue varchar(256),
CheckWarning varchar(256))

 --db's with PageVerifyOption Different

 INSERT INTO #RecoveryModel (Instance_Name, DBName, ConfiguredValue, ExpectedValue, CheckWarning)

select @@servername as Instance_Name
,d.name  -- \n\
, 'Configured: ' + CAST(d.recovery_model_desc as varchar(50) ),  --  \n\
'Expected: ' +  -- \n\
case isnull(dbExc.IntParam1, isnull(srvExc.IntParam1,1))  -- \n\
when 1 then 'FULL' -- \n\
when 2 then 'BULK_LOGGED' -- \n\
when 3 then 'SIMPLE' -- \n\
else 'unkNown - ' + CAST(isnull(dbExc.IntParam1, isnull(srvExc.IntParam1,1)) as varchar(50)) -- \n\
end -- \n\
, 'RecoveyModel '  as CheckWarning  -- \n\
 from sys.databases d  -- \n\
left join DBA..dbaApprovedExceptions dbExc  -- \n\
on d.name = dbExc.ObjectName  collate database_default  -- \n\
and dbExc.ExceptionType = 'dbRecoveyModel'  -- \n\
left join DBA..dbaApprovedExceptions srvExc  -- \n\
on srvExc.ExceptionType = 'srvDbRecoveyModel'  -- \n\
and  lower(srvExc.ObjectName) = lower(cast (serverproperty('servername') as varchar(128))) collate database_default  -- \n\
where recovery_model != isnull(dbExc.IntParam1, isnull(srvExc.IntParam1,1)) /* 1 = FULL, 2 = BULK_LOGGED, 3 = SIMPLE */   -- \n\
and d.name Not in ('master','tempdb','ReportServerTempDB') --  \n\
 and isnull(dbExc.IntParam1, isnull(srvExc.IntParam1,-9)) != -1  -- \n\

select * from #RecoveryModel