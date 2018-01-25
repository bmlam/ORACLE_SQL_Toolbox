 

create table test_part 
partition by range (created)
(
    partition p20180124 values less than ( to_date( '2018.01.25 00:00:00', 'yyyy.mm.dd hh24:mi:ss') )
   ,partition p20180125 values less than ( to_date( '2018.01.26 00:00:00', 'yyyy.mm.dd hh24:mi:ss') )
)   
as 
select * from user_objects   
where created > trunc( sysdate - 1 )
;

with magic_ as (
    select 'P' as part_name_prefix
        , 'yyyy.mm.dd hh24:mi:ss' as date_mask_universal
        , 'yyyymmdd' as date_mask_name_infix
        , '' part_name_suffix
        , 1 interval_in_days 
        , to_date('2017.12.01 00:00:00', 'yyyy.mm.dd hh24:mi:ss' ) start_time
        , to_date('2018.04.01 00:00:00', 'yyyy.mm.dd hh24:mi:ss' ) end_time
        , 999 max_partitions 
    from dual
), time_range0_ as (
    select 
     m.start_time + (rownum - 1) * m.interval_in_days as time_val
    , m.start_time + (rownum - 0) * m.interval_in_days as time_val_upper_bound
    , m.date_mask_universal, m.part_name_prefix, m.date_mask_name_infix
    , m.part_name_suffix, m.end_time
    from magic_ m
    connect by  level <= max_partitions
), time_range1_ as (
    select r.*
        , ''''|| to_char( time_val_upper_bound, r.date_mask_universal)||'''' as quoted_upper_bound
        , to_char( time_val, r.date_mask_universal ) as time_val_str
        , to_char( time_val, date_mask_name_infix ) part_name_infix
    from time_range0_ r
    where time_val <= end_time
)
select ',PARTITION '|| part_name_prefix||part_name_infix||part_name_suffix
    ||' VALUES LESS THAN ( TO_DATE(' ||quoted_upper_bound|| ', '''||date_mask_universal||''' )'  partition_clause
from time_range1_ order by 1
;