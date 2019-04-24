#!/bin/bash

## 4.1 import data from two tables, use --query parameters
sqoop import \
	--connect jdbc:mysql://mysql.example.com/sqoop \
	--username sqoop \
	--password sqoop \
	--query 'SELECT normcities.id, \
									countries.county, \
									normcities.city \
									FROM normcities \
									JOIN countries USING(country_id) \
									WHERE $CONDITIONS' \ # use $CONDITIONS after WHERE will force sqoop to use parallel(split your query into chunks for transfering)
	--split-by id \ # this column will be used for splitting the data into pieces, and parallel. if not set the default will use the primary key.
	--target-dir cities # cannot use --warehouse-dir

## 4.2 using custom boundary queries
## it's time expensive for sqoop to check the min-max of the parameter in --split-by, then use the --boundary-query
sqoop import \
	--connect jdbc:mysql://mysql.example.com/sqoop \
	--username sqoop \
	--password sqoop \
	--query 'SELECT normcities.id, \
									countries.county, \
									normcities.city \
									FROM normcities \
									JOIN countries USING(country_id) \
									WHERE $CONDITIONS' \ 
	--split-by id \
	--split-by id \ 
	--boundary-query "select min(id),max(id) from normcities" # because we use the --query rather than --table(which will detect the min,max autoly, and split data into pieces for parallel), this parameter will help for that.

## 4.3 renaming sqoop job instances
## �������е�mapreduce'job��������Ϊ QueryResult.jar����˺��������Ǹ�job�����ĸ�import���
sqoop import \
	--connect jdbc:mysql://mysql.example.com/sqoop \
	--username sqoop \
	--password sqoop \
	--query 'SELECT normcities.id, \
									countries.county, \
									normcities.city \
									FROM normcities \
									JOIN countries USING(country_id) \
									WHERE $CONDITIONS' \ 
	--split-by id \
	--split-by id \ 
	--boundary-query "select min(id),max(id) from normcities"
	--mapreduce-job-name normcities

## 4.4 importing queries with duplicated columns
## ��ͬ�������ǲ�������ģ�����Ҫʹ�� SQL����е� as ������

