SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Description:	Healthcheck: Check that "Optimize for Adhoc Workloads" is enabled
--
-- Parameters:
--
-- Log History:	
--              24/10/2018  RAG Added parameter @onlyHealthCheck to actually change the setting once we have the consent
--
-- =============================================

DECLARE @onlyHealthCheck BIT = 1

IF @onlyHealthCheck = 1 BEGIN 
	SELECT name, value_in_use FROM sys.configurations
	WHERE name = 'optimize for ad hoc workloads'
	AND value_in_use = 0
END
ELSE BEGIN
	IF EXISTS (SELECT name, value_in_use FROM sys.configurations
				WHERE name = 'optimize for ad hoc workloads'
				AND value_in_use = 0) BEGIN
		EXECUTE sp_configure 'show advanced options', 1
		RECONFIGURE
		EXECUTE sp_configure 'optimize for ad hoc workloads', 1
		RECONFIGURE
	END
END
GO
