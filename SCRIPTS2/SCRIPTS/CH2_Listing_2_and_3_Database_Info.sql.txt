IF EXISTS ( SELECT  *
            FROM    tempdb.dbo.sysobjects
            WHERE   id = OBJECT_ID(N'[tempdb].[dbo].[HoldforEachDB]') ) 
    DROP TABLE [tempdb].[dbo].[HoldforEachDB] ; 
CREATE TABLE [tempdb].[dbo].[HoldforEachDB]
    (
      [Server] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS
                               NULL,
      [DatabaseName] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS
                                     NOT NULL,
      [Size] [int] NOT NULL,
      [File_Status] [int] NULL,
      [Name] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS
                             NOT NULL,
      [Filename] [nvarchar](260) COLLATE SQL_Latin1_General_CP1_CI_AS
                                 NOT NULL,
      [Status] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS
                               NULL,
      [Updateability] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS
                                      NULL,
      [User_Access] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS
                                    NULL,
      [Recovery] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS
                                 NULL
    )
ON  [PRIMARY]
INSERT  INTO [tempdb].[dbo].[HoldforEachDB]
        EXEC sp_MSforeachdb 'SELECT CONVERT(char(100), SERVERPROPERTY(''Servername'')) AS Server,
                 ''?'' as DatabaseName,[?]..sysfiles.size, [?]..sysfiles.status, [?]..sysfiles.name, [?]..sysfiles.filename,convert(sysname,DatabasePropertyEx(''?'',''Status'')) as Status,
convert(sysname,DatabasePropertyEx(''?'',''Updateability'')) as Updateability,
 convert(sysname,DatabasePropertyEx(''?'',''UserAccess'')) as User_Access,
convert(sysname,DatabasePropertyEx(''?'',''Recovery'')) as Recovery From [?]..sysfiles '

SELECT [Server]
      ,[DatabaseName]
      ,[Size]
      ,[File_Status]
      ,[Name]
      ,[Filename]
      ,[Status]
      ,[Updateability]
      ,[User_Access]
      ,[Recovery]
  FROM [tempdb].[dbo].[HoldforEachDB] 

