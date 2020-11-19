USE master
GO
-- Variable Declaration Section: Do NOT change this section
DECLARE @hpc_datapath nvarchar(256);
SET @hpc_datapath = 'D:\Data';
DECLARE @DBNAME nvarchar(256);
DECLARE @SQL_CREATE_DB nvarchar(2000);
DECLARE @exist INT

SET @DBNAME = @hpc_datapath +'\HPCManagement.mdf'
exec master.dbo.xp_fileexist @DBNAME, @exist OUTPUT
SET @exist = CAST(@exist AS BIT)
SET @SQL_CREATE_DB = 'CREATE DATABASE HPCManagement 
ON 
(
	NAME = HPCManagement_data, 
	FILENAME = ''' + @hpc_datapath + '\HPCManagement.mdf'', 
	size = 1024MB, 
	FILEGROWTH  = 50% 
) 
LOG ON 
( 
	NAME = HPCManagement_log,
	FILENAME = ''' + @hpc_datapath +'\HPCManagement.ldf'',
	size = 128MB,	
	FILEGROWTH  = 50% 
)'

IF (@exist = 1)
  SET @SQL_CREATE_DB = @SQL_CREATE_DB + ' FOR ATTACH;'

IF (NOT EXISTS (SELECT name FROM master.dbo.sysdatabases WHERE ([name] = 'HPCManagement' ) ) )
IF NULLIF(@hpc_datapath, '') IS NOT NULL
EXECUTE (@SQL_CREATE_DB)


SET @DBNAME = @hpc_datapath +'\HPCScheduler.mdf'
exec master.dbo.xp_fileexist @DBNAME, @exist OUTPUT
SET @exist = CAST(@exist AS BIT)
SET @SQL_CREATE_DB = 'CREATE DATABASE HPCScheduler 
ON 
(
	NAME = HPCScheduler_data, 
	FILENAME = ''' + @hpc_datapath + '\HPCScheduler.mdf'',  
	size = 256MB,  
	FILEGROWTH  = 10% 
)
LOG ON ( 
	NAME = HPCScheduler_log, 
	FILENAME = ''' + @hpc_datapath +'\HPCScheduler.ldf'', 
	size = 64MB, 
	FILEGROWTH  = 10% 
)'

IF (@exist = 1)
  SET @SQL_CREATE_DB = @SQL_CREATE_DB + ' FOR ATTACH;'

IF (NOT EXISTS (SELECT name FROM master.dbo.sysdatabases WHERE ([name] = 'HPCScheduler' ) ) )
IF NULLIF(@hpc_datapath, '') IS NOT NULL
EXECUTE (@SQL_CREATE_DB)


SET @DBNAME = @hpc_datapath +'\HPCReporting.mdf'
exec master.dbo.xp_fileexist @DBNAME, @exist OUTPUT
SET @exist = CAST(@exist AS BIT)
SET @SQL_CREATE_DB = 'CREATE DATABASE HPCReporting 
ON 
(
	NAME = HPCReporting_data,  
	FILENAME = ''' + @hpc_datapath + '\HPCReporting.mdf'', 
	size = 128MB,  
	FILEGROWTH  = 10% 
)
LOG ON 
( 
	NAME = HPCReporting_log, 
	FILENAME = ''' + @hpc_datapath +'\HPCReporting.ldf'',  
	size = 64MB,  
	FILEGROWTH  = 10% 
)'

IF (@exist = 1)
  SET @SQL_CREATE_DB = @SQL_CREATE_DB + ' FOR ATTACH;'

IF (NOT EXISTS (SELECT name FROM master.dbo.sysdatabases WHERE ([name] = 'HPCReporting' ) ) )
IF NULLIF(@hpc_datapath, '') IS NOT NULL
EXECUTE (@SQL_CREATE_DB)


SET @DBNAME = @hpc_datapath +'\HPCDiagnostics.mdf'
exec master.dbo.xp_fileexist @DBNAME, @exist OUTPUT
SET @exist = CAST(@exist AS BIT)
SET @SQL_CREATE_DB = 'CREATE DATABASE HPCDiagnostics 
ON 
( 
	NAME = HPCDiagnostics_data, 
	FILENAME = ''' + @hpc_datapath + '\HPCDiagnostics.mdf'',  
	size = 256MB, 
	FILEGROWTH  = 10% 
)
LOG ON 
( 
	NAME = HPCDiagnostics_log, 
	FILENAME = ''' + @hpc_datapath +'\HPCDiagnostics.ldf'',  
	size = 64MB,  
	FILEGROWTH  = 10% 
)'

IF (@exist = 1)
  SET @SQL_CREATE_DB = @SQL_CREATE_DB + ' FOR ATTACH;'

IF (NOT EXISTS (SELECT name FROM master.dbo.sysdatabases WHERE ([name] = 'HPCDiagnostics' ) ) )
IF NULLIF(@hpc_datapath, '') IS NOT NULL
EXECUTE (@SQL_CREATE_DB)


SET @DBNAME = @hpc_datapath +'\HPCMonitoring.mdf'
exec master.dbo.xp_fileexist @DBNAME, @exist OUTPUT
SET @exist = CAST(@exist AS BIT)
SET @SQL_CREATE_DB = 'CREATE DATABASE HPCMonitoring
ON 
(
   NAME = HPCMonitoring_data,
   FILENAME = ''' + @hpc_datapath + '\HPCMonitoring.mdf'',
   size = 256MB,
   FILEGROWTH  = 10% )
LOG ON
( 
   NAME = HPCMonitoring_log,
   FILENAME = ''' + @hpc_datapath +'\HPCMonitoring.ldf'',
   size = 64MB,
   FILEGROWTH  = 10% 
 )'

IF (@exist = 1)
  SET @SQL_CREATE_DB = @SQL_CREATE_DB + ' FOR ATTACH;'

IF (NOT EXISTS (SELECT name FROM master.dbo.sysdatabases WHERE ([name] = 'HPCMonitoring' ) ) )
IF NULLIF(@hpc_datapath, '') IS NOT NULL
EXECUTE (@SQL_CREATE_DB)

