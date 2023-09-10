
--Reading in sample datasets
--creating two versions of same table just to have multiple tables
DROP TABLE IF EXISTS test_table;
CREATE TABLE test_table
(service_week varchar(50), service_year integer, service_yearmonth date, 
service_date varchar(50), betos_cd VARCHAR(50), betos_desc VARCHAR(500),pos_cd integer,pos_desc VARCHAR(50),spec_cd integer,
 spec_desc VARCHAR(500), paid_amount money, utilization integer);
COPY test_table FROM 'C:\Users\Public\lab_data.csv' DELIMITER ',' CSV HEADER;

--adding in marketing campaign dataset I found on kaggle just to try on more data
DROP TABLE IF EXISTS  marketing_campaign;
CREATE TABLE marketing_campaign 
(ID_mark integer, Year_Birth integer, Education VARCHAR(100), 
marital_status varchar(100), income integer, KidHome integer, teenHome integer,DT_customer VARCHAR(100),
Recency integer, MntWines integer,MntFruits integer, MntMeatProducts integer, MntFishProducts integer, MntSweetProducts integer,	
 MntGoldProds integer, NumDealsPurchases integer, NumWebPurchases integer, NumCatalogPurchases integer, NumStorePurchases integer, NumWebVisitsMonth integer,
 AcceptedCmp3 integer, AcceptedCmp4 integer, AcceptedCmp5 integer, AcceptedCmp1 integer, AcceptedCmp2 integer, Complain integer, 
 Z_CostContact integer, Z_Revenue integer, Response integer);
COPY marketing_campaign FROM 'C:\Users\Public\marketing_campaign.csv' DELIMITER E'\t' CSV HEADER;

--inserting some nulls since this dataset did not have any 
INSERT INTO marketing_campaign(ID_mark, Year_Birth, Education, Marital_Status, Income, Kidhome, Teenhome, Dt_Customer, Recency, MntWines, MntFruits,
							   MntMeatProducts, MntFishProducts,MntSweetProducts, MntGoldProds, NumDealsPurchases, NumWebPurchases,
							   NumCatalogPurchases,NumStorePurchases,NumWebVisitsMonth, AcceptedCmp3, AcceptedCmp4,AcceptedCmp5,
							   AcceptedCmp1,AcceptedCmp2, Complain,Z_CostContact,Z_Revenue,Response)
VALUES(30245, NULL, 'Graduation', 'Single' ,58138, 0, 0, '04-09-2012', 58, 635, 4, 546, NULL, 88,88,3,8,NULL,4,7,0,0,0,NULL,0,0,NULL,11,1);
INSERT INTO marketing_campaign(ID_mark, Year_Birth, Education, Marital_Status, Income, Kidhome, Teenhome, Dt_Customer, Recency, MntWines, MntFruits,
							   MntMeatProducts, MntFishProducts,MntSweetProducts, MntGoldProds, NumDealsPurchases, NumWebPurchases,
							   NumCatalogPurchases,NumStorePurchases,NumWebVisitsMonth, AcceptedCmp3, AcceptedCmp4,AcceptedCmp5,
							   AcceptedCmp1,AcceptedCmp2, Complain,Z_CostContact,Z_Revenue,Response)
VALUES(3045, NULL, NULL, 'Single' ,58138, 0, NULL, '04-09-2012', 58, 635, 4, 546, 55, 88, 88, NULL, 8, 5,4,7,0,0,0,NULL,0,0,3,11,1);

DROP TABLE IF EXISTS  test_table_2;
CREATE TABLE test_table_2 
(service_week varchar(50), service_year integer, service_yearmonth date, 
service_date varchar(50), betos_cd VARCHAR(50), betos_desc VARCHAR(500),pos_cd integer,pos_desc VARCHAR(50),spec_cd integer,
 spec_desc VARCHAR(500), paid_amount money, utilization integer);
COPY test_table_2 FROM 'C:\Users\Public\lab_data.csv' DELIMITER ',' CSV HEADER;

-------------------------------------------------------------------------------------------------------------------
/*practice with information schema and dynamic sql*/
--from the information schema, select all tables we want to analyze

--table to store all table names we may want
DROP TABLE IF EXISTS table_names;
CREATE TABLE table_names(
	tbl varchar(50)
);
INSERT INTO table_names
SELECT tablename
        FROM pg_tables
        WHERE schemaname = 'public'
        ORDER BY tablename;
--we can see all table names in the database of a particular table schema
SELECT * FROM table_names;

