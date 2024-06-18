REM this script generates a query to compare 2 tables which have the same columns 
REM it is assumed that both tables have common unique key column(s) since 
REM the query will order the rows by this unique key.

DEF table_1=&1 
DEF table_2=&2
DEF unique_key_columns=&3 

VAR sql_clob CLOB 

DECLARE 
  c_columns_per_line CONSTANT SIMPLE_INTEGER := 5;
  v_sql CLOB ;
  v_formatted_column_list VARCHAR(32000);
  v_t1_fully_qualified    VARCHAR2(100);
  v_t2_fully_qualified    VARCHAR2(100);
  v_uniq_key_list         VARCHAR2(100) := '&unique_key_columns';
BEGIN   
  FOR r IN ( 
    WITH 
      -- split str to columns if we need to evaluate each column name 
      -- uniq_cols_str AS ( 
      --   SELECT '&unique_key_columns' AS str 
      --   FROM dual 
      -- ), uniq_cols AS ( 
      --   SELECT upper( regexp_substr( str , '[^,]+', 1, level ) ) AS column_name 
      --     , level 
      --     , length( str ) - length ( replace( str, ',' ) ) AS dbx1
      --   FROM uniq_cols_str 
      --   CONNECT BY level <= length( str ) - length ( replace( str, ',' ) ) + 1
      -- ) ,
      tab_names_str AS ( 
        SELECT 
          '&table_1' AS t1_str 
         ,'&table_2' AS t2_str 
        FROM dual 
      ), tabs_4_cmp AS ( 
        SELECT 
          upper( regexp_replace( t1_str, '^(.*)\.(.*)$', '\1' )) AS t1_schema
         ,upper( regexp_replace( t1_str, '^(.*)\.(.*)$', '\2' )) AS t1_table
         ,upper( regexp_replace( t2_str, '^(.*)\.(.*)$', '\1' )) AS t2_schema
         ,upper( regexp_replace( t2_str, '^(.*)\.(.*)$', '\2' )) AS t2_table
        FROM tab_names_str 
      )
      , cols_4_cmp AS ( 
        SELECT  c.column_name , c.column_id 
        FROM dba_tab_columns c 
        JOIN tabs_4_cmp s ON s.t1_schema = c.owner AND s.t1_table = c.table_name 
      )
      SELECT tab.*, col.*     
        , count(1)      OVER ( PARTITION BY NULL ) col_cnt 
        , row_number()  OVER ( PARTITION BY NULL ORDER BY column_id) col_seq 
      FROM cols_4_cmp       col
      CROSS JOIN tabs_4_cmp tab
  ) LOOP 
    v_formatted_column_list := 
      CASE 
        WHEN r.col_seq > 1 THEN v_formatted_column_list 
          || CASE WHEN mod( r.col_seq, c_columns_per_line) = 0 THEN chr(10) END 
          ||', '
        END 
        ||r.column_name 
        ;
    IF r.col_seq = r.col_cnt THEN 
      v_t1_fully_qualified := lower( r.t1_schema||'.'||r.t1_table );
      v_t2_fully_qualified := lower( r.t2_schema||'.'||r.t2_table );
    END IF;
  END LOOP;
  -- 
  v_sql := 
  'WITH alt AS ( '||chr(10)
    ||'  SELECT '||v_formatted_column_list||chr(10)
    ||'  FROM '||v_t1_fully_qualified||chr(10) 
    ||'), neu AS ('||chr(10) 
    ||'  SELECT '||v_formatted_column_list||chr(10)
    ||'  FROM '||v_t2_fully_qualified||chr(10)
    ||'), a_min_n AS ('||chr(10) 
    || 'SELECT * FROM alt MINUS SELECT * FROM neu'||chr(10)
    ||'), n_min_a AS ('||chr(10) 
    || 'SELECT * FROM neu MINUS SELECT * FROM alt'||chr(10)
    ||'), ua AS ('||chr(10) 
    ||'  SELECT ''a_min_n'' src, a_min_n.* FROM a_min_n'||chr(10) 
    ||'  UNION ALL '||chr(10)
    ||'  SELECT ''n_min_a'' src, n_min_a.* FROM n_min_a'||chr(10) 
    ||') '||chr(10) 
    ||', intsect AS ( '||chr(10) 
    ||'  SELECT '||v_formatted_column_list||chr(10)
    ||'  FROM '||v_t1_fully_qualified||chr(10) 
    ||'  INTERSECT '|| chr(10) 
    ||'  SELECT '||v_formatted_column_list||chr(10)
    ||'  FROM '||v_t2_fully_qualified||chr(10) 
    ||') '||chr(10) 
    ||'SELECT * FROM ua ORDER BY '||v_uniq_key_list||' ,src' ||chr(10)
    ||';'
    ;
  :sql_clob := v_sql;
END;
/

COL spool_path NEW_VALUE spool_path 

SELECT 'n:\pers\tmp\xxx_'||to_char( sysdate, 'yyyy_mm_dd_hh24miss')||'.txt' AS spool_path
FROM dual;

SET LONG 100000 LONGCHUNKSIZE 100000 PAGESIZE 0 trimspool on 

SPOOL &spool_path

PRINT :sql_clob

SPOOL OFF 

PROMPT SQL spooled to &spool_path