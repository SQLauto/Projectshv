

SET NOCOUNT ON

DECLARE @Subject nvarchar(200) 
DECLARE @Body    nvarchar(4000)
DECLARE @JobType nvarchar(200) 

IF EXISTS(select * from tempdb..sysobjects where name like '%#PageVerify%')
DROP TABLE #PageVerify

CREATE TABLE [dbo].[#PageVerify]
(Instance_Name varchar(256),
DBName sysname,
ConfiguredValue varchar(256),
ExpectedValue varchar(256),
CheckWarning varchar(256))

 --db's with PageVerifyOption Different

 INSERT INTO #PageVerify (Instance_Name, DBName, ConfiguredValue, ExpectedValue, CheckWarning)

 select @@servername as Instance_Name
, name  -- \n\
,'Configured: ' + CAST(page_verify_option_desc  as varchar(50) ) -- \n\
,  -- \n\
'Expected: ' + -- \n\
case isnull(dbExc.IntParam1, isnull(srvExc.IntParam1,2)) -- \n\
when 2 then 'CHECKSUM' -- \n\
when 1 then 'TORN_PAGE_DETECTION' -- \n\
when 0 then 'NoNE' -- \n\
else 'unkNown - ' + CAST(isnull(dbExc.IntParam1, isnull(srvExc.IntParam1,2)) as varchar(50)) -- \n\
end -- \n\
, 'PageVerifyOption'  as CheckWarning  -- \n\
 from sys.databases d  -- \n\
left join DBA..dbaApprovedExceptions dbExc  -- \n\
on d.name = dbExc.ObjectName  collate database_default  -- \n\
and dbExc.ExceptionType = 'dbPageVerify'  -- \n\
left join DBA..dbaApprovedExceptions srvExc  -- \n\
on srvExc.ExceptionType = 'srvDbPageVerify'  -- \n\
and  lower(srvExc.ObjectName) = lower(cast (serverproperty('servername') as varchar(128))) collate database_default  -- \n\
where page_verify_option != isnull(dbExc.IntParam1, isnull(srvExc.IntParam1,2)) /*  0 = NoNE, 1 = TORN_PAGE_DETECTION, 2 = CHECKSUM  */  -- \n\
and d.name != 'tempdb' -- \n\
 and isnull(dbExc.IntParam1, isnull(srvExc.IntParam1,-9)) != -1  -- \n\

select * from #PageVerify