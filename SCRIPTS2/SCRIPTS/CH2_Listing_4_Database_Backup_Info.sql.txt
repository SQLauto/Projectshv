SELECT  CONVERT(char(100), SERVERPROPERTY('Servername')) AS Server,
        msdb.dbo.backupmediafamily.logical_device_name,
        msdb.dbo.backupmediafamily.physical_device_name,
        msdb.dbo.backupset.expiration_date,
        msdb.dbo.backupset.name,
        msdb.dbo.backupset.description,
        msdb.dbo.backupset.user_name,
        msdb.dbo.backupset.backup_start_date,
        msdb.dbo.backupset.backup_finish_date,
        CASE msdb..backupset.type
          WHEN 'D' THEN 'Database'
          WHEN 'L' THEN 'Log'
        END AS backup_type,
        msdb.dbo.backupset.backup_size,
        msdb.dbo.backupset.database_name,
        msdb.dbo.backupset.server_name AS Source_Server
FROM    msdb.dbo.backupmediafamily
        INNER JOIN msdb.dbo.backupset ON msdb.dbo.backupmediafamily.media_set_id = msdb.dbo.backupset.media_set_id
WHERE   ( CONVERT(datetime, msdb.dbo.backupset.backup_start_date, 102) >= GETDATE()
          - 30 )
