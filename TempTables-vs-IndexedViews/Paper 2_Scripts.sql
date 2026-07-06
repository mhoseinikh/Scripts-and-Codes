--tempdb capacity planning
USE tempdb;
GO

SELECT  session_id,
        user_objects_alloc_page_count,
        user_objects_dealloc_page_count,
        internal_objects_alloc_page_count,
        internal_objects_dealloc_page_count
    FROM sys.dm_db_session_space_usage
    WHERE session_id > 50
    ORDER BY user_objects_alloc_page_count DESC;


--Index and statistics maintenance
SELECT  OBJECT_SCHEMA_NAME(i.object_id) AS SchemaName,
        OBJECT_NAME(i.object_id) AS ObjectName, i.name AS IndexName, 
        us.user_seeks, us.user_scans,us.user_lookups, 
        us.user_updates, us.last_user_seek, us.last_user_update
    FROM sys.indexes AS i
        LEFT JOIN sys.dm_db_index_usage_stats AS us
            ON us.database_id = DB_ID()
                AND us.object_id = i.object_id AND us.index_id = i.index_id
    WHERE i.object_id = OBJECT_ID(N'Sales.vDailyProductRevenue');
