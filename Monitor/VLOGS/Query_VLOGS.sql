

SET NOCOUNT ON

DECLARE @Subject nvarchar(200) 
DECLARE @Body    nvarchar(4000)
DECLARE @JobType nvarchar(200) 


CREATE TABLE [dbo].[#vlogs]
(Instance_Name varchar(256),
DBName sysname,
ConfiguredValue varchar(256),
ExpectedValue varchar(256),
CheckWarning varchar(256))

 --db's with PageVerifyOption Different

 -- check count of VLOG


--variables to hold each 'iteration'  
declare @query varchar(100) 
declare @dbname sysname  
declare @vlfs int  
  
--tables used to 'loop' over databases  
IF OBJECT_ID('tempdb..#databases') IS NoT NULL -- \n\
DROP TABLE #databases 
create table #databases 
      (dbname sysname)  
insert into #databases  


--only choose online databases  
select name from sys.databases where state = 0  
  
--table to hold results  
IF OBJECT_ID('tempdb..#vlfcounts') IS NoT NULL -- \n\
DROP TABLE #vlfcounts 
create table #vlfcounts
    (dbname sysname,  
    vlfcount int)  
  
 
--table to capture DBCC loginfo output  
--changes in the output of DBCC loginfo from SQL2012 mean we have to determine the version 

SET NOCOUNT ON
declare @MajorVersion tinyint  
set @MajorVersion = LEFT(CAST(SERVERPROPERTY('ProductVersion') AS nvarchar(Max)),CHARINDEX('.',CAST(SERVERPROPERTY('ProductVersion') AS nvarchar(Max)))-1) 

 SET NOCOUNT ON 
if @MajorVersion < 11 -- pre-SQL2012 
begin 
    declare @dbccloginfo table  
    (  
        fileid tinyint,  
        file_size bigint,  
        start_offset bigint,  
        fseqNo int,  
        [status] tinyint,  
        parity tinyint,  
        create_lsn numeric(25,0)  
    )  
  
    while exists(select top 1 dbname from #databases)  
    begin  
  
 SET NOCOUNT ON 
        set @dbname = (select top 1 dbname from #databases)  
        set @query = 'dbcc loginfo (' + '''' + @dbname + ''') WITH NO_INFOMSGS '  
   
        insert into @dbccloginfo  
        exec (@query)  
  
        set @vlfs = @@rowcount  
  
        insert #vlfcounts  
        values(@dbname, @vlfs)  
  
        delete from #databases where dbname = @dbname  
  
    end --while 
end 
else 
begin 
    declare @dbccloginfo2012 table  
    (  
        RecoveryUnitId int, 
        fileid tinyint,  
        file_size bigint,  
        start_offset bigint,  
        fseqNo int,  
        [status] tinyint,  
        parity tinyint,  
        create_lsn numeric(25,0)  
    )  
  
    while exists(select top 1 dbname from #databases)  
    begin  
  
        set @dbname = (select top 1 dbname from #databases)  
        set @query = 'dbcc loginfo (' + '''' + @dbname + ''') WITH NO_INFOMSGS '  
  
        insert into @dbccloginfo2012  
        exec (@query)  
  
        set @vlfs = @@rowcount  
  
        insert #vlfcounts  
        values(@dbname, @vlfs)  
  
        delete from #databases where dbname = @dbname  
  
    end --while 
end 


INSERT INTO #vlogs (Instance_Name, DBName, ConfiguredValue, ExpectedValue, CheckWarning)  

SELECT @@servername as Instance_Name
,dbname as DBName -- \n\
,'Current VLogs: '+ cast ( a.vlfcount as varchar(30)) as ConfiguredValue -- \n\
,'Max Expected VLogs: 1000'  as ExpectedValue 
, 'VLogfiles '  as CheckWarning  -- \n\
FROM #vlfcounts a -- \n\
left join DBA..dbaApprovedExceptions dbExc  -- \n\
ON a.dbname = dbExc.ObjectName  -- \n\
and dbExc.ExceptionType = 'dbVLogFilesCount'  -- \n\
left join DBA..dbaApprovedExceptions srvExc  -- \n\
ON srvExc.ExceptionType = 'srvDbVLogFilesCount' -- \n\
and  lower(srvExc.ObjectName) = lower(cast (serverproperty('servername') as varchar(128))) collate database_default -- \n\
GROUP BY a.dbname,a.vlfcount, isnull(dbExc.IntParam1, isnull(srvExc.IntParam1,1000)) , CAST( isnull(srvExc.IntParam1,100) as VARCHAR(30)), isnull(srvExc.IntParam1,-9)   -- \n\
HAVING (a.vlfcount) > isnull(dbExc.IntParam1, isnull(srvExc.IntParam1,1000)) -- \n\
and isnull(srvExc.IntParam1,-9) != -1  -- \n\

select * from #vlogs