--first function just returns all values from the table e.g. hello world of dynamic sql
CREATE OR REPLACE FUNCTION test_func(_tbl anyelement)
  RETURNS SETOF anyelement AS
$func$
BEGIN
	RETURN QUERY EXECUTE 'SELECT * FROM ' || pg_typeof(_tbl); --pg_typeof gets the data type of any value
END
$func$  LANGUAGE plpgsql;

--first function just selects all rows from a given table name
SELECT * FROM test_func(NULL::test_table);
-----------------------------------------------------------------------------------------------------------
--create tables to use to summarize data
--Creating a table to store summary statistics
DROP TABLE IF EXISTS  summary_stats;
CREATE TABLE summary_stats(
	id serial,
	stats varchar(100)
);
--table to hold percentiles
DROP TABLE IF EXISTS  percentiles_stats;
CREATE TABLE percentiles_stats(
	id serial,
	percentiles varchar(200)
);

--Creating a table to hold missing value information for numeric data
DROP TABLE IF EXISTS  missing_values;
CREATE TABLE missing_values(
	id serial,
	missing_vals bigint
);

--Creating a table to store column names of numeric variables
DROP TABLE IF EXISTS  table_column_names;
CREATE TABLE table_column_names(
	id serial,
	table_name varchar(100),
	column_name varchar(100));

--table to hold all numeric summary information
DROP TABLE IF EXISTS  numeric_summary_table;
CREATE TABLE numeric_summary_table(
	tablename VARCHAR(100),
	columnname VARCHAR(100),
	missingvalues bigint,
	average numeric,
	maximum numeric,
	minimum numeric,
	quartileone numeric,
	median numeric,
	quartilethree numeric,
	ninetyninthperc numeric);

--table for categorical column names
DROP TABLE IF EXISTS table_categorical_column_names;
CREATE TABLE table_categorical_column_names(
	id serial,
	table_name varchar(100),
	column_name varchar(100));

--table for categorical missing values
DROP TABLE IF EXISTS  categorical_missing;
CREATE TABLE categorical_missing(
	id serial,
	MissingValues bigint);

--table to count number of distinct values for categorical values
DROP TABLE IF EXISTS  categorical_distinct;
CREATE TABLE categorical_distinct(
	id serial,
	countdistinct bigint);

--table to summarize categorical data
DROP TABLE IF EXISTS  categorical_summary;
CREATE TABLE categorical_summary(
	tablename VARCHAR(100),
	columnname VARCHAR(100),
	distinctcount bigint,
	MissingValues bigint);

------------------------------------------------------------------------------------------------------
/*Functions to get numeric statistics on all tables, no parameters for functions just using to do dynamic sql*/
--get numeric summary statistics for all tables
CREATE OR REPLACE FUNCTION print_numeric_all() 
/*Function that finds all tables in public scema and returns the average, min, and max values for columns that are numeric*/
  RETURNS TABLE(avg_val numeric, max_val numeric, min_val numeric) 
AS 
$$
DECLARE 
    var_avg record; --record to information from information_schema
	tab record; --record to store table names of tables to analyze
BEGIN
	FOR tab in (SELECT tablename --get table names where schema is public
        FROM pg_tables
        WHERE schemaname = 'public'
        ORDER BY tablename)
	LOOP
		FOR var_avg IN (SELECT table_schema, column_name, table_name --get scema, column names and table names for relevant tables for numeric data columns
                 FROM information_schema.columns 
                 WHERE (table_name = tab.tablename
				 AND table_schema = 'public' 
				 AND table_name not in ('summary_stats', 'missing_values', 'table_column_names', 'percentiles_stats',
											 'numeric_summary_table', 'table_categorical_column_names', 'categorical_summary', 'categorical_distinct', 'categorical_missing', 'table_names')
				 AND data_type in 
						('smallint', 'integer', 'bigint', 'decimal', 'numeric', 'real', 'double precision', 'smallserial', 'serial', 'bigserial', 'money'))	
				 ORDER BY column_name)
		LOOP
			RETURN QUERY EXECUTE
	   		format('SELECT round(avg(cast(%I AS numeric)),2), max(cast(%I AS numeric)), min(cast(%I AS numeric)) FROM %I.%I',var_avg.column_name,var_avg.column_name,var_avg.column_name, var_avg.table_schema, var_avg.table_name);
	   END LOOP;
	END LOOP;
END; $$ 
LANGUAGE plpgsql;
--select print_numeric_all()


CREATE OR REPLACE FUNCTION missing_val_count() 
/*Function that finds all tables in public scema and returns the count of missing values for a particular attribute*/
  RETURNS TABLE(cnt bigint) 
