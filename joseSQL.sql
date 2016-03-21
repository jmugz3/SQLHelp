
----#### CASCADING REFENTIAL INTEGRITY
--Default (No Action): An error is raised and the DELETE or UPDATE is rolled back. 
--Cascade: All rows containing those foreign keys are also deleted in other tables 
--set NULL: All rows containing those foreign keys are set to NULL in other tables 
--set Default: All rows containing those foreign keys are set to default values
GO

----#### CLEARING CACHE 
--dbcc freeproccache 
--dbcc dropcleanbuffers 
--dbcc freesystemcache('all')
--dbcc cleantable
--dbcc freeproccache
GO

----#### STORED PROCEDURES METADATA INFO
--sp_who 'StoreProcedure'
--sp_columns SP_name
--sp_helptext spName --> to see the code in text 
--sp_help bl_InsertInteraction --> to view name, owner, type and created datetime. 
--sp_depends spName --> view the dependencies of the stored procedure 
--SELECT OBJECT_DEFINITION (OBJECT_ID(N'Prod_App.dbo.co_mst'));
--SELECT * FROM sys.sql_modules WHERE object_id = (OBJECT_ID(N'Prod_App.dbo.co'));
GO

----#### STORED PROCEDURES
---- COMMON STD FOR RETURN
--RETURN 0  --success
--RETURN 1  --failure, or non-zero value
----store result in a different variable and print it

----Optimization 
--SET NOCOUNT ON -- does not display the message with number of rows affected
--SET NOCOUNT OFF
--EXECUTE sp_executesql [yourSP]--instead of EXEC to reuse Execution Plan
GO

----#### TRANSACTIONS
--IF (/*VALIDATE*/) RETURN -1  --fail first
--BEGIN TRANSACTION --Keep it as short as possible
--  BEGIN TRY
--    /* your code */
--    COMMIT TRANSACTION
--    RETURN 0
--  END TRY
--  BEGIN CATCH
--    SELECT ERROR_MESSAGE() AS 'ErrorMessage'
--    ROLLBACK TRANSITION
--    RETURN -2
--    --or rollback when
--    IF @@TRANCOUNT > 0
--      ROLLBACK TRANSITION
--  END CATCH
----or commit at the end
--  IF @@TRANCOUNT > 0
--    COMMIT TRANSACTION
--  GO
GO

----#### DEADLOCKS
----Usually for Error 1205 (Transaction (Process ID %d) was deadlocked on {%Z} resources with another process and has been chosen as the deadlock victim. Rerun the transaction.)
----Use Trace flags 1222 (error info by processes and then resources) and 1204 (error info formatted by each node)
--DBCC TRACEON(1222, -1)
----Look at process-list (spid/worker thread) and resource-list (resources that are owned/locked by participants)
----And find the queries locking the resources.
----Then run the queries using Database Tuning Advisor (DTA)
----Extra : On pagelock, find dbid and associatedObjectId - which is your partitionId
--SELECT DB_NAME(55); --55 is the dbid, it returns database name
--SELECT *
--from sys.dm_os_tasks
--where task_state = 'RUNNING' --IN('SUSPENDED','RUNNING')

--SELECT *
--from sys.sysprocesses
GO



----#### IDENTITY COLUMN
--SET IDENTITY_INSERT tablename ON -- and SQL Server is able to reuse values, but you need to specify which values go on which columns.
----e.g. INSERT INTO table ('column1') VALUES('value1'). If you delete all rows, SQL Server will continue the increment from the last identity value, unless 
--DBCC CHECKIDENT('tablename',RESEED,0) --Restarts count of the identity column 

--Obtaining the last value of the identity column: 
--SELECT SCOPE_IDENTITY() --displays the last generated item in the identity column in the same session within the same scope 
--SELECT @@IDENTITY --global variable that displays the same as SCOPE_IDENTITY() in the same session across any scope 
--SELECT IDENT_CURRENT('tablename') --displays last generated item in the identity column across any session and any scope
GO

----#### AGGREGATION
--SELECT 'nonnumericcolumn', SUM('numericcolumn') AS newcolumnname from table1
--GROUP BY Name, City --Here you put all non-numeric columns that are not using aggregate functions 
--WHERE 'filters before aggregation'; HAVING 'filters after aggregations'
GO

----#### CHECK CONTRAINTS
--ALTER TABLE "tablename" 
--ADD CONSTRAINT "constraint_name" CHECK ("boolean_expression" > TRUE) --if true then the value is accepted; otherwise, no. 
--When passing NULL, the boolean evaluates to UNKNOWN and allows the value 

----Delete the check constraint: 
--ALTER TABLE tablename 
--DROP CONSTRAINT constraint_name 
GO

----#### DROP, ALTER AND CREATE
-- Write scripts so they will not fail 
--IF EXISTS( /*condition */)
--  --TRUE -> ALTER
--  --ELSE -> CREATE
----OR
--IF EXISTS( /*condition */)
--  --TRUE -> DROP IT
--  --ELSE -> CREATE

