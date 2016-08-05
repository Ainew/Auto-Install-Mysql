#!/bin/bash
#author longxibendi
#function install MySQL5.1.45



###################################### configure and install  #####################################################
mkdir -p /home/longxibendi/mysql/usr/local/mysql
cd 
mkdir mysql
cd mysql
wget http://downloads.mysql.com/archives/mysql-5.1/mysql-5.1.45.tar.gz

tar zxvf mysql-5.1.45.tar.gz
cd mysql-5.1.45




./configure --prefix=/home/longxibendi/mysql/usr/local/mysql --without-debug --without-bench --enable-thread-safe-client --enable-assembler --enable-profiling --with-mysqld-ldflags=-all-static --with-client-ldflags=-all-static --with-charset=latin1 --with-extra-charset=utf8,gbk --with-innodb --with-mysqld-user=longxibendi --without-embedded-server --with-server-sufix=community  --with-unix-socket-path=/home/longxibendi/mysql/usr/local/mysql/sock/mysql.sock  --enable-assembler --with-extra-charsets=complex --enable-thread-safe-client --with-big-tables --with-readline --with-ssl  --with-plugins=partition,heap,innobase,myisam,myisammrg,csv
make -j `cat /proc/cpuinfo | grep 'model name' | wc -l ` && make install



###################################### set log and data storage path  #####################################################

chmod +w /home/longxibendi/mysql/usr/local/mysql
mkdir  -p /home/longxibendi/mysql/3309/data/
mkdir  -p /home/longxibendi/mysql/3309/binlog/
mkdir  -p /home/longxibendi/mysql/3309/relaylog/


###################################### create data file #####################################################

/home/longxibendi/mysql/usr/local/mysql/bin/mysql_install_db --basedir=/home/longxibendi/mysql/usr/local/mysql --datadir=/home/longxibendi/mysql/3309/data --user=longxibendi


####################################### create my.cnf  profile #####################################################

echo "
[client]
character-set-server = utf8
port    = 3309
socket  = /home/longxibendi/mysql/usr/local/mysql/sock/mysql.sock

[mysqld]
character-set-server = utf8
replicate-ignore-db = mysql
replicate-ignore-db = test
replicate-ignore-db = information_schema
user    = mysql
port    = 3309
socket  = /home/longxibendi/mysql/usr/local/mysql/sock/mysql.sock
basedir = /home/longxibendi/mysql
datadir = /home/longxibendi/mysql/3309/data
log-error = /home/longxibendi/mysql/3309/mysql_error.log
pid-file = /home/longxibendi/mysql/3309/mysql.pid
open_files_limit    = 10240
back_log = 600
max_connections = 5000
max_connect_errors = 6000
table_cache = 614
external-locking = FALSE
max_allowed_packet = 16M
sort_buffer_size = 1M
join_buffer_size = 1M
thread_cache_size = 300
#thread_concurrency = 8
query_cache_size = 20M
query_cache_limit = 2M
query_cache_min_res_unit = 2k
default-storage-engine = MyISAM
thread_stack = 192K
transaction_isolation = READ-COMMITTED
tmp_table_size = 20M
max_heap_table_size = 20M
long_query_time = 3
log-slave-updates
log-bin = /home/longxibendi/mysql/3309/binlog/binlog
binlog_cache_size = 4M
binlog_format = MIXED
max_binlog_cache_size = 8M
max_binlog_size = 20M
relay-log-index = /home/longxibendi/mysql/3309/relaylog/relaylog
relay-log-info-file = /home/longxibendi/mysql/3309/relaylog/relaylog
relay-log = /home/longxibendi/mysql/3309/relaylog/relaylog
expire_logs_days = 30
key_buffer_size = 10M
read_buffer_size = 1M
read_rnd_buffer_size = 6M
bulk_insert_buffer_size = 4M
myisam_sort_buffer_size = 8M
myisam_max_sort_file_size = 20M
myisam_repair_threads = 1
myisam_recover

interactive_timeout = 120
wait_timeout = 120

skip-name-resolve
#master-connect-retry = 10
slave-skip-errors = 1032,1062,126,1114,1146,1048,1396

#master-host     =   192.168.1.2
#master-user     =   username
#master-password =   password
#master-port     =  3309

server-id = 1

innodb_additional_mem_pool_size = 16M
innodb_buffer_pool_size = 20M
innodb_data_file_path = ibdata1:56M:autoextend
innodb_file_io_threads = 4
innodb_thread_concurrency = 8
innodb_flush_log_at_trx_commit = 2
innodb_log_buffer_size = 16M
innodb_log_file_size = 20M
innodb_log_files_in_group = 3
innodb_max_dirty_pages_pct = 90
innodb_lock_wait_timeout = 120
innodb_file_per_table = 0

#log-slow-queries = /home/longxibendi/mysql/3309/slow.log
#long_query_time = 10

[mysqldump]
quick
max_allowed_packet = 32M

" > /home/longxibendi/mysql/3309/my.cnf


############################### solve  bug  http://bugs.mysql.com/bug.php?id=37942  #############################################

mkdir -p /home/longxibendi/mysql/share/mysql/english/
cp /home/longxibendi/mysql/usr/local/mysql/share/mysql/english/errmsg.sys /home/longxibendi/mysql/share/mysql/english/

############################### start MySQL Server  #############################################
/bin/sh /home/longxibendi/mysql/usr/local/mysql/bin/mysqld_safe --defaults-file=/home/longxibendi/mysql/3309/my.cnf 2>&1 > /dev/null &
############################### try use MySQL Server  #############################################
/home/longxibendi/mysql/usr/local/mysql/bin/mysql -u root -p -S /home/longxibendi/mysql/usr/local/mysql/sock/mysql.sock -P3309 -h127.0.0.1 -e "show databases;"
