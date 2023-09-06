SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Description:	Healthcheck: Generate commands to create SPN's for SQL Server Service account
--
-- Remarks:     This script does not check whether the SPN exists, that is controlled by setspn -s, 
--              which will only create it in case it does not exit.
--              Tip: Use this script in a multi-server query window.
--
-- Log History:	
--
-- =============================================

-- These accounts should be enabled for delegation in AD
SELECT DISTINCT @@SERVERNAME AS ServerName, servicename, service_account 
	FROM sys.dm_server_services AS s
	WHERE servicename LIKE 'SQL Server (%'
		AND service_account <> 'LocalSystem'
		AND service_account NOT LIKE 'NT Service%'

-- This will script out the required SETSNP commands to create SPN on the service accounts 
DECLARE @Domain varchar(100), @key varchar(100)
SET @key = 'SYSTEM\ControlSet001\Services\Tcpip\Parameters\'
EXEC master..xp_regread @rootkey='HKEY_LOCAL_MACHINE', @key=@key,@value_name='Domain',@value=@Domain OUTPUT 

SELECT @@SERVERNAME AS ServerName, servicename, service_account 
		, 'setspn -s "MSSQLSvc/' + @@servername + '.'+convert(varchar(100),@Domain) 
			+'" "'  + 
			CASE WHEN service_account LIKE '%@%' THEN 
				RIGHT(service_account, CHARINDEX('@', REVERSE(service_account)) - 1) -- Domain
				+ '\' 
				+ REPLACE(service_account, RIGHT(service_account, CHARINDEX('@', REVERSE(service_account))), '')	-- Account
				ELSE service_account
			END  + '"' AS CreateSPN

	FROM sys.dm_server_services AS s
	WHERE servicename LIKE 'SQL Server (%'
		AND service_account <> 'LocalSystem'
		AND service_account NOT LIKE 'NT Service%'
UNION ALL
SELECT @@SERVERNAME AS ServerName, servicename, service_account 
		, 'setspn -s "MSSQLSvc/' + @@servername + '.'+convert(varchar(100),@Domain)  + ':' + CONVERT(SYSNAME,tcp_port.local_tcp_port) 
			+'" "'  + 
			CASE WHEN service_account LIKE '%@%' THEN 
				RIGHT(service_account, CHARINDEX('@', REVERSE(service_account)) - 1) -- Domain
				+ '\' 
				+ REPLACE(service_account, RIGHT(service_account, CHARINDEX('@', REVERSE(service_account))), '')	-- Account
				ELSE service_account
			END  + '"'
	FROM sys.dm_server_services AS s
		CROSS APPLY (select distinct local_tcp_port from sys.dm_exec_connections where local_net_address is not null) AS tcp_port
	WHERE servicename LIKE 'SQL Server (%'
		AND service_account <> 'LocalSystem'
		AND service_account NOT LIKE 'NT Service%'

