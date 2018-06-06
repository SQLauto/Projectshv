

SET NOCOUNT ON

DECLARE @Subject nvarchar(200) 
DECLARE @Body    nvarchar(4000)
DECLARE @JobType nvarchar(200) 


--Databases with filegroups getting full

IF EXISTS(select * from tempdb..sysobjects where name like '%#FullFileGroup%')
DROP TABLE #FullFileGroup 

CREATE TABLE [dbo].[#FullFileGroup]
(Instance_Name varchar(256),
DBName sysname,
FileGroupName varchar(256),
FileName varchar(256),
TotalGB varchar(256),
UsedDB varchar(256),
Auto_Growth varchar(256),
MaxSizeGB varchar(256),
PercentageUsed varchar(256),
CheckWarning varchar(256))


IF OBJECT_ID('tempdb..#fullDBfiles') is NOT NULL  -- \n\
DROP TABLE #fullDBfiles  -- \n\
  -- \n\
create table #fullDBfiles (dbName nvarchar(128), filegroupName nvarchar(128), fileName nvarchar(128), total8kPages bigint, used8kPages bigint, auto_growth char(3), maxSize bigint)  -- \n\
  -- \n\
insert into  #fullDBfiles   -- \n\
exec sp_msforeachdb 'USE [?]  select ''?'' as dbName,ISNULL(ds.name, ''LOG'') fileGroup, df.name fileName , size totalPages,FILEPROPERTY ( df.name , ''SpaceUsed'' ) usedPages, case growth when 0 then ''NO'' else ''yes'' end as auto_growth, case max_size when -1 then 2147483648 else max_size end as maxSize from sys.database_files df left join sys.filegroups ds on df.data_space_id = ds.data_space_id where df.data_space_id not in ( select       data_space_id       from sys.database_files    where NOT    ( FILEPROPERTY (name , ''SpaceUsed'') >= 0.90 * size  and ( size + (case is_percent_growth when 1 then size*growth/100 else growth end ) >  ( case max_size when -1 then 2147483648 else max_size end) or growth = 0    )      )  )  and ds.is_read_only = 0 and df.type in (0,1) '  -- \n\
  -- \n\

Insert into #FullFileGroup (Instance_Name,DBName,FileGroupName,FileName,TotalGB,UsedDB,Auto_Growth,MaxSizeGB,PercentageUsed,CheckWarning)

select  @@servername as Instance_Name -- \n\
,dbName  -- \n\
, 'FG: ' + filegroupName AS FileGroupName  -- \n\
, 'File: ' + fileName AS FileName  -- \n\
, 'Total GB: ' + cast(cast(total8kPages/128.0/1024.0 as decimal(19,3)) as varchar(20)) AS TotalGB  -- \n\
, 'Used GB: ' + cast(cast(used8kPages/128.0/1024.0 as decimal(19,3)) as varchar(20)) AS UsedGB  -- \n\
, 'Auto Growth: ' + auto_growth AS Auto_Growth  -- \n\
, 'Max size GB: ' + cast(cast(maxSize/128.0/1024.0 as decimal(19,3)) as varchar(20)) AS MaxSizeGB  -- \n\
, 'Percent Used: ' + cast(used8kPages*100/total8kPages as varchar(10))  + '%' as PercentUsed  -- \n\
, 'FullFileGroup' as CheckWarning  -- \n\
from #fullDBfiles fdb  -- \n\
LEFT JOIN DBA..dbaApprovedExceptions ex  -- \n\
ON lower(ex.ObjectName) = lower(cast (serverproperty('servername') AS VARCHAR(128))) COLLATE database_default  -- \n\
and ex.ExceptionType = 'srvFullFileGroup'  -- \n\
LEFT JOIN DBA..dbaApprovedExceptions ex2  -- \n\
ON lower(ex2.ObjectName) = fdb.dbName + ';' + fdb.filegroupName  COLLATE database_default  -- \n\
and ex2.ExceptionType = 'dbFullFileGroup'  -- \n\
WHERE  -- \n\
ex.ObjectName is null  -- \n\
and  -- \n\
ex2.ObjectName is null  -- \n\
  -- \n\
IF OBJECT_ID('tempdb..#fullDBfiles') is NOT NULL  -- \n\
DROP TABLE #fullDBfiles  -- \n\



select * from #FullFileGroup
