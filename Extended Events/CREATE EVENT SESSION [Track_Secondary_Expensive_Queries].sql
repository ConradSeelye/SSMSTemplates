
/* 
Creating a server-level Extended Event (XE) session to run on an Always On Secondary Replica requires navigating a unique constraint: **the secondary replica metadata is read-only.** Therefore, you must write and deploy the script on the Primary Replica first. The Availability Group will automatically sync the session's definition to the secondary instance's master database.
Once it replicates, you connect directly to the Secondary Replica and issue a command to turn it on.

### Understanding and Adjusting the Threshold Parameters
To prevent performance overhead, you must filter out the noise and only capture truly "expensive" queries. Extended Events measure resource usage with specific parameters and units:
 1. **duration**: Measured in **microseconds** (1 \text{ second} = 1,000,000 \text{ microseconds}).
 2. **cpu_time**: Also measured in **microseconds**. This is actual CPU core processing time. If a query runs parallel across 4 cores, cpu_time can easily exceed duration.
 3. **logical_reads**: Measured in **8 KB memory pages** read from the buffer pool. 100,000 logical reads equals roughly 800 MB of data processed in memory (100,000 \times 8 \text{ KB} / 1024 = 781.25 \text{ MB}).
### Step-by-Step Implementation Example
#### Step 1: Create the Session (Execute on the PRIMARY Replica)
Run this T-SQL script while connected to your Primary instance.
 * **The Threshold Strategy:** For this example, we will set the filter predicates to capture any ad-hoc batch or stored procedure that eats more than **3 seconds of CPU time** OR performs more than **200,000 logical reads** (about 1.5 GB of memory page scans).
```sql

*/

/* Delete

DROP EVENT SESSION [Track_Secondary_Expensive_Queries] ON SERVER 


*/

-- Instance default log path (shows where XE/event files will go when no path is supplied)
--SELECT SERVERPROPERTY('InstanceDefaultLogPath') AS InstanceDefaultLogPath,
--       SERVERPROPERTY('InstanceDefaultDataPath') AS InstanceDefaultDataPath;


-- EXECUTE THIS ON THE PRIMARY REPLICA
CREATE EVENT SESSION [Track_Secondary_Expensive_Queries] ON SERVER 
ADD EVENT sqlserver.rpc_completed(
    ACTION(sqlserver.client_app_name, sqlserver.database_name, sqlserver.nt_username, sqlserver.sql_text)
    -- WHERE ([cpu_time]>=(3000000) OR [logical_reads]>=(1000))),
	-- WHERE (sqlserver.database_name = N'SAT' AND (duration > 1000000 OR [cpu_time]>=(3000000)    )),
	WHERE ( sqlserver.database_name = N'SAT' AND ([cpu_time]>=(3000000) OR [logical_reads]>=(1000)))),
ADD EVENT sqlserver.sql_batch_completed(
    ACTION(sqlserver.client_app_name, sqlserver.database_name, sqlserver.nt_username, sqlserver.sql_text)
    WHERE ([cpu_time]>=(3000000) OR [logical_reads]>=(1000)))
ADD TARGET package0.event_file(SET filename=N'S:\xEvents\Track_Secondary_Expensive_Queries')
WITH (
    MAX_MEMORY=4096 KB, 
    EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS, 
    MAX_DISPATCH_LATENCY=30 SECONDS, 
    STARTUP_STATE=OFF
);
GO

--```
--#### Step 2: Start the Session (Execute on the SECONDARY Replica)
--Give the Availability Group a few seconds to sync the configuration metadata. Then, open a query window **connected directly to the Secondary Replica** and run this statement to spin up the engine tracking mechanism:
--```sql
-- EXECUTE THIS ON THE READ-ONLY SECONDARY REPLICA
ALTER EVENT SESSION [Track_Secondary_Expensive_Queries] ON SERVER STATE = START;
GO

--```
--#### Step 3: Extract and Read the Capture Data (Execute on the SECONDARY)
--Because the session runs on the secondary, it outputs its trace file (.xel) to the local disk path of the secondary instance. Run this script directly on the secondary to parse the XML payload and list the worst queries sorted by memory pressure:
--```sql
-- EXECUTE THIS ON THE SECONDARY TO VIEW RESULTS
SELECT 
    event_data.value('(event/@name)[1]', 'VARCHAR(50)') AS [Event_Type],
    event_data.value('(event/@timestamp)[1]', 'DATETIME2') AS [Time_Stamp],
    event_data.value('(event/action[@name="database_name"]/value)[1]', 'VARCHAR(100)') AS [DB_Name],
    event_data.value('(event/data[@name="duration"]/value)[1]', 'BIGINT') / 1000000.0 AS [Duration_Sec],
    event_data.value('(event/data[@name="cpu_time"]/value)[1]', 'BIGINT') / 1000000.0 AS [CPU_Time_Sec],
    event_data.value('(event/data[@name="logical_reads"]/value)[1]', 'BIGINT') AS [Logical_Reads],
    event_data.value('(event/action[@name="sql_text"]/value)[1]', 'VARCHAR(MAX)') AS [SQL_Statement],
    event_data.value('(event/action[@name="client_app_name"]/value)[1]', 'VARCHAR(255)') AS [Application]
FROM (
    SELECT CAST(event_data AS XML) AS event_data
    FROM sys.fn_xe_file_target_read_file('Track_Secondary_Expensive_Queries*.xel', NULL, NULL, NULL)
) AS TargetXMLTable
ORDER BY [Logical_Reads] DESC;




