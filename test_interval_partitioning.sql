set lines 160 echo on


CREATE TABLE amd_job (
	 job_id 		INTEGER NOT NULL PRIMARY KEY
	,se_id 		INTEGER NOT NULL
	,start_ts 	DATE NOT NULL
	,finish_ts 	DATE NOT NULL
	,rerun_seq 	INTEGER
	,exit_code 	INTEGER
	,state 		VARCHAR2(16)
) TABLESPACE tb_nbaprof_01_data
PARTITION BY RANGE ( start_ts )
INTERVAL ( NumToYMInterval( 1, 'YEAR') )
( PARTITION pre2017 VALUES LESS THAN ( TO_DATE( '2017.01.01 00:00:00', 'yyyy.mm.dd hh24:mi:ss') )
)
;

col partition_name format a30
col high_value     format a80

create or replace view vw_test_1234 as
select partition_name, high_value, segment_created
from user_tab_partitions 
where 1=1
  and table_name = 'AMD_JOB'
order by partition_name  
;

select * from vw_test_1234;

insert into amd_job ( job_id, se_id, start_ts, finish_ts, rerun_seq, exit_code , state )
values ( 123,  345, to_date( '2017.05.01', 'yyyy.mm.dd'), to_date( '2017.05.01', 'yyyy.mm.dd'), 0, 0, 'state?' )
;
commit;

select * from vw_test_1234;

insert into amd_job ( job_id, se_id, start_ts, finish_ts, rerun_seq, exit_code , state )
values ( 123+1,  345, to_date( '2017.07.01', 'yyyy.mm.dd'), to_date( '2017.05.01', 'yyyy.mm.dd'), 0, 0, 'state?' )
;
commit;

select * from vw_test_1234;

insert into amd_job ( job_id, se_id, start_ts, finish_ts, rerun_seq, exit_code , state )
values ( 123+2,  345, to_date( '2017.09.01', 'yyyy.mm.dd'), to_date( '2017.05.01', 'yyyy.mm.dd'), 0, 0, 'state?' )
;
commit;

select * from vw_test_1234;


