USE msdb;  
GO  

EXEC dbo.sp_add_job  
   @job_name = N'BackupHPCManagementDatabase',   
   @enabled = 1,   
   @description = N'Create a backup of the monitoring database' ;   
GO  

EXEC dbo.sp_add_jobstep  
    @job_name = N'BackupHPCManagementDatabase',   
    @step_name = N'execute backup',   
    @subsystem = N'TSQL',   
    @command = N'USE [HPCManagement]  
                 GO  

DECLARE @path VARCHAR(500)
DECLARE @name VARCHAR(500)
DECLARE @pathwithname VARCHAR(500)
DECLARE @time DATETIME
DECLARE @year VARCHAR(4)
DECLARE @month VARCHAR(2)
DECLARE @day VARCHAR(2)
DECLARE @hour VARCHAR(2)
DECLARE @minute VARCHAR(2)
DECLARE @second VARCHAR(2)

SET @path = ''E:\Daily Backups\''

SELECT @time   = GETDATE()
SELECT @year   = (SELECT CONVERT(VARCHAR(4), DATEPART(yy, @time)))
SELECT @month  = (SELECT CONVERT(VARCHAR(2), FORMAT(DATEPART(mm,@time),''00'')))
SELECT @day    = (SELECT CONVERT(VARCHAR(2), FORMAT(DATEPART(dd,@time),''00'')))
SELECT @hour   = (SELECT CONVERT(VARCHAR(2), FORMAT(DATEPART(hh,@time),''00'')))
SELECT @minute = (SELECT CONVERT(VARCHAR(2), FORMAT(DATEPART(mi,@time),''00'')))
SELECT @second = (SELECT CONVERT(VARCHAR(2), FORMAT(DATEPART(ss,@time),''00'')))

SELECT @name = ''HPCManagement'' + ''_'' + @year + @month + @day + @hour + @minute + @second

SET @pathwithname = @path + @namE + ''.bak''

BACKUP DATABASE [HPCManagement] TO DISK = @pathwithname WITH FORMAT, MEDIANAME = ''SQLServerBackups'', NAME = ''Full Backup of HPCManagement''; 
GO  
',   
    @retry_attempts = 5,   
    @retry_interval = 5 ;   
GO  

EXEC dbo.sp_add_schedule  
    @schedule_name = N'DailyFullBackup_HPCManagement',   
    @freq_type = 4,   
    @freq_interval = 1,   
    @active_start_time = 224500 ;   
GO  

EXEC sp_attach_schedule  
   @job_name = N'BackupHPCManagementDatabase',  
   @schedule_name = N'DailyFullBackup_HPCManagement' ;   
GO

EXEC sp_add_jobserver 
	@job_name = N'BackupHPCManagementDatabase'
GO