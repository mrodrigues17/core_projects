/*
    Stored Procedure that can automatically report summary statistics of any arbitrary number of columns
*/ 

DROP PROCEDURE IF EXISTS data_profiler;

CREATE PROCEDURE        data_profiler (

    table_name          TEXT            -- pass in the name of the table

)
