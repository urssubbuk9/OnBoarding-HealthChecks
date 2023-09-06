SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Description:	Healthcheck: instant file initialization is enabled
--
-- Remarks:     This script will return information only for SQL Server 2012 SP4 and 2016 SP onwards.
--                 SQL Server 2014 branch does not have the column, ask Microsoft why :)
--              You can use this to get as many servers as you can and the fill the gaps manually
--
-- Parameters:
--
-- Log History:	
--
-- =============================================

IF RIGHT(@@version, LEN(@@version) - 3 - CHARINDEX(' ON ', @@VERSION)) NOT LIKE 'Windows%'
    BEGIN
        SELECT  SERVERPROPERTY('ServerName') AS [Server Name] ,
                RIGHT(@@version,
                      LEN(@@version) - 3 - CHARINDEX(' ON ', @@VERSION)) AS [OS Info] ,
                LEFT(@@VERSION, CHARINDEX('-', @@VERSION) - 2) + ' '
                + CAST(SERVERPROPERTY('ProductVersion') AS NVARCHAR(300)) AS [SQL Server Version] ,
                'N/A' AS [service_account] ,
                'N/A' AS [instant_file_initialization_enabled]
    END
ELSE
    BEGIN
        IF EXISTS ( SELECT  0
                    FROM    sys.all_objects AO
                            INNER JOIN sys.all_columns AC ON AC.object_id = AO.object_id
                    WHERE   AO.name LIKE '%dm_server_services%'
                            AND AC.name = 'instant_file_initialization_enabled' )
            BEGIN
                EXEC('   SELECT  SERVERPROPERTY(''ServerName'') AS [Server Name] ,
                RIGHT(@@version, LEN(@@version) - 3 - CHARINDEX('' ON '', @@VERSION)) AS [OS Info] ,
                LEFT(@@VERSION, CHARINDEX(''-'', @@VERSION) - 2)  + '' '' +  CAST(SERVERPROPERTY(''ProductVersion'') AS NVARCHAR(300) ) AS [SQL Server Version],
                service_account ,
                instant_file_initialization_enabled
                FROM    sys.dm_server_services
                WHERE   servicename LIKE ''SQL Server (%''')
            END
        ELSE
            BEGIN
                SELECT  SERVERPROPERTY('ServerName') AS [Server Name] ,
                        RIGHT(@@version,
                              LEN(@@version) - 3 - CHARINDEX(' ON ', @@VERSION)) AS [OS Info] ,
                        LEFT(@@VERSION, CHARINDEX('-', @@VERSION) - 2) + ' '
                        + CAST(SERVERPROPERTY('ProductVersion') AS NVARCHAR(300)) AS [SQL Server Version] ,
                        service_account AS [service_account] ,
                        'N/A' AS [instant_file_initialization_enabled]
                FROM    sys.dm_server_services
                WHERE   servicename LIKE 'SQL Server (%'
            END  
    END

