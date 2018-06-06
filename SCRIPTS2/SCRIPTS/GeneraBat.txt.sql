------------------------------------------------------------------
----
---- T-SQL Para Generar los .BAT para subir o bajar txts
----
------------------------------------------------------------------


--DECLARE
--  @Server VARCHAR(20), 
--  @DBName   VARCHAR(20),
--  @Modo   VARCHAR(20), 
--  @UserPass VARCHAR(50),
--  @Identity VARCHAR(5),
--  @Where VARCHAR(8000)


----Cambiar los siguientes valores para adecuarlos a la instalación

--SET @Server   = ''
--/*Si quieres usarlo via remoto  parametro:  '-S win2008'*/
--SET @UserPass = '-T'
--/*User y password '-Usa -PP@55w0rd'*/
--SET @DBName   = DB_NAME()
--/*Si quieres usar una base ene specifico parametro:  or:-S 'pcat'*/
--SET @Modo     = 'Out'
--/*Out */
--Set @Identity = ' -E'
--/*Usar o no identitys*/
--Set @Where= '%sc%'
--/*Filtro de tablas*/


--SELECT 'ECHO '+name+' >>Log.txt'+CHAR(13)+CHAR(10)+'BCP '+@DBNAME+'..'+name+' '+@Modo+' '+name+'.txt -b 1000 -n '+@Server+' '+@UserPass+@Identity' >>Log.txt'
--FROM sysobjects
--WHERE objectproperty(id, 'isusertable') = 1
--  AND name != 'dtproperties'
--  AND NOT (name like ('TMP%'))
--  AND Name LIKE @Where
--ORDER BY name
--go


/*distinta tabla para filtros de base y agrega schema en las tablas*/
------------ oOOooo

select s.name+'.'+t.Name AS name Into #Temporalname
from sys.tables T join sys.schemas S
On T.schema_id=S.schema_id



DECLARE
  @Server VARCHAR(20), 
  @DBName   VARCHAR(20),
  @Modo   VARCHAR(20), 
  @UserPass VARCHAR(50),
  @Identity VARCHAR(5),
  @Where VARCHAR(8000)



--Cambiar los siguientes valores para adecuarlos a la instalación

SET @Server   = ''
/*Si quieres usarlo via remoto  parametro:  '-S win2008'*/
SET @UserPass = '-T'
/*User y password '-Usa -PP@55w0rd'*/
SET @DBName   = DB_NAME()
/*Si quieres usar una base ene specifico parametro:  or:-S 'pcat'*/
SET @Modo     = 'Out'
/*Out */
Set @Identity = ' -E'
/*Usar o no identitys*/
Set @Where= '%sc%'
/*Filtro de tablas*/



SELECT 'ECHO '+name+' >>Log.txt'+CHAR(13)+CHAR(10)+'BCP '+@DBNAME+'.'+name+' '+@Modo+' '+name+'.txt -b 1000 -n '+@Server+' '+@UserPass+@Identity'-b 1000 >>Log.txt'
FROM #Temporalname
WHERE Name LIKE @Where
ORDER BY name

drop table #Temporalname