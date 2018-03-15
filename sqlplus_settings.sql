set lines 120 pages 60

set timing on

column action         format a20
column db_name        format a10
column module         format a10
column my_pc          format a10
column name           format a30
column object_name    format a30
column object_owner   format a15
column object_type    format a15
column owner          format a15
column program        format a15
column step           format a20
column type           format a15
column username       format a15

column "Type"           format a15

alter session set nls_date_format = 'yyyy.mm.dd hh24:mi';