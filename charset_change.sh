read -p "give root password for mysql --------> " root_pass
host=localhost
port=3306
date_time=$(date -Iseconds)

db_arr=( helpdesk helpdesk_admin )

for db in ${db_arr[@]} ; do
    queries_arr=()
    queries_arr+="SELECT CONCAT('ALTER TABLE ', TABLE_SCHEMA, '.', TABLE_NAME, ' CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;') AS query FROM information_schema.TABLES WHERE TABLE_SCHEMA = '$db' AND TABLE_COLLATION != 'utf8mb4_general_ci' INTO OUTFILE '/tmp/table_charset$db$date_time.sql';"
    queries_arr+="SELECT CONCAT('ALTER TABLE ', TABLE_SCHEMA, '.', TABLE_NAME, ' MODIFY ', COLUMN_NAME, ' ', COLUMN_TYPE, ' CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;') AS query FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = '$db' AND COLLATION_NAME != 'utf8mb4_general_ci' AND COLLATION_NAME IS NOT NULL INTO OUTFILE '/tmp/column_charset$db$date_time.sql';"
    for query in ${queries_arr[@]}; do
        mysql -h$host -P$port -uroot -p$root_pass  --execute "$query" 
    done
    mysql -h$host -P$port -uroot -p$root_pass $db < /tmp/table_charset$db$date_time.sql
    mysql -h$host -P$port -uroot -p$root_pass $db </tmp/column_charset$db$date_time.sql
done