--DROP, CREATE & ALTER must be in separate batches 
--DROP dbName  --deletes both files (mdf and ldf)
--GO
--CREATE TABLE tableName  --every db has two files tableName.mdf for data
--GO                      --and tableName.ldf for logging transactions
--ALTER TABLE tableName
GO


----#### CHANGE DATATYPE OF COLUMN
--ALTER TABLE tableName
--  ALTER COLUMN columnName newDataType
GO


----#### CHARINDEX
--SELECT * FROM #temp T
--WHERE t.column1 like CHARINDEX(@subSet, @entireSet) > 0
GO

----#### QUERY PARTITION CLAUSE
--SELECT SUM(table.column1) OVER (PARTITION BY table.column2 ORDER BY table.column3) AS
--  'newColumnName'
--  --Reinitializes whener you cross the boundary
GO

----#### SORT THE SET AT LAST STEP
--ORDER BY example:
--SELECT * FROM bigDB
--SELECT col1,col2 INTO [temptable] T FROM BigDB
--DELETE T FROM [temptable] T WHERE col1 < 0
--SELECT col1,col2 FROM [temptable] T ORDER BY col2
GO

----#### DUPLICATE REMOVAL
--SELECT * FROM table1
--INTERSECT --removes duplicates only from result sets. INTERSECT ALL does not.
--SELECT * FROM table2

----identifying duplicates using aggregators
--SELECT col1, col2, count(*)
--FROM t1
--GROUP BY col1, col2
--HAVING count(*) > 1

--SET rowcount 4 --to the number of rows from the previous statement
--DELETE FROM t1 WHERE rowIdentifier=1; --column for PK

----Using column table expression CTE
--WITH cte AS (
--  SELECT col1, col2, row_number() OVER(PARTITION BY col1, col2 ORDER BY col1) AS [newCol]
--  FROM t1
--)
--DELETE cte WHERE [newCol] > 1
GO

----#### NULLs 
--COALESCE(col1,col2,col3) --returns the first non-NULL it finds
--ISNULL(@foo,0) --turns NULLs into 0
GO

----####  JOINS
----SELF JOIN FOR DEPENDENCIES:
--col1 and col3 values means the same
--SELECT t2.col2, t2.col3
--FROM table t1
--LEFT JOIN table t2 ON t1.col1 = t2.col3

---- Multiple Tables in Data Warehousing 
--Use UNION and UNION ALL: Must have identical column names and data types.
--Useful when dealing with history or logs in mutiple tables
--SELECT * FROM table1
--UNION ALL --includes duplicates. UNION does not
--SELECT * FROM table2
GO

----#### CHECK IF DATA EXISTS
--IF EXISTS(SELECT 1 dbo.table)
--  BEGIN
--     --DO SOMETHING
--  END
GO

----#### COUNT ROWS (LARGE INDEX DBS)
--SELECT rows from sysindexes  --row counts for all indexes
--WHERE object_name(id) = 'table' and indexid = 1
GO

----#### EXECUTION PLAN
--USE Database GO
--SET SHOWPLAN_ALL ONGO
---- FMTONLY will not exec stored proc
--SET FMTONLY ON GO
--EXEC [dbo].[SP] param1,param2 GO

--SET FMTONLY OFF GO
--SET SHOWPLAN_ALL OFF GO
GO

----#### DEBUGGING (SYNTAX ONLY)
--SET NOEXEC ON
----Statements to debug INSERTO INTO Table.. etc.
--SET NOEXEC OFF
--GO
GO

----#### GOTO (FOR ERRORS ONLY)
--IF 'ERROR' GOTO ERROR_LABEL
--ERROR_LABEL:
--  /* Statement */
--  RETURN -1
GO



----#### CODING STDS FROM THE WEB 
--Avoid using cursors, but if you must use them, use temp tables to improve performance
--Stay away from nesting Views
--Use Table-Valued functions. Convert scalar functions to a Table-Valued function using CROSS APPLY
--Partition when moving data. All tables in SQL are partitioned, so you can use SWITCH to archive data from a warehousing load. It enhances concurrency.
--Favor Store Procedures over ORMs and take advantage of reusing Execution Plans, which means less data traffic over networks
--Split up large transactions to prevent blocking and/or (NOLOCK)
--Use Triggers only for Simple Auditing; otherwise, use a Store Procedure
--Avoid clustering on GUIDs and ordering using volatile columns. Use DATE or IDENTITY instead. Maybe sequential GUIDs
--use SELECT 1 to check for data
--use SELECT .. CASE WHEN [condition] ELSE .. END INTO [temptable] instead of UPDATE. UPDATE statement writes twice (the actual write, and the log) for any single write to a table
--Trim the code (less JOINS, WHERE, etc)
--ONLY use SELECT * when needed; otherwise, select the columns needed
--Avoid Double-Dipping. Keep it Simple
--If feasible, pre-stage data for performance
GO