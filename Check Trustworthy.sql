SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Description:	Healthcheck: Check for databases using trustworthy
--
-- Parameters:
--
-- Log History:	
--
-- =============================================

SELECT '-' AS name, '-' AS database_owner,  '-' AS is_trustworthy_on, '-- EXECUTE AS SQLCMD' AS change_trustworthy
UNION ALL

SELECT name
        , SUSER_SNAME(owner_sid) AS database_owner
        , CASE WHEN is_trustworthy_on = 1 THEN 'Yes'
            ELSE 'No'
            END AS is_trustworthy_on 
		, ':CONNECT ' + @@SERVERNAME + CHAR(10) 
			+ 'ALTER DATABASE ' + QUOTENAME(name) + ' SET TRUSTWORTHY OFF'
			+ CHAR(10) + 'GO'
    FROM sys.databases
    WHERE database_id > 4
		AND is_trustworthy_on = 1
    ORDER BY name
GO
