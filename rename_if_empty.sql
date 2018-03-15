declare 
	-- Rename any existing table if it is not empty
	-- this is a preparation step that can be used in a CREATE TABLE script when
	-- that script does drop a table before re-creating it.
	-- This way we can avoid the misfortune of unintentionally dropping a table which 
	-- contains valuable data that cannot be re-created easily.
	-- Nothing happens if the table does not exist at all.
	-- The rename procedure composed a deterministic new table name for the rename operation.
	-- If the new name is already used, an exception is raised. However this behaviour should be
	-- desirable for the intended use case of a safe and efficient deployment
	-- An exception is raised 
    lc_table_name constant varchar2(30) := upper('wrk_bas_xyz');
    l_table_name_new varchar2(30);
    l_rows_exist integer; 
    l_table_exist integer;
    l_ddl long; 
	 
	PROCEDURE rename_if_empty( 
		p_table_to_rename VARCHAR2
	) 
	AS
	begin
		 select count(1) into l_table_exist
		 from user_tables
		 where table_name = p_table_to_rename
		 ;
		 if l_table_exist > 0 then 
			  execute immediate 
					'select count(*) into :l_rows_exists from '||p_table_to_rename
					||' where rownum = 1'
					into l_rows_exist
					;
			  if l_rows_exist > 0 then
					NULL;
			  else
					-- The Global Schema Clean will take care of the renamed table some day 
					l_table_name_new := 'BAK_'||to_char(sysdate, 'yyyymmdd')
						 ||'_'
						 ||substr( replace( p_table_to_rename
							  , '_', ''
							  ), 1, 18 
							  )
						 ;
					begin 
						 l_ddl := 'rename '||p_table_to_rename 
							  ||' to '            ||l_table_name_new;
						 dbms_output.put_line( 'Running DDL '||l_ddl||' ...'); 
						 execute immediate l_ddl;
					exception 
						 when others then 
							  raise_application_error(-20000, 'Oracle raised error on: '||chr(10)||l_ddl||': '||chr(10)||sqlerrm);
					end try_rename;
				
			end if; -- rows_exist
		 end if; -- table_exist
	END rename_if_empty;
begin
	rename_if_empty( lc_table_name );
	-- 
	-- uncomment the following lines if we want to drop the table
	-- 
   -- dbms_output.put_line( 'dropping empty table '||lc_table_name||' ...'); 
 
	
end;
/ 
