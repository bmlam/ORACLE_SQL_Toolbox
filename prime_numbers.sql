SET ECHO OFF SCan OFF serverout on timing on linesize 140 pages 100 

rem a procedure to compute prime number and store the result into  table prime_numbers
rem that will be created in code if necessary  
rem one use case is to create database session that will mainly consumes CPU and main storage (PGA)
rem this is only for test and demo purpose and has no practical use. According to en.wikipedia.org
rem  "As of December 2018 the largest known prime number has 24,862,048 decimal digits"
rem this procedure only produces primes up to 38 digits!
rem It uses the Sieve of Eratosthenes algorithm

--BEGIN 
--	--
--	-- run once to create table if it does not yet exist
--	-- 
--	FOR tab_rec IN (
--		SELECT UPPER('prime_numbers') table_name FROM dual 
--		MINUS 
--		SELECT table_name FROM user_tables
--	) LOOP
--		EXECUTE IMMEDIATE 
--q'[
--	 CREATE TABLE prime_numbers
--	( prime NUMBER(38) primary key
--	, run_start timestamp not null 
--	, ts_found  timestamp not null 
--	);
--]';
--	END LOOP; 
--END;
--/

alter session set nls_date_format = 'yyyy.mm.dd hh24:mi:ss';








CREATE OR REPLACE PROCEDURE p_prime_numbers 
( i_start_with NUMBER := 1
 ,i_end_with   NUMBER := NULL
 ,i_max_run_seconds NUMBER := 36
) AS 
	--                                       12345678901234567890123456789012345678
	-- lk_max_end_with                       99999999999999999999999999999999999999;
	l_run_start DATE := SYSDATE;
	l_end_with_used NUMBER(38);
	TYPE h_map_varchar2_to_bool IS TABLE OF BOOLEAN INDEX BY VARCHAR2(100);
	lt_prime_flag h_map_varchar2_to_bool;
	l_number_running NUMBER ;
	l_prime_curr 	 NUMBER; 
	l_prime_maybe  	 NUMBER; 
	l_elapse_secs    NUMBER;
	l_stop  BOOLEAN := FALSE;
	l_safety_countdown NUMBER := 9;
BEGIN 
	l_end_with_used := COALESCE( i_end_with, POWER(10,7));
	dbms_output.put_line( $$plsql_unit||':'||$$plsql_line||' '|| systimestamp ||' l_end_with_used: '||l_end_with_used );

	l_number_running := greatest( 2, i_start_with);
	IF mod( l_number_running, 2 ) = 0 THEN
		l_number_running := l_number_running + 1;
	END IF;
	-- step 1
	WHILE l_number_running <= l_end_with_used LOOP
		lt_prime_flag( TO_CHAR(l_number_running)) := NULL;
		l_number_running := l_number_running + 2;
	END LOOP;


	dbms_output.put_line( $$plsql_unit||':'||$$plsql_line||' '|| systimestamp ||' list elems:'||lt_prime_flag.count );
	dbms_output.put_line( $$plsql_unit||':'||$$plsql_line||' '|| systimestamp ||' last in list:'||lt_prime_flag.last );

	WHILE NOT l_stop 
	LOOP
		IF l_prime_curr IS NULL THEN 
			l_prime_curr := 2; -- step 2
		ELSE	
			-- get next prime from list 
			l_prime_maybe := lt_prime_flag.next( l_prime_curr ); 
			l_prime_curr := NULL;
			WHILE l_prime_maybe IS NOT NULL LOOP
				IF lt_prime_flag( l_prime_maybe ) IS NULL THEN
					l_prime_curr := l_prime_maybe;
					EXIT;
				END IF;
				l_prime_maybe := lt_prime_flag.next ( l_prime_maybe );
			END LOOP; -- over list 

		END IF; 
		dbms_output.put_line( $$plsql_unit||':'||$$plsql_line||' '|| systimestamp ||' prime curr: '||l_prime_curr );

		IF l_prime_curr IS NOT NULL 
		THEN 
			-- save the prime number just found
			MERGE INTO prime_numbers d
			USING ( 
				SELECT l_prime_curr prime FROM DUAL 
			) s
			ON (s.prime = d.prime )
			WHEN NOT MATCHED THEN 
				INSERT ( prime,  run_start, ts_found ) 
				VALUES ( s.prime, l_run_start, systimestamp )
			;
			COMMIT;

			l_number_running := l_prime_curr;
			WHILE l_number_running <= l_end_with_used LOOP
				DECLARE 
					l_dummy_flag BOOLEAN;
				BEGIN 
					l_dummy_flag := lt_prime_flag( TO_CHAR(l_number_running));
					-- if previous assignment did not raise NO_DATA_FOUND it means the number is in the list 
				 	lt_prime_flag( TO_CHAR(l_number_running)):= NULL;
				EXCEPTION 
					WHEN NO_DATA_FOUND THEN 
						NULL;
				END test_num_in_list;
				l_number_running := l_number_running + l_prime_curr ;

			END LOOP; -- to mark non-primes 

		END IF; -- a prime found from list 

		l_elapse_secs := ( SYSDATE - l_run_start ) * 1440 * 60;		
		l_stop := l_elapse_secs >= i_max_run_seconds OR l_prime_curr IS NULL ;

		l_safety_countdown := l_safety_countdown - 1;
		IF l_safety_countdown = 0 THEN
			dbms_output.put_line( $$plsql_unit||':'||$$plsql_line||  systimestamp ||' '||' l_safety_countdown reached 0 ' );
			EXIT;
		END IF;
	END LOOP; -- until l_stop 

END;
/

SHOW ERRORS
