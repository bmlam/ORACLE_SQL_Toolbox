REM some experiments to understand how date and timestamp data types work in Oracle 

rem UNIX only has a tick count to hold the system. Besides, the process handling system service may have a timezone environment variable
REM in the absence of a timezone, presumably UTC or GMT is assumed. 
REM timezone is interpreted as a negative or positive offset in hours and minutes to UTC. 
rem SYSDATE will display this tick count with consideration to the timezone. In the absence of a configured timezone, the offset is zero, 
REM column of DATE type presumably stores the tick count since epoch, which makes the time unambiguous. 
rem column of TIMESTAMP, TIMESTAMP WITH TIME ZONE, TIMESTAMP WITH local TIME ZONE no longer stores the tick count
rem but presumably the tick count value has been converted and decomposed to units for year, month, day etc 
REM CAST does not ensure that the value stored as one of the TIMESTAMP types is as unambiguous as the tick count

select systimestamp, sysdate, current_date, sessiontimezone  from dual;
alter session set nls_date_format = 'yyyy-mm-dd hh24:mi:ss';
alter session set nls_LANGUAGE = 'GERMAN';
select * from nls_session_parameters
;
ALTER SESSION SET TIME_ZONE = '-5:0'
;
SELECT systemtimezone from dual
;
create table test_tz ( ts timestamp );

insert into test_tz values( cast ( sysdate as timestamp ) );
insert into test_tz values(  ( systimestamp ) );
insert into test_tz values( cast ( sysdate as timestamp with local time zone ) );
insert into test_tz values( cast ( systimestamp as timestamp with local time zone ) );
select * from test_tz
;

create table test_tz2 ( ts timestamp with time zone);

insert into test_tz2 values( cast ( sysdate as timestamp ) );
insert into test_tz2 values(  ( systimestamp ) );
insert into test_tz2 values( cast ( sysdate as timestamp with local time zone ) );
insert into test_tz2 values( cast ( systimestamp as timestamp with local time zone ) );
select * from test_tz2
;

