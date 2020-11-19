
BEGIN TRY
    if not exists (select * from sys.server_principals where name = '$(TargetAccount)')
    begin
        /* create login [$(TargetAccount)] from windows;*/
        CREATE LOGIN [$(TargetAccount)] WITH PASSWORD = '$(PassWord)', CHECK_EXPIRATION = OFF;
    end
END TRY
BEGIN CATCH
END CATCH

if not exists (select * from sys.database_principals where name = '$(TargetAccount)')
begin
	create user [$(TargetAccount)];
	if @@error <> 0 return;
end;

ALTER USER [$(TargetAccount)] WITH LOGIN = [$(TargetAccount)];

exec sp_addrolemember 'db_datareader', '$(TargetAccount)';
if @@error <> 0 return;

exec sp_addrolemember 'db_datawriter', '$(TargetAccount)';
if @@error <> 0 return;

exec sp_addrolemember 'db_ddladmin', '$(TargetAccount)';
if @@error <> 0 return;

exec sp_addrolemember 'db_owner', '$(TargetAccount)';
if @@error <> 0 return;

-- Enable HPC setup user to configure database in HpcServer_x64.msi
grant alter to [$(TargetAccount)]
if @@error <> 0 return;

-- Enable HPC setup user to use user-defined FUNCTION
grant exec to [$(TargetAccount)];
if @@error <> 0 return;

-- Enable HPC setup user to query database extended property DbVersion
grant view definition to [$(TargetAccount)]
if @@error <> 0 return;
GO