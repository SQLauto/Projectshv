

SET NOCOUNT ON

DECLARE @Subject nvarchar(200) 
DECLARE @Body    nvarchar(4000)
DECLARE @JobType nvarchar(200) 


-- check for long hold locks (longer then 5 minutes)

IF EXISTS(select * from tempdb..sysobjects where name like '%#LongHoldLocks%')
DROP TABLE #LongHoldLocks

CREATE TABLE [dbo].[#LongHoldLocks]
(Instance_Name varchar(256),
DBName sysname,
Blocker_session_id varchar(256),
Blocker_login_name varchar(256),
Blocker_host_name varchar(256),
Blocker_program_name varchar(256),
Blocked_session_id varchar(256),
Blocked_wait_time_seconds varchar(256),
Blocked_login_name varchar(256),
Blocked_host_name varchar(256),
Blocked_program_name varchar(256),
Blocked_wait_resource varchar(256),
MinutesMax varchar(256),
CheckWarning varchar(256)
)

INSERT INTO #LongHoldLocks (Instance_Name,DBName, Blocker_session_id, Blocker_login_name, 
                            Blocker_host_name, Blocker_program_name, Blocked_session_id ,
                                               Blocked_wait_time_seconds, Blocked_login_name, Blocked_host_name, 
                                               Blocked_program_name, Blocked_wait_resource, MinutesMax,CheckWarning )

Select  @@servername as Instance_Name,-- \n\
       db_name(blocked.database_id) as Dbname
         , blockerS.session_id as Blocker_session_id  -- \n\
      , 'BLOCKER information: login: ' + CAST(blockerS.login_name as VARCHAR(128)) as  Blocker_login_name  -- \n\
      , 'Host: ' + CAST( blockerS.host_name as VARCHAR(128))  as  Blocker_host_name  -- \n\
      , 'Program: ' + CAST(  blockerS.program_name as VARCHAR(128))  as  Blocker_program_name  -- \n\
         , 'BLOCKED information: session:' + CAST(blocked.[session_id] as VARCHAR(128)) as [Blocked_session_id]  -- \n\
         , 'Wait Time: ' + CAST( blocked.[wait_time]/1000/60 as VARCHAR(128)) + ' minutes'  as [Blocked_wait_time_seconds]  -- \n\
      , 'login: ' + CAST(blockedS.login_name as VARCHAR(128))  as  Blocked_login_name  -- \n\
      , 'Host: ' + CAST( blockedS.host_name as VARCHAR(128))  as  Blocked_host_name  -- \n\
      , 'Program: ' + CAST(  blockedS.program_name  as VARCHAR(128)) as  Blocked_program_name  -- \n\
      , 'Wait Eesource: ' +  blocked.[wait_resource] as [Blocked_wait_resource]       -- \n\
      , 'Max Agreed Wait Time Is: ' + cast(isnull(ex.IntParam1 , 7) as varchar(50)) + ' minutes.' As MinutesMax -- \n\
         , 'LongHoldLocks ' as CheckWarning 
        -- \n\
from sys.dm_exec_requests blocked  -- \n\
inner join sys.dm_exec_sessions blockerS  -- \n\
on blocked.blocking_session_id =  blockerS.session_id   -- \n\
inner join sys.dm_exec_sessions blockedS  -- \n\
on blocked.session_id =  blockedS.session_id   -- \n\
left join DBA..dbaApprovedExceptions ex  -- \n\
on lower(ex.ObjectName) = lower(cast (serverproperty('servername') as varchar(128))) collate database_default  -- \n\
and ExceptionType = 'srvLongHoldLocks'  -- \n\
where  blocked.blocking_session_id !=0   -- \n\
and blocked.[wait_time] > isnull(ex.IntParam1 , 7)* 60000  -- 300000 wait time in miliseconds = 5 minutes -- \n\
order by blockerS.session_id, blocked.[wait_time] 

select * from #LongHoldLocks