/*
    Stored Procedure that can automatically report summary statistics of any arbitrary number of columns
*/ 

-- Create table to hold datatypes that are numeric
DROP TABLE IF EXISTS  public.numerical_datatypes;
CREATE TABLE public.numerical_datatypes(
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

    schema_var      TEXT
)
/* Function that finds all tables for a given scema and returns the average, min, and max values for columns that are numeric */
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
		FOR var_avg IN (SELECT table_schema, column_name, table_name --get schema, column names and table names for relevant tables for numeric data columns
                 FROM information_schema.columns 
                 WHERE (table_name = tab.tablename
				 AND table_schema = 'public' 
				 AND data_type in (SELECT distinct data_type from public.numerical_datatypes))
				 ORDER BY column_name)
		LOOP
			RETURN QUERY EXECUTE
	   		format('SELECT round(avg(cast(%I AS numeric)),2), max(cast(%I AS numeric)), min(cast(%I AS numeric)) FROM %I.%I', var_avg.column_name, var_avg.column_name, var_avg.column_name, var_avg.table_schema, var_avg.table_name);
	   END LOOP;
	END LOOP;
END; $$ 
LANGUAGE plpgsql;

