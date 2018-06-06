

SET NOCOUNT ON

DECLARE @Subject nvarchar(200) 
DECLARE @Body    nvarchar(4000)
DECLARE @JobType nvarchar(200) 


-- Check for files Getting Full
SET NOCOUNT ON

IF exists (select * from tempdb.sys.all_objects where name like '%#FileGettingFull%') 

DROP TABLE #FileGettingFull 

CREATE TABLE #FileGettingFull
(
Instance_Name sysname,
DataFile varchar (512),
PhysicalName varchar (512),
MBTotal varchar (512),
MBused varchar (512),
PercentageUsed varchar (512),
ExpectedPercentage varchar (512),
CheckWarning varchar (512)
)


-- check for files getting full


Insert into #FileGettingFull (Instance_Name,DataFile,PhysicalName,MBTotal, MBused, PercentageUsed,ExpectedPercentage,CheckWarning) 

exec sp_msforeachdb 
'use [?]; 
     SELECT @@servername as Instance_Name, 
       [name] as DataFile, 
       ''physical name: '' + [physical_name] AS PhysicalName,
       ''file total MB: '' + CAST( CAST([size] as DECIMAL(38,0))/128.  AS VARCHAR(20)) AS MBtotal,
       ''MB used: '' + CAST( CAST(FILEPROPERTY([name],''SpaceUsed'') AS DECIMAL(38,0))/128. AS VARCHAR(20)) AS MBUsed,  
       ''percentage used: '' + CAST(CAST(CAST(FILEPROPERTY([name],''SpaceUsed'') AS DECIMAL(38,0))*100.0/CAST([size] as DECIMAL(38,0)) as DECIMAL(32,2)) AS VARCHAR(20))+ ''%'' AS PercentageUsed, 
       ''max expected usage: '' + CAST( isnull(srvExc.IntParam1,90) as VARCHAR(30)) + ''%''  ExpectedPercentage
       , ''DataFileGettingFull '' as CheckWarning  
FROM sys.master_files df 
left join DBA..dbaApprovedExceptions srvExc  
on srvExc.ExceptionType = ''DataMaxUsagePercentage''  
and  lower(srvExc.ObjectName) = lower(cast (serverproperty(''servername'') as varchar(128))) collate database_default  
WHERE  CAST(CAST(FILEPROPERTY(name,''SpaceUsed'') AS DECIMAL(38,0))*100.0/CAST([size] as DECIMAL(38,0)) as DECIMAL(32,2)) > isnull(srvExc.IntParam1,90)' 


select * from #FileGettingFull
