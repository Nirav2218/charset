read -p "give root password for mysql --------> " root_pass
host=localhost
port=3306
date_time=$(date -Iseconds)

db_arr=( helpdesk helpdesk_admin )

for db in ${db_arr[@]} ; do
    out_file=/tmp/table_charset$db$date_time.sql
    out_file2=/tmp/table_charset$db$date_time.sql

    query1="SELECT CONCAT('ALTER TABLE ', TABLE_SCHEMA, '.', TABLE_NAME, ' CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;') AS query 
FROM information_schema.TABLES 
WHERE TABLE_SCHEMA = '$db' AND TABLE_COLLATION != 'utf8mb4_general_ci' ;"
    query2="SELECT CONCAT('ALTER TABLE ', TABLE_SCHEMA, '.', TABLE_NAME, ' MODIFY ', COLUMN_NAME, ' ', COLUMN_TYPE, ' CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;') AS query 
FROM information_schema.COLUMNS 
WHERE TABLE_SCHEMA = '$db' AND COLLATION_NAME != 'utf8mb4_general_ci' AND COLLATION_NAME IS NOT NULL;"
    
    mysql -h "$host" -P "$port" -N -uroot -p"$root_pass" --execute "$query1" > "$out_file"

    mysql -h "$host" -P "$port" -N -uroot -p"$root_pass" --execute "$query2" > "$out_file2"

    mysql -h "$host" -P "$port" -uroot -p"$root_pass" "$db" < "$out_file"

    mysql -h "$host" -P "$port" -uroot -p"$root_pass" "$db" < "$out_file2"

done