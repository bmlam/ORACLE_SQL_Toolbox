
col target format a50
col units format a6
col opname format a30
col elapsed format 99999
col remaining format 99999
col osuser format a10

set lines 100 pages 100

select * from (
select  s.username 
  , ps."QC SID" qc_sid
  ,s.sid||','||s.serial# by_sid
  , round ( (sysdate-logon_time) * 1440 ) "lifeM" 
  ,s.osuser
--  ,s.sid||','||s.serial# sid_ser
--, 999999 spid 
--,(select spid from v$process p where p.addr=s.paddr) spid
  ,opname, target
  , totalwork as total
  , case units when 'Blocks' then 'Blk' else units end "units" 
  , sofar
  , round( 100 * sofar / case when totalwork = 0 then 1 else totalwork end ) "% done"
  ,case when elapsed_seconds < 60 then to_char(to_char(elapsed_seconds) )||'s'
        when elapsed_seconds > 60 then to_char(round(elapsed_seconds/60, 1))||'m'
        else to_char(elapsed_seconds)
        end
  as "elapsd"
  --,start_time  
  ,case when nvl(time_remaining,0) = 0 then '0'
        when time_remaining < 60 then to_char(time_remaining)||'s'
        else round(time_remaining/60, 1)||'m'
        end
  as "remain"
  , to_char(round( (nvl(time_remaining,0) + elapsed_seconds)/60, 1) )||'m' as est_tot
  , round(sofar/case when elapsed_seconds=0 then 0.001 else elapsed_seconds end ) "UpS" 
  ,last_update_time
  ,substr(client_info,1,4)||'..'||substr(client_info,-4) as "short usid?"
  ,client_info as "usid?"
  ,s.program
  , o.serial#
  , logon_time
  , start_time
  , row_number() over (partition by o.sid order by start_time desc) recentness_rank
  , s.sid
from v$session s
join v$session_longops o
on ( s.sid = o.sid and s.serial#=o.serial# )
left join parallel_server ps
on ( ps.sid = s.sid )
where 1=1
-- and s.username in ( 'xxx')  
--and s.username like 'xxx%'
--   and s.schemaname = 'xxx'  
--  and ( osuser like 'lamb' )
 and s.username like upper('bl_cl%') 
-- and lower(osuser) like 'xxxx'
--  and (lower(program) like '%sqlplus%' ) --  or lower(program) like 'oracle%(p%)' )
  --and lower(s.program) not like '%oracle%' 
--   and s.sid in ( 795 )
  --and logon_time > sysdate - 600/1440
--  and s.action like '%xxx%' 
  )
where 1=1  
  and recentness_rank <= 1
--  and "remain" > 0
order by null 
, qc_sid
--  , opname
 , sid, to_char(logon_time, 'yyyymmddhh24:mi:ss')||to_char( sid) desc  
  --,last_update_time desc
    ,start_time desc
;

rem call pkg_kill.by_sid( 516,37238 );  

select  o.sid
  ,o.username
  ,o.serial#
  ,opname, target, target_desc
  , totalwork as total
  , units, sofar
  ,start_time
  ,case when elapsed_seconds < 60 then to_char(elapsed_seconds)||'s'
        else round(elapsed_seconds/60, 1)||'m'
        end
  as "elapsd"
  ,case when nvl(time_remaining,0) = 0 then null
        when time_remaining < 60 then to_char(time_remaining)||'s'
        else round(time_remaining/60, 1)||'m'
        end
  as "remain"
  ,last_update_time
  , o.serial#
