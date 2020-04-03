REM the use case or motivation behind this query is to find out how certain objects are
REM in a given status, e.g. queued, or running. The object has two date column A und B,
REM where A is e.g. ENTER_QUEUE_TIME and B is EXIT_QUEUE_TIME. The duration between A and B spans the 
REM time when the object is in the queued status. 
REM We want to know for a given hour or day etc, how many objects are in the queue in average.
REM This query provides the answer, based on a generally available test data set. 
REM We use the CREATED column of DBA_OBJECTS as column A, adds a randomized time interval to A
REM yielding B.

set linesize 120 pages 100

alter session set nls_date_format = 'rr.mm.dd hh24:mi';

define p_days_back=&1
define p_randomize_duration_mins=&2
define p_group_by_date_mask=&3

WITH data_ AS (
	SELECT object_id obj_id, 'queued' as STATUS
		, created - dbms_random.value(low=> 0, high=> 9999 ) / 1440  as ENTER_QUEUE_TIME
		, created + dbms_random.value(low=> 0, high=> &p_randomize_duration_mins ) / 1440 as EXIT_QUEUE_TIME
	FROM dba_objects
	WHERE created >= sysdate - &p_days_back
), factory_ as (
	SELECT level, (sysdate - &p_days_back) + level/1440 minit 
	from dual
	connect by level <=  &p_days_back * 1440
), flat_ AS (
	SELECT status, f.minit, d.ENTER_QUEUE_TIME, d.EXIT_QUEUE_TIME, obj_id
	FROM data_ d 
	JOIN factory_ f ON f.minit >= d.ENTER_QUEUE_TIME and f.minit <= d.EXIT_QUEUE_TIME 
), add_group_key_ AS (
	SELECT status
		, obj_id, ENTER_QUEUE_TIME, EXIT_QUEUE_TIME
		, to_char(minit, '&p_group_by_date_mask') group_key
	FROM flat_
)
SELECT group_key time_slot, count(1) queue_len
--select * 
FROM add_group_key_
GROUP BY group_key
ORDER BY group_key
;

-- test example: view_queue_length_stats.sql 1 30 rr.mm.dd_hh24

