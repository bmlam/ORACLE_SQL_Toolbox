-- Extract column definition from data dictionary
select co.column_name, co.data_type, 
  case 
  when data_type = 'NUMBER' then data_precision ||
        case when data_scale > 0 then ','||data_scale end
  when data_type in ('VARCHAR2', 'CHAR' ) then to_char( data_length ) 
  end as data_size 
, cm.comments
from user_tab_columns co
join user_col_comments cm
on ( co.table_name = cm.table_name 
  and co.column_name = cm.column_name 
)
where 1=1
  and co.table_name = 'IMP_XF_JOURNEY_KPIS'
  order by co.column_id
  ;      