#!/bin/bash

## 6.1 scheduling sqoop jobs with oozie
## using oozie in your environment to schedule hadoop jobs and call sqoop from within your existing workflows
<workflow-app name="sqoop-workflow" xmlns="uri:oozie:wrokflow:0.1">
	...
		<action name="sqoop-acton">
			<sqoop xmlns="uri:oozie:sqoop-action:0.2">
				<job-tracker>foo:8021</job-tracker>
				<name-node>bar:8020</name-node>
				<arg>import</arg>
				<arg>--table</arg>
				<arg>cities</arg>
				<arg>--username</arg>
				<arg>sqoop</arg>
				<arg>--password</arg>
				<arg>sqoop</arg>
				...
			</sqoop>
			<ok to='next'/>
			<error to='error'/>
		</action>
	...
</workflow-app>

## 6.2 specifying commands in oozie
## in shell bash command you need "or' after parameter  and \x for ת���ַ�, but in oozie command, you need not, for example:
# in shell bash command
sqoop import --password "spEci#l\$" --connect "jdbc:x:/yyy;db=sqoop"
# in oozie command
<command>sqoop import --password spEci@l$ --connect jdbc:x:/yyy;db=sqoop pass:[<phrase role='keep-together'></command></phrase>]

## 6.3 using property parameters in oozie
## PROBLEM:oozie might ignore sqoop parameter when entered with -D, for example -Dsqoop.export.statements.per.transaction=1.
## SOLUTION: with configuration section within sqoop action
<workflow-app name="sqoop-workflow" xmlns="uri:oozie:workflow:0.1">
	...
		<action name="sqoop-action">
			<sqoop xmlns="uri:oozie:sqoop-action:0.2">
				<job-tracker>foo:8021</job-tracker>
				<name-node>bar:8020</name-node>
				<configuration>
					<property>
						<name>sqoop.export.statements.per.transaction</name>
						<value>1</value>
					</property>
				</configuration>
				<command>import --table cities --connect ...</command>
			</sqoop>
			<ok to='next'/>
			<error to="error"/>
		</action>
	...
<workflow-app>

			
## 6.4 installing JDBC drivers in oozie
## Problem: can execute from command line, but cannot find JDBC driver in oozie
## Solution: need install the JDBC drivers into Oozie separately. install either into your workflow's lib/ dir or into the shared action library location usually found at /user/oozie/share/lib/sqoop/
## you can download the drivers from the applicable vendors's website, copying the jar files into the lib/ dir.

## 6.5 importing data directly into hive
## --hive-import
sqoop import \
 --connect jdbc:mysql://mysql.example.com:/sqoop \
 --username sqoop \
 --password sqoop \
 --table cities \
 --hive-import \ # this for import data into hive
 --map-column-hive id=STRING,price=DECIMAL \ # this for specified datatype for column
 --target-dir xxx \
 --warehouse-dir xxx \
 --hive-overwrite # if you want overwrite a exist hive table, use this, or it will append to a exist hive table

## 6.6 using partitioned hive tables
sqoop import \
	--connect jdbc:mysql://mysql.example.com/sqoop \
	--username sqoop \
	--password sqoop \
	--table cities \
	--hive-import \
	--hive-partition-key day \
	--hive-partition-value "2013-05-22"

## 6.7 replacing special delimiters during hive import
## �������������д��� hive ��Ϊ�ķָ�������\n,\t��\01����ôʹ��--hive-drop-import-delims �� --hive-delims-replacement���޳������ ����ָ�����
## ֵ��ע����ǣ���Ȼ��������hive�������ǲ����޶��� --hive-import֮����������Ҳ���á�
sqoop import \
	--connect jdbc:mysql://mysql.example.com/sqoop \
	--username sqoop \
	--password sqoop \
	--table cities \
	--hive-import \
	--hive-drop-import-delims
	
sqoop import \
	--connect jdbc:mysql://mysql.example.com/sqoop \
	--username sqoop \
	--password sqoop \
	--table cities \
	--hive-import \
	--hive-delims-replacement "special"

## 6.8 using the correct NULL string in hive
## Problem: the imported data in some column have correct NULL, but some just have character "NULL"
## Solution:--null-string '\\N' and --null-non-string '\\N'
sqoop import \
	--connect jdbc:mysql://mysql.example.com/sqoop \
	--username sqoop \
	--password sqoop \
	--table cities \
	--hive-import \
	--null-string '\\N' \
	--null-non-string '\\N'

## 6.9 import data into hbase
sqoop import \
	--connect jdbc:mysql://mysql.example.com/sqoop \
	--username sqoop \
	--password sqoop \
	--table cities \
	--hbase-table cities \ 
	--column-family world \ # ������ 
	--hbase-row-key col1,col2,.. # ָ��rowkey����ʽ�� ����Ĭ��Ϊ ���� �� --split-byָ������
	
## 6.10 import all rows into hbase
## Problem: if a row with all column is null, the sqoop will skip this row, result in there are fewer rows than source database
sqoop import \
	-Dsqoop.hbase.add.row.key=true \ # ������ column ����nullʱ����ת
	--connect jdbc:mysql://mysql.example.com/sqoop \
	--username sqoop \
	--password sqoop \
	--table cities \
	--hbase-table cities \ 
	--column-family world \ 

## 6.11 improving performance when importing into hbase
## Problem: it is slow than import into HDFS with text files
## Solution: create hbase table prior and create more regions with the column family, hbase shell:
hbase> create 'cities', 'world', {NUMREGIONS=>20, SPLITALGO=>'HexString Split'} #ÿ��hbaseĬ����һ��region��������ֻ�ܱ�һ���ڵ�ʹ�ã�ָ�����region��sqoop���Ը��õ�����Hbase cluster