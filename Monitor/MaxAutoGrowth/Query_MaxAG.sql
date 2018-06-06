

SET NOCOUNT ON

--MaxDataFileAutoGrowthMin


IF EXISTS(select * from tempdb..sysobjects where name like '%#MaxAG%')
DROP TABLE #MaxAG 

CREATE TABLE [dbo].[#MaxAG ]
(Instance_Name varchar(256),
DBName sysname,
DataFile varchar(256),
PhysicalName varchar(256),
ConfiguredValue varchar(256),
ExpectedValue varchar(256),
CheckWarning varchar(256))

INSERT INTO #MaxAG( Instance_Name,DBName, DataFile , PhysicalName, ConfiguredValue, ExpectedValue, CheckWarning )

Select  @@Servername as Instance_Name -- \n\
,db_name(database_id) dbName,  -- \n\
'file name: ' + name as DataFile,  -- \n\
'physical name: ' + [physical_name] AS PhysicalName, -- \n\
'MB to grow: ' + CAST(CAST(  -- \n\
case is_percent_growth  -- \n\
when 1 then  -- \n\
(cast(size as decimal(16,2))*growth/100.0)/128.0   -- \n\
else growth/128.0  -- \n\
end as decimal(16,2))as varchar(50))  -- \n\
as ConfiguredValue  -- \n\
, 'Max Expected Growth MB: ' + cast(cast(isnull(dbExc.IntParam1, isnull(srvExc.IntParam1,1024)) as decimal(12,2)) as varchar(50)) as ExpectedValue  -- \n\
, 'MaxDataFileAutoGrowth ' as CheckWarning  -- \n\
from sys.master_files d  -- \n\
left join DBA..dbaApprovedExceptions dbExc  -- \n\
on db_name(d.database_id) = dbExc.ObjectName  -- \n\
and dbExc.ExceptionType = 'dbFileGrowth'  -- \n\
left join DBA..dbaApprovedExceptions srvExc  -- \n\
on srvExc.ExceptionType = 'srvDbFileGrowth'  -- \n\
and  lower(srvExc.ObjectName) = lower(cast (serverproperty('servername') as varchar(128))) collate database_default  -- \n\
where d.type <> '2'  
and  case is_percent_growth when 1 then (size*growth/100.0)/128.0 else growth/128.0 end > isnull(dbExc.IntParam1, isnull(srvExc.IntParam1,1024)) -- \n\
and isnull(dbExc.IntParam1, isnull(srvExc.IntParam1,-9)) != -1  -- \n\

select * from #MaxAG
