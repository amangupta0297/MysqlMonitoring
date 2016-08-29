#!/bin/bash
# MySQL monitoring script
# razique.mahroua@gmail.com
# Version 0
#| ----------- Notes de version ----------------------------| 
#|                                                          |
#|----------------------------------------------------------|   

#| ----------- Usage------ ---------------------------------| 
#| ./SCRIPT.sh    										    |
#|----------------------------------------------------------|

CUT=/usr/bin/cut;
ZABBIX_SENDER=/usr/local/bin/zabbix_sender;
ZABBIX_CONFIG_FILE=/etc/zabbix/zabbix_agentd.conf;
ZABBIX_HOSTNAME=`cat $ZABBIX_CONFIG_FILE | grep Hostname | sed 's/^.........//'`
ZABBIX_TMP_VARIABLES_NAME="mysql.variables.";
ZABBIX_TMP_STATUS_NAME="mysql.status.";
ZABBIX_TMP_VARIABLES=zabbix_variables.tmp;
ZABBIX_TMP_STATUS=zabbix_status.tmp;
MYSQL=/usr/bin/mysql;
MYSQL_USER=;
MYSQL_PASS=;
MYSQL_GLOBAL_VARIABLES="SHOW GLOBAL VARIABLES";
MYSQL_GLOBAL_STATUS="SHOW GLOBAL STATUS";
MYSQL_DELIMITER='";';
MYSQL_OUTPUT_VARIABLES=mysql_output_variables.tmp;
MYSQL_OUTPUT_STATUS=mysql_output_status.tmp;
DEBUG=0;

# 1- Values that will be given to the zabbix_sender
variables=(
innodb_additional_mem_pool_size	
innodb_buffer_pool_size	
innodb_file_io_threads	
innodb_log_buffer_size	
innodb_log_file_size	
innodb_max_dirty_pages_pct	
innodb_open_files	
innodb_thread_concurrency
innodb_thread_sleep_delay	
join_buffer_size	
long_query_time
max_allowed_packet	
max_binlog_cache_size	
max_binlog_size	
max_connect_errors	
max_connections	
max_delayed_threads	
max_heap_table_size	
max_join_size	
max_length_for_sort_data	
max_prepared_stmt_count	
open_files_limit	
query_alloc_block_size	
query_cache_limit	
query_cache_min_res_unit	
query_cache_size	
query_cache_type	
query_cache_wlock_invalidate	
query_prealloc_size	
read_buffer_size	
sort_buffer_size	
sql_max_join_size	
sql_select_limit	
table_lock_wait_timeout
thread_cache_size
table_cache
tmp_table_size	
wait_timeout	
)

status=(
Aborted_clients	
Aborted_connects
Bytes_received	
Bytes_sent	
Com_commit	
Com_delete	
Com_delete_multi
Com_execute_sql	
Com_help	
Com_insert
Com_insert_select	
Com_lock_tables	
Com_optimize	
Com_replace
Com_replace_select
Com_rollback
Com_select	
Com_update	
Com_update_multi	
Connections	
Created_tmp_disk_tables	
Created_tmp_files
Created_tmp_tables	
Delayed_errors	
Delayed_insert_threads	
Delayed_writes	
Innodb_buffer_pool_pages_data	
Innodb_buffer_pool_pages_dirty	
Innodb_buffer_pool_pages_flushed	
Innodb_buffer_pool_pages_free	
Innodb_buffer_pool_pages_misc	
Innodb_buffer_pool_pages_total	
Innodb_buffer_pool_read_requests	
Innodb_buffer_pool_reads	
Innodb_buffer_pool_wait_free	
Innodb_buffer_pool_write_requests	
Innodb_data_pending_fsyncs
Innodb_data_pending_reads	
Innodb_data_pending_writes
Innodb_data_read	
Innodb_data_reads	
Innodb_data_writes	
Innodb_data_written	
Innodb_log_waits	
Innodb_log_write_requests	
Innodb_log_writes
Innodb_page_size	
Innodb_pages_created	
Innodb_pages_read	
Innodb_pages_written	
Innodb_rows_deleted	
Innodb_rows_inserted	
Innodb_row_lock_current_waits
Innodb_rows_read	
Innodb_rows_updated	
Max_used_connections	
Open_files	
Opened_files
Open_tables	
Qcache_free_blocks
Qcache_free_memory
Qcache_hits
Qcache_inserts
Qcache_total_blocks
Queries	
Questions	
Slow_queries
Table_locks_immediate	
Table_locks_waited	
Threads_cached	
Threads_connected	
Threads_created	
Threads_running	
Uptime
)

# 2a- We first create the files
touch $ZABBIX_TMP_VARIABLES $ZABBIX_TMP_STATUS;

# 2- We extract the raw values for both values (global and status)
echo $MYSQL_GLOBAL_VARIABLES | $MYSQL -u $MYSQL_USER -p$MYSQL_PASS > $MYSQL_OUTPUT_VARIABLES ;
echo $MYSQL_GLOBAL_STATUS | $MYSQL -u $MYSQL_USER -p$MYSQL_PASS > $MYSQL_OUTPUT_STATUS ;

# 3- We iterate the array in order to filter the files 
for variables in ${variables[*]}; do
	cat $MYSQL_OUTPUT_VARIABLES | grep $variables >> $ZABBIX_TMP_VARIABLES ;
done
	# We prepend the name 
	sed -i "s/^/$ZABBIX_HOSTNAME $ZABBIX_TMP_VARIABLES_NAME/" $ZABBIX_TMP_VARIABLES

for status in ${status[*]}; do
	cat $MYSQL_OUTPUT_STATUS | grep $status >> $ZABBIX_TMP_STATUS ;
done
	# We prepend the name 
	sed -i "s/^/$ZABBIX_HOSTNAME $ZABBIX_TMP_STATUS_NAME/" $ZABBIX_TMP_STATUS;


# 4- We delete the MySQL files
rm $MYSQL_OUTPUT_VARIABLES $MYSQL_OUTPUT_STATUS

# 5- We finally send the values to the Zabbix_sender 
case "$DEBUG" in
	"1"*)
 	echo -e '------------------------------------------\n\E[47;35m'"\033[1mValues Datas :\033[0m" 
	cat $ZABBIX_TMP_VARIABLES
	
 	# 5a- The values file
	echo -e '------------------------------------------\n\E[47;35m'"\033[1mZabbix Output :\033[0m" 
	$ZABBIX_SENDER -c $ZABBIX_CONFIG_FILE -i $ZABBIX_TMP_VARIABLES  -vv	

	echo -e '------------------------------------------\n\E[47;35m'"\033[1mStatus Datas :\033[0m" 
	cat $ZABBIX_TMP_STATUS
	
	# 5b- The staus file
	echo -e '------------------------------------------\n\E[47;35m'"\033[1mZabbix Output :\033[0m" 
 	$ZABBIX_SENDER -c $ZABBIX_CONFIG_FILE -i $ZABBIX_TMP_STATUS -vv
	;;

	"0"*)
	$ZABBIX_SENDER -c $ZABBIX_CONFIG_FILE -i $ZABBIX_TMP_VARIABLES
	# 5b- The staus file
	$ZABBIX_SENDER -c $ZABBIX_CONFIG_FILE -i $ZABBIX_TMP_STATUS
	;;
esac
	
# 6- We delete the Zabbix files
rm	$ZABBIX_TMP_VARIABLES $ZABBIX_TMP_STATUS