AS 
$$
DECLARE 
    na_count record;
	tab record;
BEGIN
	FOR tab in (SELECT tablename
        FROM pg_tables
        WHERE schemaname = 'public'
        ORDER BY tablename)
	LOOP
		FOR na_count IN (SELECT table_schema, column_name, table_name
                 FROM information_schema.columns 
                 WHERE (table_name = tab.tablename
				 AND table_schema = 'public' 
				 AND table_name not in ('summary_stats', 'missing_values', 'table_column_names', 'percentiles_stats',
											 'numeric_summary_table', 'table_categorical_column_names', 'categorical_summary', 'categorical_distinct', 'categorical_missing','table_names')  
				 AND data_type in 
						('smallint','integer', 'bigint', 'decimal', 'numeric', 'real', 'double precision', 'smallserial', 'serial', 'bigserial', 'money'))	
				 ORDER BY column_name)
		LOOP
			RETURN QUERY EXECUTE
	   		format('SELECT COUNT(*) FROM %I.%I WHERE %I IS NULL', na_count.table_schema, na_count.table_name, na_count.column_name);
	   END LOOP;
	END LOOP;
END; $$ 
LANGUAGE plpgsql;

--get percentile statistics for all tables
CREATE OR REPLACE FUNCTION get_percentiles() 
/*Function that finds all tables in public scema and returns 25th, median, 75th and 99th percentiles*/
  RETURNS TABLE(quartile_one numeric, med numeric, quartile_three numeric, nine_nine numeric) 
AS 
$$
DECLARE 
    perc_records record;
	tab record;
