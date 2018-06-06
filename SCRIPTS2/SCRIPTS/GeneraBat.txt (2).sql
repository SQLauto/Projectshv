----------------------------------------------------------------
--
-- T-SQL Para Generar los .BAT para subir o bajar txts
--
----------------------------------------------------------------


DECLARE
  @Server VARCHAR(20), @DBName   VARCHAR(20),
  @Modo   VARCHAR(20), @UserPass VARCHAR(50)


--Cambiar los siguientes valores para adecuarlos a la instalación
SET @Server   = 'win2008'
SET @DBName   = 'pcat'
SET @Modo     = 'out'
SET @UserPass = '-Usa -PP@55w0rd'


SELECT 'ECHO '+name+' >>Log.txt'+CHAR(13)+CHAR(10)+'BCP '+@DBNAME+'..'+name+' '+@Modo+' '+name+'.txt -b 1000 -n -S '+@Server+' '+@UserPass+' >>Log.txt'
FROM sysobjects
WHERE objectproperty(id, 'isusertable') = 1
  AND name != 'dtproperties'
  AND NOT (name like ('TMP%'))
ORDER BY name
