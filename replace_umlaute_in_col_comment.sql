-- generate column comments. To get good result for comments containing german special characters, run it
-- on a database where these characters are OK, the convert function helps to identify such data
WITH add_cmp_data AS (
  SELECT tc. table_name, cc.column_name, cc.comments
    ,  convert( comments, 'utf8', 'us7ascii' ) comm2
  FROM user_col_comments cc
  join user_tab_columns tc
  on  tc.table_name  = cc.table_name
  and tc.column_name = cc.column_name
  where tc.table_name = 'CMT_DOKUMENTE_LOB_JN'
    and cc.comments is not null
  ORDER BY tc.column_id
)
SELECT null x -- cc.*, tc.column_id
, 'COMMENT ON COLUMN '||cc.table_name||'.'||cc.column_name||' IS '''
  || cc.comments
  ||''''||chr(10)||'/' comment_original
, 'COMMENT ON COLUMN '||cc.table_name||'.'||cc.column_name||' IS '''
  ||
  replace( -- Upper case not yet replaced!
      replace(
        replace(
          replace( cc.comments, 'ä', 'ae' )
            , 'ö', 'oe' )
              ,'ü', 'ue' )
                , 'ß', 'ss' )     
  ||''''||chr(10)||'/' comment_umlaut_converted
FROM add_cmp_data cc
WHERE 1=1
-- AND comm2 <> comments
;
 
