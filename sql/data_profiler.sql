/*
    Stored Procedure that can automatically report summary statistics of any arbitrary number of columns
*/ 

-- Create table to hold datatypes that are numeric
DROP TABLE IF EXISTS    public.numerical_datatypes;
CREATE TABLE            public.numerical_datatypes(
    data_type           TEXT
);

INSERT INTO public.numerical_datatypes (data_type)
VALUES
     ('smallint'   )
    ,('integer'    )
    ,('bigint'     )
    ,('decimal'    )
    ,('numeric'    )
    ,('real'       )
    ,('double'     )
    ,('precision'  )
    ,('smallserial')
    ,('serial'     )
    ,('bigserial'  )
    ,('money'      );

DROP FUNCTION IF EXISTS print_numeric_summary;
CREATE FUNCTION print_numeric_summary (

    schema_var      TEXT    -- specify the schema we want 
)
/* 
    Function that finds all tables for a given schema and returns the average, min, and max values for columns that are numeric
*/
  RETURNS TABLE(avg_val numeric, max_val numeric, min_val numeric) 
AS 
$$
DECLARE 
    var_avg record; --record to information from information_schema
	tab record;     --record to store table names of tables to analyze
BEGIN
	FOR tab in (SELECT tablename --get table names where schema is public
                FROM pg_tables
                WHERE schemaname = schema_var
                ORDER BY tablename)
	LOOP
		FOR var_avg IN (
                SELECT 
                     table_schema
                    ,column_name
                    ,table_name --get schema, column names and table names for relevant tables for numeric data columns
                 FROM 
                    information_schema.columns
                 WHERE (table_name   = tab.tablename
				 AND    table_schema = schema_var
				 AND    data_type IN (SELECT distinct data_type FROM public.numerical_datatypes)) -- specify we only want numeric data
				 ORDER BY column_name)
		LOOP
			RETURN QUERY EXECUTE
	   		format('SELECT 
                 ROUND(AVG(CAST(%I AS numeric)), 2)
                ,MAX(CAST(%I AS numeric))
                ,MIN(CAST(%I AS numeric))
                FROM %I.%I'
                
                ,var_avg.column_name
                ,var_avg.column_name
                ,var_avg.column_name
                ,var_avg.table_schema
                ,var_avg.table_name);
	   END LOOP;
	END LOOP;
END; $$ 
LANGUAGE plpgsql;

-- TODO determine how we can include information about the column in the query above (ideally the table too)
SELECT max(paid_amount) FROM test_table
select print_numeric_summary('public')

WITH cte AS (
                SELECT 
                     table_schema
                    ,column_name
                    ,table_name --get schema, column names and table names for relevant tables for numeric data columns
                 FROM 
                    information_schema.columns
                 WHERE (table_name   = 'test_table'
				 AND    table_schema = 'public'
				 AND    data_type IN (SELECT distinct data_type FROM public.numerical_datatypes)) -- specify we only want numeric data
				 ORDER BY column_name
)
SELECT 
                 ROUND(AVG(CAST(column_name AS numeric)), 2)
                ,MAX(CAST(column_name AS numeric))
                ,MIN(CAST(column_name AS numeric))
                FROM cte

SELECT 
                 ROUND(AVG(CAST(paid_amount AS numeric)), 2)
                ,MAX(CAST(paid_amount AS numeric))
                ,MIN(CAST(paid_amount AS numeric))
                ,%I
                FROM %I.%I
                GROUP BY
                %I'