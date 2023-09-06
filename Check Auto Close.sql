SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Description:	Healthcheck: Check for databases with auto close enabled.
--
-- Parameters:
--
-- Log History:	
--
-- =============================================

SELECT '-' AS name, '-' AS is_auto_close_on, '-- EXECUTE AS SQLCMD' AS change_autoclose
UNION ALL

SELECT name
        , CASE WHEN is_auto_close_on = 1 THEN 'Yes'
            ELSE 'No'
            END AS is_auto_close_on 
		, ':CONNECT ' + @@SERVERNAME + CHAR(10) 
			+ 'ALTER DATABASE ' + QUOTENAME(name) + ' SET AUTO_CLOSE OFF'
			+ CHAR(10) + 'GO'
    FROM sys.databases
    WHERE is_auto_close_on = 1
    ORDER BY name
GO
