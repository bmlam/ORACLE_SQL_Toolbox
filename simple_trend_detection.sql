alter session set nls_date_format = 'yyyymmdd hh24:mi:ss'; 

with magic_ as (
    select to_date( '20140102 07:00:00' ) as base_time
    from dual
), data_ as (
    select 0 as entity_id, 0 as value, sysdate as probe_time from dual where 1=0 union all
    select 1,              10,         to_date('20140102 07:00:00') from dual union all
    select 1,              20,         to_date('20140102 07:10:00') from dual union all
    select 1,              30,         to_date('20140102 07:30:00') from dual union all
    select 1,              23,         to_date('20140102 07:40:00') from dual union all
    select 1,              22,         to_date('20140102 07:45:00') from dual union all
    select 2,              50,         to_date('20140102 07:00:00') from dual union all
    select 2,              20,         to_date('20140102 07:47:00') from dual union all
    select 3,              40,         to_date('20140102 07:00:00') from dual union all
    select 3,              40,         to_date('20140102 07:52:00') from dual
), dat1_ as (
    select data_.*
      , ( data_.probe_time - m.base_time ) * 1440 as ela_minutes
    from data_ cross join magic_ m
), agg_ as (
    select entity_id,
        avg(value) over(partition by entity_id) as ybar,
        value as y,
        avg(ela_minutes) over(partition by entity_id) as xbar,
        ela_minutes as x
    from dat1_
)
select entity_id, sum( (x - xbar ) * ( y - ybar ) ) / sum( ( x - xbar ) * ( x - xbar ) ) as Beta
from agg_ group by entity_id
--select * from dat1_ 
;

-- If you WERE to activate the line "select * from dat1_ " and comment out the two lines above it, you would see 
-- the raw data as follows:

-- ENTITY_ID      VALUE PROBE_TIME        ELA_MINUTES
------------ ---------- ----------------- -----------
--         1         10 20140102 07:00:00           0
--         1         20 20140102 07:10:00          10
--         1         30 20140102 07:30:00          30
--         1         23 20140102 07:40:00          40
--         1         22 20140102 07:45:00          45
--         2         50 20140102 07:00:00           0
--         2         20 20140102 07:47:00          47
--         3         40 20140102 07:00:00           0
--         3         40 20140102 07:52:00          52
--
--9 rows selected.

--We see that the entity 1 has increasing value, for 2 it is decreasing and for 3 it is unchanged
