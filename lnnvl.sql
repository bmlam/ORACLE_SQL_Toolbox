set null null

create table test_lnnvl as 
with seed_ as (
   select 1 as val from dual union all
   select 2        from dual union all
   select null     from dual
), a_b as (
	select 
	  a.val a
	 ,b.val b
	from seed_ a
	cross join seed_ b
)
select a, b
-- , case when lnvnl( a = b) then 'true' else 'false' ) end as "lnnvl"
from a_b
;

-- SQL> select * from test_lnnvl where lnnvl( a = b );
-- 
--          A          B
-- ---------- ----------
--          1 null
-- null                1
-- null       null
-- 
-- -- conclusion lnnvl is not suitable for eliminating redundant UPDATE in a MERGE statement. We would want following rows to be
-- -- eliminatie:
-- 
--          1          1
-- null       null
