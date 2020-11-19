/*-------------------------------------------------------------------------------------------------
 * Creates error messages that are used by the sdm stored procedures. 
 *-------------------------------------------------------------------------------------------------*/

if exists (select * from master.dbo.sysmessages where error = 60001)
begin
exec sp_dropmessage @msgnum=60001, @lang = 'us_english'
end
exec sp_addmessage @msgnum=60001, @msgtext='Another change is in progress', @severity=16, @lang = 'us_english'
GO

if exists (select * from master.dbo.sysmessages where error = 60002)
begin
exec sp_dropmessage @msgnum=60002, @lang = 'us_english'
end
exec sp_addmessage @msgnum=60002, @msgtext='An instance in the change has been modified by another change.', @severity=16, @lang = 'us_english'
GO

if exists (select * from master.dbo.sysmessages where error = 60003)
begin
exec sp_dropmessage @msgnum=60003, @lang = 'us_english'
end
exec sp_addmessage @msgnum=60003, @msgtext='Unsupported instance state transition', @severity=16, @lang = 'us_english'
GO

if exists (select * from master.dbo.sysmessages where error = 60004)
begin
exec sp_dropmessage @msgnum=60004, @lang = 'us_english'
end
exec sp_addmessage @msgnum=60004, @msgtext='Cannot change root status', @severity=16, @lang = 'us_english'
GO

if exists (select * from master.dbo.sysmessages where error = 60005)
begin
exec sp_dropmessage @msgnum=60005, @lang = 'us_english'
end
exec sp_addmessage @msgnum=60005, @msgtext='Cannot update instance value unless change is editable or discovering.', @severity=16, @lang = 'us_english'
GO

if exists (select * from master.dbo.sysmessages where error = 60006)
begin
exec sp_dropmessage @msgnum=60006, @lang = 'us_english'
end
exec sp_addmessage @msgnum=60006, @msgtext='An instance member cannot be updated unless the change is editable or discovering.', @severity=16, @lang = 'us_english'
GO

if exists (select * from master.dbo.sysmessages where error = 60007)
begin
exec sp_dropmessage @msgnum=60007, @lang = 'us_english'
end
exec sp_addmessage @msgnum=60007, @msgtext='The state of one or more instances in the change is not consistent with the state of the change.', @severity=16, @lang = 'us_english'
GO

if exists (select * from master.dbo.sysmessages where error = 60008)
begin
exec sp_dropmessage @msgnum=60008, @lang = 'us_english'
end
exec sp_addmessage @msgnum=60008, @msgtext='Unsupported change state transition.', @severity=16, @lang = 'us_english'
GO

if exists (select * from master.dbo.sysmessages where error = 60009)
begin
exec sp_dropmessage @msgnum=60009, @lang = 'us_english'
end
exec sp_addmessage @msgnum=60009, @msgtext='Null value passed to a parameter that cannot be null.', @severity=16, @lang = 'us_english'
GO

if exists (select * from master.dbo.sysmessages where error = 60010)
begin
exec sp_dropmessage @msgnum=60010, @lang = 'us_english'
end
exec sp_addmessage @msgnum=60010, @msgtext='The change has been updated by another user.', @severity=16, @lang = 'us_english'
go

if exists (select * from master.dbo.sysmessages where error = 60011)
begin
exec sp_dropmessage @msgnum=60011, @lang = 'us_english'
end
exec sp_addmessage @msgnum=60011, @msgtext='Access to the change is denied', @severity=16, @lang = 'us_english'
go

if exists (select * from master.dbo.sysmessages where error = 60012)
begin
exec sp_dropmessage @msgnum=60012, @lang = 'us_english'
end
exec sp_addmessage @msgnum=60012, @msgtext='You do not have permission to update setting values for the instance %s in the change.', @severity=16, @lang = 'us_english'
go

if exists (select * from master.dbo.sysmessages where error = 60013)
begin
exec sp_dropmessage @msgnum=60013, @lang = 'us_english'
end
exec sp_addmessage @msgnum=60013, @msgtext='Only an administrator or the owner can change the owner the instance %s.', @severity=16, @lang = 'us_english'
go

if exists (select * from master.dbo.sysmessages where error = 60014)
begin
exec sp_dropmessage @msgnum=60014, @lang = 'us_english'
end
exec sp_addmessage @msgnum=60014, @msgtext='Only an administrator can create a root instance', @severity=16, @lang = 'us_english'
go

if exists (select * from master.dbo.sysmessages where error = 60015)
begin
exec sp_dropmessage @msgnum=60015, @lang = 'us_english'
end
exec sp_addmessage @msgnum=60015, @msgtext='You do not have permission to update reference members on an instance %s in the change.', @severity=16, @lang = 'us_english'
go

if exists (select * from master.dbo.sysmessages where error = 60016)
begin
exec sp_dropmessage @msgnum=60016, @lang = 'us_english'
end
exec sp_addmessage @msgnum=60016, @msgtext='You do not have permission to update the permissions for an instance %s in the change.', @severity=16, @lang = 'us_english'
go

if exists (select * from master.dbo.sysmessages where error = 60017)
begin
exec sp_dropmessage @msgnum=60017, @lang = 'us_english'
end
exec sp_addmessage @msgnum=60017, @msgtext='The specified user is not registered with the store.', @severity=16, @lang = 'us_english'
go

if exists (select * from master.dbo.sysmessages where error = 600018)
begin
exec sp_dropmessage @msgnum=600018, @lang = 'us_english'
end
exec sp_addmessage @msgnum=600018, @msgtext='Instance permissions cannot be updated unless the change is editable or discovering.', @severity=16, @lang = 'us_english'
GO

if exists (select * from master.dbo.sysmessages where error = 600019)
begin
exec sp_dropmessage @msgnum=600019, @lang = 'us_english'
end
exec sp_addmessage @msgnum=600019, @msgtext='The specified user does not exist in the store.', @severity=16, @lang = 'us_english'
GO

if exists (select * from master.dbo.sysmessages where error = 60020)
begin
exec sp_dropmessage @msgnum=60020, @lang = 'us_english'
end
exec sp_addmessage @msgnum=60020, @msgtext='Another change has locked the instances this change is trying to update. Wait until the existing change has completed or been cancelled before retrying the action.', @severity=16, @lang = 'us_english'
GO

if exists (select * from master.dbo.sysmessages where error = 600021)
begin
exec sp_dropmessage @msgnum=600021, @lang = 'us_english'
end
exec sp_addmessage @msgnum=600021, @msgtext='The change cannot be reverted because the previous instance state has been archived.', @severity=16, @lang = 'us_english'
GO

if exists (select * from master.dbo.sysmessages where error = 600022)
begin
exec sp_dropmessage @msgnum=600022, @lang = 'us_english'
end
exec sp_addmessage @msgnum=600022, @msgtext='The change updates instances that are not in the list of instances referenced by the change.', @severity=16, @lang = 'us_english'
GO

if exists (select * from master.dbo.sysmessages where error = 600023)
begin
exec sp_dropmessage @msgnum=600023, @lang = 'us_english'
end
exec sp_addmessage @msgnum=600023, @msgtext='The change cannot be committed unless all actions have been committed.',  @severity=16, @lang = 'us_english'
GO