,message    
--,(select spid from v$process p where p.addr=s.paddr) spid
from v$session_longops o
join my_sessions mys 
on ( o.sid = mys.sid and o.serial# = mys.serial#)
where 1=1 
  and o.username not in ('SYS','SYSTEM')  
  --and username = 'INKA_PROFILER'
  --and o.sid in ( 719 )
  --and logon_time > sysdate - 600/1440
  and mys.my_pc  = 'DEMUC11629' 
order by to_char(o.sid) desc  
  --,last_update_time desc
    ,o.start_time desc
;

-- session details from v$
select *
from (
select sid, serial#, sid||','||serial# sid_ser 
 ,username, osuser
  ,status
  ,action
  ,resource_consumer_group rsrc_grp
--   ,paddr
  , round ( (sysdate-logon_time) * 1440 ) "LifeM" 
  ,99999 as spid 
  --, (select spid from v$process p where p.addr=s.paddr) spid
  ,program
   , machine, logon_time
    ,sql_address, sql_hash_value
--    ,(select sql_text from v$sqltext_with_newlines where address = sql_address and piece=0) curr_sql
--    ,(select sql_text from v$sqltext_with_newlines where address = prev_sql_addr and piece=0 ) prev_sql
    ,module
    ,client_info as "usid?"
    ,s.process as cl_pid
from v$session s
where 1=1
---- and username != 'ORACLE'  
 and s.username in( 'xxx') 
--  and osuser like 'lamb'
  --and (lower(program) like 'sqlplus%') -- or lower(program) like 'oracle%(p%)' )
  --and sql_hash_value = '3619688912'  and sid in ( 1708,2645,3281,4477,4513,4697,4722,4773,4787 )
  --and client_info = 'DE81F3D55A1766851373E6950CC8C122'
  --and logon_time > sysdate-5/1440 
order by spid
)
;


rem view entries impacted by transaction 

select sid
 ,sysdate
 --, ses_addr, xidusn usn
	,used_ublk
    , round( used_ublk*16/1024) rbs_mb
    , used_urec 
	,x.status "x-stat"
	,start_time   
    ,round ( ( sysdate - to_date(start_time, 'mm/dd/rr hh24:mi:ss') ) * 1440, 2) "Xtn-mins"
    ,round ( ( sysdate - logon_time ) * 1440, 2) ses_age
--    ,100*round( used_urec/2100000/1, 3) "%done" 
from v$transaction x join v$session s on (saddr = ses_addr) 
where 1=1
  and s.sid in ( 2368  ) 
  --and s.sid = 433 
;  

--SID	SYSDATE USED_UBLK	RBS_MB	USED_UREC	x-stat	START_TIME	Xtn-mins	SES_AGE	%done
--247	11.03.2009 15:38:17	10614	166	2144770	ACTIVE	03/11/09 13:03:34	154,72	229,78	204,3
--247	11.03.2009 15:40:01	10614	166	2144770	ACTIVE	03/11/09 13:03:34	156,45	231,52	204,3

select
	owner, object_name, object_type  
--	(select tablespace_name from dba_tablespaces where ts#
	, obj#
	,statistic_name
	,value
from v$segstat s join dba_objects o on (object_id = obj#)
where object_name = 'XXX'
  and owner = 'XXX'
;

rem monitor the session stats (usually when the queries above do not release sufficient info

select sid
  , to_char(sysdate, 'dd hh24:mi:ss') tstmp
 --, serial#, username, osuser, program
	,block_gets b_gets, consistent_gets c_gets,
	block_changes b_chg, consistent_changes c_chg,
	physical_reads phy_rd
from v$session s join v$sess_io l using (sid)
where username is not null
  --and s.username = user
--    and sid in ( 328 ) 
-- and osuser = 'lambonmi'
;  

rem v$sesstat 

rem v$session_wait   

select * 
from v$sesstat join v$statname using (statistic#)
where sid=119
;

select usn, extents, status, xacts, wraps, shrinks
	, writes/1000000 write_mb
	,hwmsize/1000000 hmw_mb
	,extends
from v$rollstat
where 1=1
  and usn = 7
;


select username, osuser, status, count(*)
from v$session
where 1=1
 -- and username is not null
group by rollup(username, osuser, status)
order by count(*) desc
;

select * 
from v$sess_io
where sid=25
;

select*
from v$sort_segment -- no priv! 
;
