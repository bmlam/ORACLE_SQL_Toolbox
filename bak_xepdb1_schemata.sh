#!/bin/bash

DATA_PUMP_DIR=/opt/oracle/admin/XE/dpdump/8EA8703789F26816E053CB3CA0D96BBE
file_prefix=sfwbe2_XE-`date +%Y%m%d`-selected_schemata
dump_file=$file_prefix.dmp
log_file=$file_prefix.log

schemata=APX_SERVICE,DBOSYNC,FLOWS_FILES,HR,IOS_APP_DATA,ISO,LAM,LAMBONMI,PDBADMIN,SERVICE,SFW_MISC,SH,TEST_LOG_INSTALL

echo "Dump file: $dump_file"
echo "Will use password from env var ORA_SECRET"

expdp system/$ORA_SECRET@xepdb1 dumpfile=$dump_file logfile=$log_file schemas=$schemata
