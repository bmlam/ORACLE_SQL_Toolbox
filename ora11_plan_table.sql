
CREATE TABLE ORA11_PLAN_TABLE 
   (	STATEMENT_ID VARCHAR2(30), 
	PLAN_ID NUMBER, 
	TIMESTAMP DATE, 
	REMARKS VARCHAR2(4000), 
	OPERATION VARCHAR2(30), 
	OPTIONS VARCHAR2(255), 
	OBJECT_NODE VARCHAR2(128), 
	OBJECT_OWNER VARCHAR2(30), 
	OBJECT_NAME VARCHAR2(30), 
	OBJECT_ALIAS VARCHAR2(65), 
	OBJECT_INSTANCE NUMBER(38,0), 
	OBJECT_TYPE VARCHAR2(30), 
	OPTIMIZER VARCHAR2(255), 
	SEARCH_COLUMNS NUMBER, 
	ID NUMBER(38,0), 
	PARENT_ID NUMBER(38,0), 
	DEPTH NUMBER(38,0), 
	POSITION NUMBER(38,0), 
	COST NUMBER(38,0), 
	CARDINALITY NUMBER(38,0), 
	BYTES NUMBER(38,0), 
	OTHER_TAG VARCHAR2(255), 
	PARTITION_START VARCHAR2(255), 
	PARTITION_STOP VARCHAR2(255), 
	PARTITION_ID NUMBER(38,0), 
	OTHER LONG, 
	OTHER_XML CLOB, 
	DISTRIBUTION VARCHAR2(30), 
	CPU_COST NUMBER(38,0), 
	IO_COST NUMBER(38,0), 
	TEMP_SPACE NUMBER(38,0), 
	ACCESS_PREDICATES VARCHAR2(4000), 
	FILTER_PREDICATES VARCHAR2(4000), 
	PROJECTION VARCHAR2(4000), 
	TIME NUMBER(38,0), 
	QBLOCK_NAME VARCHAR2(30)
   ) 
;

-- comment out grant if not appropiate 
GRANT INSERT, DELETE, SELECT ON ORA11_PLAN_TABLE TO PUBLIC;