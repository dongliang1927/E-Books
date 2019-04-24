#!/bin/bash

# example in book:
sqoop import
--connect jdbc:mysql://mysql.example.com/sqoop \
--username sqoop \ 
--password sqoop \ 
--table cities \ 
--target-dir /etl/input/cities \ # 指定文件存储目录,当路径存在时,不能导入
--warehouse-dir /etl/input \ # 指定文件存储的父目录
--where "column1 = 'xxx'" \ # 指定筛选条件,不建议常用
-P \ # 在线输入
--password-file my-sqoop-password \ # 生成密码文件，并导入，保证安全。创建方式： echo "my-secret-password" > sqoop.password; hadoop dfs -put sqoop.password /user/$USER/sqoop.password; hadoop dfs -chown 400 /user/$USER/sqoop.password; rm sqoop.password; sqoop import --password-file /user/$USER/sqoop.password ...
--as-sequencefile \ # 二进制格式传输，利于pdf和图片以及带有分隔符的文本的传输。但需要加载额外的java类包。 该格式是hadoop的文件格式，是mapreduce的定制格式（key:value）
--as-avrodatafile \ # 是通用数据序列化系统，可以存储任何格式的数据。
--compress \ # 压缩文件，默认GZip
--compression-codec org.apache.hadoop.io.compress.BZip2Codec \ # 在各节点安装了的情况下，可以使用其他压缩格式，如BZip2
--direct \ # 通过使用关系型数据库自带的数据传输工具，加快导入速度，如mysqldump和mysqlimput工具（在各个节点安装），目前支持mysql和PostgreSQL
--map-column-java id=Long,name=String,score=Float \ # 强制转换字段类型,用的是java里的字段类型。
--num-mapper 4 \ # 指定mapper的数量，并行化。默认为4个。数据库里的记录条数 > mapper个数
--null-string '\\N' \ # 指定null数据为 \N
--null-non-string '\\N' 

sqoop import-all-tables \ # 导入整个数据库
--connect jdbc:mysql://mysql.example.com/sqoop \
--username sqoop \
--password sqoop \
--exclude-tables xxx,xxx \ # 除了 xxx 表，全部导入
--warehouse-dir 

## 实际应用
server_add="jdbc:oracle:thin:@//db.dm.bionta.com:1521/social"
db_username="dongliang"
db_password="123456"

db_tablename="r_people"
hbase_namespace="sadan3"
hbase_tablename="r_people"
columnfamily="basic"

sqoop import \
-D sqoop.hbase.add.row.key=true \
--connect ${server_add} \
--username ${db_username} \
--password ${db_password} \
--query "select region,sid from ${db_tablename} where $CONDITIONS" \
-m 1 \
--hbase-table ${hbase_namespace}:${hbase_tablename} \
--column-family ${columnfamily} \
--hbase-create-table \
--hbase-row-key REGION,SID

hive -e "CREATE DATABASE IF NOT EXIST ${hbase_namespace};
DROP TABLE IF EXIST ${hbase_namespace}.${hbase_tablename};
CREATE EXTERNAL TABLE ${hbase_namespace}.${hbase_tablename}(HBASE_ROWKEY STRING,SID STRING,REGION STRING)
SORT BY 'org.apache.hadoop.hive.hbase.HBaseStorageHandler'
WITH SERDEPROPERTIES(\"hbase.columns.mapping\"=\":key, ${columnfamily}:SID \")
TBLPROPERTIES(\"hbase.table.name\"=\"${hbase_namespace}:${hbase_tablename}\")"
