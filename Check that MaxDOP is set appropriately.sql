SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Description:	Healthcheck: Is Max DOP correctly configured?
--
-- Parameters:
--
-- Log History:	
--				2019-08-05	RAG	- Added Cost Threshold for Parallelism
--
-- =============================================

DECLARE @cpu_count INT
DECLARE @numa_node_count INT
DECLARE @maxDop INT

SELECT @numa_node_count= COUNT(DISTINCT parent_node_id) 
	FROM sys.dm_os_schedulers AS s
	WHERE s.status = 'VISIBLE ONLINE'

SELECT @cpu_count = cpu_count 
	FROM sys.dm_os_sys_info

SELECT @maxDop = 
			CASE WHEN @cpu_count / @numa_node_count >= 8 THEN 8
				ELSE @cpu_count / @numa_node_count
			END

SELECT @numa_node_count as numa_node_count
		, @cpu_count AS cpu_count
		, value_in_use AS current_max_dop
		, current_ctp AS cost_threshold_parallelism
		, CASE 
			WHEN value_in_use <> @maxDop THEN 'EXECUTE sp_configure ''max degree of parallelism'', ' + CONVERT(VARCHAR, @maxDop) + ';' + CHAR(10) + 'RECONFIGURE;' 
			ELSE 'max degree of parallelism is set to ' + CONVERT(VARCHAR, @maxDop) + ' which matches to the number of cores per numa node'
		END AS [sp_configure]
FROM sys.configurations
CROSS APPLY (SELECT value_in_use AS current_ctp FROM sys.configurations
				WHERE name = 'cost threshold for parallelism') AS ctp
WHERE name = 'max degree of parallelism'