BEGIN
	FOR tab in (SELECT tablename
        FROM pg_tables
        WHERE schemaname = 'public'
        ORDER BY tablename)
	LOOP
		FOR perc_records IN (SELECT table_schema, column_name, table_name
                 FROM information_schema.columns 
                 WHERE (table_name = tab.tablename
				 AND table_schema = 'public' 
				 AND table_name not in ('summary_stats','missing_values','table_column_names','percentiles_stats',
											 'numeric_summary_table','table_categorical_column_names','categorical_summary','categorical_distinct','categorical_missing','table_names')  
				 AND data_type in 
						('smallint','integer', 'bigint', 'decimal', 'numeric', 'real','double precision', 'smallserial','serial','bigserial', 'money'))	
				 ORDER BY column_name)
		LOOP
			RETURN QUERY EXECUTE
			format('select percentile_disc (0.25)  within group (order by cast(%I AS numeric)),
					percentile_disc (0.5)  within group (order by cast(%I AS numeric)),
					percentile_disc (0.75) within group (order by cast(%I AS numeric)),
					percentile_disc (0.99) within group (order by cast(%I AS numeric))
					from %I.%I', perc_records.column_name, perc_records.column_name, perc_records.column_name, perc_records.column_name, perc_records.table_schema, perc_records.table_name);
	   END LOOP;
	END LOOP;
END; $$ 
LANGUAGE plpgsql;
----------------------------------------------------------------------------------------------------------------------------------
/*Creating tables to store relevant information then join together*/

--Using function created earlier, insert numeric summary statistics into summary_stats table
INSERT INTO summary_stats(stats) select print_numeric_all();

--using function created earlier, insert count of missing values into missing values table
INSERT INTO missing_values(missing_vals) select missing_val_count();

--using function created earlier, insert count of missing values into missing values table
INSERT INTO percentiles_stats(percentiles) select get_percentiles();

--Insert numeric column names into table
INSERT INTO table_column_names(table_name, column_name) 
SELECT table_name,column_name from information_schema.columns
				WHERE table_name in (SELECT tablename
        		FROM pg_tables
				WHERE (table_schema = 'public' 
					   AND table_name not in ('summary_stats', 'missing_values', 'table_column_names', 'percentiles_stats',
											 'numeric_summary_table', 'table_categorical_column_names', 'categorical_summary', 'categorical_distinct', 'categorical_missing', 'table_names')  
					   AND data_type in 
						('smallint','integer', 'bigint','decimal','numeric','real','double precision', 'smallserial','serial','bigserial', 'money')))
				ORDER BY table_name, column_name;					 
									 
--Inner join the two tables, format summary stats to split columns on commas and remove parenthesis

INSERT INTO numeric_summary_table 
SELECT table_name as tableName, column_name as columnName, missing_vals as MissingValues, 
	   cast(split_part(right(stats,-1), ',', 1) as NUMERIC) AS Average,
       cast(split_part(stats, ',', 2) as NUMERIC) AS Maximum,
       cast(split_part(left(stats,-1), ',', 3) as NUMERIC) AS Minimum,
	   
	   cast(split_part(right(percentiles,-1), ',', 1) as NUMERIC) AS quartileOne,
       cast(split_part(percentiles, ',', 2) as NUMERIC) AS Median,
       cast(split_part(percentiles, ',', 3) as NUMERIC) AS quartileThree,
	   cast(split_part(left(percentiles,-1), ',', 4) as NUMERIC) AS NinetyNinthPerc

	   FROM table_column_names
	   INNER JOIN summary_stats on summary_stats.id = table_column_names.id
	   INNER JOIN missing_values on missing_values.id = table_column_names.id
	   INNER JOIN percentiles_stats on percentiles_stats.id = table_column_names.id;

--------------------------------------------------------------------------------------------------------


--categorical get distinct count and missing values

CREATE OR REPLACE FUNCTION categorical_missing_summary() 
/*Function that finds all tables in public scema and returns the count of missing values for a particular attribute*/
  RETURNS TABLE(count_missing bigint) 
AS 
$$
DECLARE 
    na_count record;
	tab record;
BEGIN
	FOR tab in (SELECT tablename
        FROM pg_tables
        WHERE schemaname = 'public'
        ORDER BY tablename)
	LOOP
		FOR na_count IN (SELECT table_schema, column_name, table_name
                 FROM information_schema.columns 
                 WHERE (table_name = tab.tablename
				 AND table_schema = 'public' 
				 AND table_name not in ('summary_stats','missing_values','table_column_names','percentiles_stats',
											 'numeric_summary_table','table_categorical_column_names','categorical_summary','categorical_distinct','categorical_missing','table_names') 
				 AND data_type in 
						('character','character varying', 'date'))	
				 ORDER BY column_name)
		LOOP
			RETURN QUERY EXECUTE
	   		format('SELECT COUNT(*) FROM %I.%I WHERE %I IS NULL',na_count.table_schema, na_count.table_name,na_count.column_name);
	   END LOOP;
	END LOOP;
END; $$ 
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION distinct_count_categorical() 
/*Function that finds all tables in public scema and returns the count of missing values for a particular attribute*/
  RETURNS TABLE(distinct_count bigint) 
AS 
$$
DECLARE 
    dist record;
	tab record;
BEGIN
	FOR tab in (SELECT tablename
        FROM pg_tables
        WHERE schemaname = 'public'
        ORDER BY tablename)
	LOOP
		FOR dist IN (SELECT table_schema, column_name, table_name
                 FROM information_schema.columns 
                 WHERE (table_name = tab.tablename
				 AND table_schema = 'public' 
				 AND table_name not in ('summary_stats','missing_values','table_column_names','percentiles_stats',
											 'numeric_summary_table','table_categorical_column_names','categorical_summary','categorical_distinct','categorical_missing','table_names')  
				 AND data_type in 
						('character','character varying', 'date'))	
				 ORDER BY column_name)
		LOOP
			RETURN QUERY EXECUTE
	   		format('SELECT COUNT(DISTINCT %I) FROM %I.%I',dist.column_name,dist.table_schema, dist.table_name);
	   END LOOP;
	END LOOP;
END; $$ 
LANGUAGE plpgsql;


INSERT INTO table_categorical_column_names(table_name, column_name) 
SELECT table_name,column_name from information_schema.columns
				WHERE table_name in (SELECT tablename
        		FROM pg_tables
				WHERE (table_schema = 'public' AND data_type in 
						('character','character varying', 'date')
				AND table_name not in ('summary_stats','missing_values','table_column_names','percentiles_stats',
											 'numeric_summary_table','table_categorical_column_names','categorical_summary','categorical_distinct','categorical_missing', 'table_names')))
				ORDER BY table_name, column_name;		

INSERT INTO categorical_distinct(countdistinct) select distinct_count_categorical();
INSERT INTO categorical_missing(MissingValues) select categorical_missing_summary();

INSERT INTO categorical_summary 
SELECT table_name as tableName, column_name as columnName, countdistinct, MissingValues
		
	   FROM table_categorical_column_names
	   INNER JOIN categorical_distinct on categorical_distinct.id = table_categorical_column_names.id
	   INNER JOIN categorical_missing on categorical_missing.id = table_categorical_column_names.id;

SELECT * FROM numeric_summary_table;
SELECT * FROM categorical_summary;

SELECT * FROM summary_stats