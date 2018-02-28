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

-- The table has these rows:

--SQL> select * from test_lnnvl order by a, b;
--
--         A          B
------------ ----------
--         1          1
--         1          2
--         1 null
--         2          1
--         2          2
--         2 null
--null                1
--null                2
--null       null
--
--9 rows selected.

-- From an intuitive understanding of the use cases of LNNVL - the way I personally interpret
-- purpose of this function - Logical Negation with special handling for Null VaLues, only the 1.
-- the 5 and the last row should be excluded by the expression LNNVL( a = b ), i.e. I expect 6 rows
-- to be returned.
-- But see what the function really does:

-- SQL> select * from test_lnnvl where lnnvl( a = b );
-- 
--          A          B
-- ---------- ----------
--          1 null
-- null                1
-- null       null
-- 
-- It only returns 4 rows. The following rows are missing in the result set:
--          1          1
-- null       null

-- One of the presumed use case for LNNVL is in a MERGE statement. It is suppose to update
-- only those rows which differ in at least one column in the target and source result set
-- taking null value into consideration. 
-- I saw a few programmer uses this function because they LNNVL will take care of the null
-- value nicely. But as we have seen, the function is not really up to this expectation.
