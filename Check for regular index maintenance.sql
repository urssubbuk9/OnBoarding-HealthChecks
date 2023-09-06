SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Description:	Healthcheck: Check for regular index maintenance
--
-- Log History:
-- 				25-10-2018	RAG	Added CHAR(10) + JOB: to get one line per job.
-- 								Also added double quotes to be able to copy/paste into excel 
-- 									and job list will land in one single cell
-- =============================================

SELECT CASE WHEN NOT EXISTS (
        SELECT * 
            FROM msdb.dbo.sysjobs AS j 
				INNER JOIN msdb.dbo.sysjobsteps as s
					ON s.job_id = j.job_id
			WHERE j.name LIKE '%index%'
				OR s.step_name LIKE '%index%') THEN 'Does not have any job that looks like index maintenance' 
		ELSE '"' + 
				STUFF((SELECT CHAR(10) + 'JOB: ' + j.name + '-' + s.step_name + ISNULL(' (' + CASE WHEN j.enabled = 0 THEN 'DISABLED!!' ELSE NULL END + ')', '')
						FROM msdb.dbo.sysjobs AS j 
							INNER JOIN msdb.dbo.sysjobsteps as s
								ON s.job_id = j.job_id
						WHERE j.name LIKE '%index%'
							OR s.step_name LIKE '%index%'
						FOR XML PATH('')), 1,1,'') + '"'
		END AS index_maint
GO
