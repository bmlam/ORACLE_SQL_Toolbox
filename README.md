# ORACLE_SQL_Toolbox
Simple or maybe more complex example to demonstrate Oracle SQL power or features

I hope the name of each script explains the purpose of itself. Nevertheless, some scripts are explained in more details as follows:

create_range_partitions.sql: 
When creating a new range partitioned table based on a date column, one seemingly daunting task to to create 
and specify the value range of each partitions. This script assumes that you want to apply a equal time interval to each partition. You 
just need to configure some parameters in the inline view named magic_ and the query will generated the partition clauses for you.

mortgage_with_model.sql:
A non-trivial example of emulating the functionality of a spreadsheet software. The example displays the mortgage payment plan your mortgage loan consultant might show you or which you might cook up yourself with your favorite software. The difference is that the "software" here is plain text you you just need access to an Oracle database to modify and visualize the plan. This query had been published on my wordpress site and clearly I will use github to maintain it in the future.
