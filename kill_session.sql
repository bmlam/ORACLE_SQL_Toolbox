select 
  to_char( sql_exec_start, 'yyyymmdd hh24:mi:ss' ) sql_started
  , status
  , substr(program, 1, 12) program
  , username
  , 'declare x number; begin x:= sys.sf_kill_session( '||sid||', '||serial#||' ); end; '||chr(10)||'/' kill_cmd1_old
  , logon_time
  ,osuser
  , s.*
from gv$session s
where 1=1
--  and schemaname = user
  and username = 'BZ_60BAT'
--  and program like 'ora%'
--  and lower(osuser) like  'a%'
--  and osuser like 'bonlam%'
--   and sid = 922
--  and module = 'licensing.sk_listener.ep_queue_listener'  
order by s.logon_time
;

select 'exec dbms_scheduler.drop_job( '''||job_name||''', force=> true) ' kill_job
,j.* 
from dba_scheduler_jobs j
where job_name like 'EP_PROCESS_RUNN%'
--owner = 'BZ_60BAT'
order by last_start_date desc 
;
