REM Many SQL statement found on the web assume that the examplary tables departments and employees exist
REM on the database. Unfortunately, some sites or the DBAs did not care to create these tables in there 
REM test environment. Also some users may have privileges to execute queries but do not have the privilege
REM to create tables. 
REM The following statement provides a solution to the problem of not having access to the tables:
 
WITH departments as (
   SELECT 0 department_id, 'bla' department_name, 'bla' location FROM dual WHERE 1=0
   UNION ALL SELECT 10 ,   'Operations'         , 'muc'          FROM dual 
   UNION ALL SELECT 20 ,   'Sales'              , 'lax'          FROM dual 
   UNION ALL SELECT 30 ,   'Research'           , 'sop'          FROM dual 
), employees AS (
   SELECT 0 employee_id, 'bla' first_name, 'bla' last_name, 0 department_id, 0 salary FROM dual WHERE 1=0
   UNION ALL SELECT 123, 'Adam'          , 'Smith',         10             , 1000     FROM DUAL
   UNION ALL SELECT 124, 'Bob'           , 'Chang',         10             , 1000     FROM DUAL
   UNION ALL SELECT 224, 'Bob'           , 'Mansion',       10             , 1000     FROM DUAL
   UNION ALL SELECT 125, 'Charlie'       , 'Nogya',         20             , 1400     FROM DUAL
)
SELECT d.*, e.*
FROM employees e
RIGHT JOIN departments d
ON (e.department_id = d.department_id )
;