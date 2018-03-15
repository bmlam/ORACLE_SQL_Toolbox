-- This is a template query to detect delta in two result sets
with CHANGED_SET as (
	select /*+ parallel(t,8) */ party_id
	from bla
	minus
	select  /*+ parallel(t,8) */party_id
	from blabla
) , EXPECTED_SET as (
	select party_id
	from bla
) , INTERSECT_SET as (
	select party_id
	from CHANGED_SET
	intersect
	select /*+ parallel(t,8) */ party_id
	from EXPECTED_SET
)
select 'CHANGED_SET' src, count(distinct party_id) cnt
from CHANGED_SET
union all
select 'EXPECTED_SET ' src, count(distinct party_id) cnt
from EXPECTED_SET
union all
select 'INTERSECT_SET' src, count(distinct party_id) cnt
from INTERSECT_SET
;
