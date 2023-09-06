SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Description:	Healthcheck: Databases using downgraded compatibility mode
--
-- Parameters:
--
-- Log History:	
--              2019-04-29 RAG  - Changed the comparison between compat levels and not to version     
--                              - Added order by [name]
--              2020-08-03 BE   - Added T-SQL code generation
--
-- =============================================

DECLARE @compatibility TINYINT SET @compatibility = (SELECT compatibility_level FROM sys.databases WHERE database_id = 1)
DECLARE @version NVARCHAR(128) SET @version = CONVERT(NVARCHAR(128),SERVERPROPERTY('ProductVersion'))


SELECT name
        , compatibility_level
        , @compatibility AS max_compatibility_level
        , @version AS server_version 
        , CASE WHEN compatibility_level < @compatibility THEN 'Use Downgraded Compatibility Level'
            ELSE 'Compatibility Level matches the Product Version'
            END AS compatibility_level_status
		, 'ALTER DATABASE ' + QUOTENAME(name) + ' SET COMPATIBILITY_LEVEL = ' + CONVERT(VARCHAR(10),@compatibility) + ';' AS [T-SQL]
    FROM sys.databases
    WHERE compatibility_level < @compatibility
        AND state_desc = 'ONLINE'
    ORDER BY name
GO
