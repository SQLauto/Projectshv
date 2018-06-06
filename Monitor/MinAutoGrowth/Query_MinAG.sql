

SET NOCOUNT ON

DECLARE @Subject nvarchar(200) 
DECLARE @Body    nvarchar(4000)
DECLARE @JobType nvarchar(200) 


--MinDataFileAutoGrowthMin

IF EXISTS(select * from tempdb..sysobjects where name like '%#MinAG%')
DROP TABLE #MinAG 

CREATE TABLE [dbo].[#MinAG ]
(Instance_Name varchar(256),
DBName sysname,
DataFile varchar(256),
PhysicalName varchar(256),
ConfiguredValue varchar(256),
ExpectedValue varchar(256),
CheckWarning varchar(256))

INSERT INTO #MinAG( Instance_Name,DBName, DataFile , PhysicalName, ConfiguredValue, ExpectedValue, CheckWarning )


select  @@servername as Instance_Name,  
db_name(database_id) dbName,  -- \n\
'file name: ' + name as DataFile,  -- \n\
'physical name: ' + [physical_name] AS PhysicalName, -- \n\
'MB to grow: ' + CAST(CAST(  -- \n\
case is_percent_growth   
when 1 then   
(cast(size as decimal(16,2))*growth/100.0)/128.0    
else growth/128.0   
end as decimal(16,2))as varchar(50))   
as ConfiguredValue   
, 'Min Expected growth MB: ' + cast(cast(isnull(dbExc.IntParam1, isnull(srvExc.IntParam1,512)) as decimal(12,2)) as varchar(50)) as ExpectedValue  
, 'MinDataFileAutoGrowthMin ' as CheckWarning   
from sys.master_files d   
left join DBA..dbaApprovedExceptions dbExc   
on db_name(d.database_id) = dbExc.ObjectName   
and dbExc.ExceptionType = 'dbFileGrowthLow'   
left join DBA..dbaApprovedExceptions srvExc   
on srvExc.ExceptionType = 'srvDbFileGrowthLow'   
and  lower(srvExc.ObjectName) = lower(cast (serverproperty('servername') as varchar(128))) collate database_default   
where d.type <> '2'  
and case is_percent_growth when 1 then (size*growth/100.0)/128.0 else growth/128.0 end < isnull(dbExc.IntParam1, isnull(srvExc.IntParam1,512))  
 and isnull(dbExc.IntParam1, isnull(srvExc.IntParam1,-9)) != -1   
order by 1,2 desc   

select * from #MinAG
