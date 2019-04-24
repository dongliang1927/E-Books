#!/bin/bash

# example in book:
sqoop import
--connect jdbc:mysql://mysql.example.com/sqoop \
--username sqoop \ 
--password sqoop \ 
--table cities \ 
--target-dir /etl/input/cities \ # ָ���ļ��洢Ŀ¼,��·������ʱ,���ܵ���
--warehouse-dir /etl/input \ # ָ���ļ��洢�ĸ�Ŀ¼
--where "column1 = 'xxx'" \ # ָ��ɸѡ����,�����鳣��
-P \ # ��������
--password-file my-sqoop-password \ # ���������ļ��������룬��֤��ȫ��������ʽ�� echo "my-secret-password" > sqoop.password; hadoop dfs -put sqoop.password /user/$USER/sqoop.password; hadoop dfs -chown 400 /user/$USER/sqoop.password; rm sqoop.password; sqoop import --password-file /user/$USER/sqoop.password ...
--as-sequencefile \ # �����Ƹ�ʽ���䣬����pdf��ͼƬ�Լ����зָ������ı��Ĵ��䡣����Ҫ���ض����java����� �ø�ʽ��hadoop���ļ���ʽ����mapreduce�Ķ��Ƹ�ʽ��key:value��
--as-avrodatafile \ # ��ͨ���������л�ϵͳ�����Դ洢�κθ�ʽ�����ݡ�
--compress \ # ѹ���ļ���Ĭ��GZip
--compression-codec org.apache.hadoop.io.compress.BZip2Codec \ # �ڸ��ڵ㰲װ�˵�����£�����ʹ������ѹ����ʽ����BZip2
--direct \ # ͨ��ʹ�ù�ϵ�����ݿ��Դ������ݴ��乤�ߣ��ӿ쵼���ٶȣ���mysqldump��mysqlimput���ߣ��ڸ����ڵ㰲װ����Ŀǰ֧��mysql��PostgreSQL
--map-column-java id=Long,name=String,score=Float \ # ǿ��ת���ֶ�����,�õ���java����ֶ����͡�
--num-mapper 4 \ # ָ��mapper�����������л���Ĭ��Ϊ4�������ݿ���ļ�¼���� > mapper����
--null-string '\\N' \ # ָ��null����Ϊ \N
--null-non-string '\\N' 

sqoop import-all-tables \ # �����������ݿ�
--connect jdbc:mysql://mysql.example.com/sqoop \
--username sqoop \
--password sqoop \
--exclude-tables xxx,xxx \ # ���� xxx ��ȫ������
--warehouse-dir 

## ʵ��Ӧ��
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
