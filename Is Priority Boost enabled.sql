SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Description:	Healthcheck: Is Priority Boost enabled? (It should NOT be)
--
-- Parameters:
--
-- Log History:	
--
-- =============================================

DECLARE @onlyHealthCheck BIT = 1

IF @onlyHealthCheck = 1 BEGIN 
	SELECT name, value_in_use 
        FROM sys.configurations
        WHERE name = 'priority boost'
            AND value_in_use = 1
END
ELSE BEGIN
	IF EXISTS (SELECT name, value_in_use FROM sys.configurations
				WHERE name = 'priority boost'
                    AND value_in_use = 1) BEGIN
        EXECUTE sp_configure 'show advanced options', 1
        RECONFIGURE
        EXECUTE sp_configure 'priority boost', 0
        RECONFIGURE
	END
END
GO
