SET NOCOUNT ON
select b.name, b.job_id, a.email_address, a.name
from msdb..[sysoperators] a
inner join msdb..sysjobs b
on a.id = b.notify_email_operator_id