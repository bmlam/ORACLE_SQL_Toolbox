REM to quickly capture performance related parameters from many DB instances 

define spool_file=&1

set lines 132 pages 60

column db_name        format a10
column name           format a40
column value          format a60
column isdefault      format a6

spool &spool_file append;

select sys_context('userenv', 'db_name' ) db_name, name, value, isdefault
-- , t.*
from v$parameter t
where regexp_like( name, 'cpu|cache_size|^sga|memory.*target|xxx' )
  and not regexp_like ( name, 'inmemory|db_.*k_cache_size|data_transfer_cache_size|flash' )
order by t.name 
;
spool off
