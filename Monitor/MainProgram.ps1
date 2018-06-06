### POWERSHELL ###

### REMOVE OLD SERVERS LIST ###
### $FileExists = Test-Path F:\Monitor\SERVERNAME.txt
### if ($FileExists) 
### {
### 	Remove-Item F:\Monitor\SERVERNAME.txt
### }

#################################################################################################################################################################################

### CREATE SERVERS NAME FILE ###

### invoke-expression "sqlcmd -E -S SSCVPIDERA01 -i F:\Monitor\GetServers.sql -s ',' -W -h -1 > F:\Monitor\SERVERNAME.txt"
### $x = get-content F:\Monitor\SERVERNAME.txt
### $x[1..$x.count] | set-content F:\Monitor\SERVERNAME.txt 
### $FILE = Get-Content F:\Monitor\SERVERNAME.txt 
### $output = $FILE[0..($FILE.count - 3)] > SERVERNAME.txt

#################################################################################################################################################################################

### REVIEW SERVERS LIST AUTOSHRINK CYCLE ####

$FileExists = Test-Path F:\Monitor\AutoShrink\AutoShrink_Report.txt
if ($FileExists) 
{
 	Remove-Item F:\Monitor\AutoShrink\AutoShrink_Report.txt
	Remove-Item F:\Monitor\AutoShrink\Email_output_DB_Status.txt
	Remove-Item F:\Monitor\AutoShrink\Email_output_DB_Status_history.txt
	Remove-Item F:\Monitor\AutoShrink\Failures_log.txt
}

$objSQLConnection = New-Object System.Data.SqlClient.SqlConnection

foreach ($srv in get-content F:\Monitor\SERVERNAME.txt)
{
 try
 {
     $objSQLConnection.ConnectionString = "Server=$srv;Integrated Security=SSPI;" 
     $objSQLConnection.Open() | Out-Null 
     write-host (get-date) + $srv
     $objSQLConnection.Close()
     invoke-expression "sqlcmd -E -S '$srv' -i F:\Monitor\AutoShrink\Query_AutoShrink.sql -s '|' -u -W -h -1 >> F:\Monitor\AutoShrink\AutoShrink_Report.txt"
    
 }
 catch
 {
         $err = $Error[0].Exception ; 
            Write-Host -BackgroundColor Red -ForegroundColor White "Failed:" + (get-date) + $srv
         "Error caught: @" + (get-date) + " - " + $srv + " - " + $err.Message | out-File -filepath "F:\Monitor\AutoShrink\Failures_log.txt" -append
         continue 
 }
}

##### EMAIL CONDITION AUTOSHRINK #####

$COUNT = (Get-Content F:\Monitor\AutoShrink\AutoShrink_Report.txt).count
IF ($Count -gt 0)
{
 	Write Host "Sending Email..."
 	write-host "File Count="$COUNT "Row(s)"
	invoke-expression "sqlcmd -E -S SSCVPIDERA01 -i F:\Monitor\AutoShrink\DB_Status_SendMail.sql -s ',' -W -h -1 > F:\Monitor\AutoShrink\Email_output_DB_Status.txt"
	get-date >> F:\Monitor\AutoShrink\Email_output_DB_Status_history.txt
	get-content F:\Monitor\AutoShrink\Email_output_DB_Status.txt >> F:\Monitor\AutoShrink\Email_output_DB_Status_history.txt
[GC]::Collect()
} 
ELSE
{
 	Write Host "Not Send any email"..
 	write-host "File Count="$COUNT "Row(s)"
 	write-host " ********************************* "

}

#################################################################################################################################################################################

### REVIEW SERVERS LIST AutoCreateStatsCYCLE ####

$FileExists = Test-Path F:\Monitor\AutoCreateStats\AutoCreateStats_Reports.txt
if ($FileExists) 
{
 	Remove-Item F:\Monitor\AutoCreateStats\AutoCreateStats_Reports.txt
	Remove-Item F:\Monitor\AutoCreateStats\Email_output_DB_Status.txt
	Remove-Item F:\Monitor\AutoCreateStats\Email_output_DB_Status_history.txt
	Remove-Item F:\Monitor\AutoCreateStats\Failures_log.txt
}

foreach ($srv in get-content F:\Monitor\SERVERNAME.txt)
{
 try
 {
     $objSQLConnection.ConnectionString = "Server=$srv;Integrated Security=SSPI;" 
     $objSQLConnection.Open() | Out-Null 
     write-host (get-date) + $srv
     $objSQLConnection.Close()
     invoke-expression "sqlcmd -E -S '$srv' -i F:\Monitor\AutoCreateStats\Query_AutoCreateStats.sql -s '|' -u -W -h -1 >> F:\Monitor\AutoCreateStats\AutoCreateStats_Reports.txt"
    
 }
 catch
 {
         $err = $Error[0].Exception ; 
            Write-Host -BackgroundColor Red -ForegroundColor White "Failed:" + (get-date) + $srv
         "Error caught: @" + (get-date) + " - " + $srv + " - " + $err.Message | out-File -filepath "F:\Monitor\AutoCreateStats\Failures_log.txt" -append
         continue 
 }
}

##### EMAIL CONDITION AUTOCREATESTATS#####

$COUNT = (Get-Content F:\Monitor\AutoCreateStats\AutoCreateStats_Reports.txt).count
IF ($Count -gt 0)
{
 	Write Host "Sending Email..."
 	write-host "File Count="$COUNT "Row(s)"
	invoke-expression "sqlcmd -E -S SSCVPIDERA01 -i F:\Monitor\AutoCreateStats\DB_Status_SendMail.sql -s ',' -W -h -1 > F:\Monitor\AutoCreateStats\Email_output_DB_Status.txt"
	get-date >> F:\Monitor\AutoCreateStats\Email_output_DB_Status_history.txt
	get-content F:\Monitor\AutoCreateStats\Email_output_DB_Status.txt >> F:\Monitor\AutoCreateStats\Email_output_DB_Status_history.txt
[GC]::Collect()
} 
Else
{
 	Write Host "Not Send any email"..
 	write-host "File Count="$COUNT "Row(s)"
 	write-host " ********************************* "

}

#################################################################################################################################################################################

### REVIEW SERVERS LIST AUTOCLOSE ####

$FileExists = Test-Path F:\Monitor\AutoClose\AutoClose_Reports.txt
if ($FileExists) 
{
 	Remove-Item F:\Monitor\AutoClose\AutoClose_Reports.txt
	Remove-Item F:\Monitor\AutoClose\Email_output_DB_Status.txt
	Remove-Item F:\Monitor\AutoClose\Email_output_DB_Status_history.txt
	Remove-Item F:\Monitor\AutoClose\Failures_log.txt
}

foreach ($srv in get-content F:\Monitor\SERVERNAME.txt)
{
 try
 {
     $objSQLConnection.ConnectionString = "Server=$srv;Integrated Security=SSPI;" 
     $objSQLConnection.Open() | Out-Null 
     write-host (get-date) + $srv
     $objSQLConnection.Close()
     invoke-expression "sqlcmd -E -S '$srv' -i F:\Monitor\AutoClose\Query_AutoClose.sql -s '|' -u -W -h -1 >> F:\Monitor\AutoClose\AutoClose_Reports.txt"
    
 }
 catch
 {
         $err = $Error[0].Exception ; 
            Write-Host -BackgroundColor Red -ForegroundColor White "Failed:" + (get-date) + $srv
         "Error caught: @" + (get-date) + " - " + $srv + " - " + $err.Message | out-File -filepath "F:\Monitor\AutoClose\Failures_log.txt" -append
         continue 
 }
}

##### EMAIL CONDITION AUTOCLOSE #####

$COUNT = (Get-Content F:\Monitor\AutoClose\AutoClose_Reports.txt).count
IF ($Count -gt 0)
{
 	Write Host "Sending Email..."
 	write-host "File Count="$COUNT "Row(s)"
	invoke-expression "sqlcmd -E -S SSCVPIDERA01 -i F:\Monitor\AutoClose\DB_Status_SendMail.sql -s ',' -W -h -1 > F:\Monitor\AutoClose\Email_output_DB_Status.txt"
	get-date >> F:\Monitor\AutoClose\Email_output_DB_Status_history.txt
	get-content F:\Monitor\AutoClose\Email_output_DB_Status.txt >> F:\Monitor\AutoClose\Email_output_DB_Status_history.txt
[GC]::Collect()
} 
Else
{
 	Write Host "Not Send any email"..
 	write-host "File Count="$COUNT "Row(s)"
 	write-host " ********************************* "

}

#################################################################################################################################################################################

### REVIEW SERVERS LIST PAGEVERIFY ####

$FileExists = Test-Path F:\Monitor\PageVerify\PageVerify_Reports.txt
if ($FileExists) 
{
 	Remove-Item F:\Monitor\PageVerify\PageVerify_Reports.txt
	Remove-Item F:\Monitor\PageVerify\Email_output_DB_Status.txt
	Remove-Item F:\Monitor\PageVerify\Email_output_DB_Status_history.txt
	Remove-Item F:\Monitor\PageVerify\Failures_log.txt
}

foreach ($srv in get-content F:\Monitor\SERVERNAME.txt)
{
 try
 {
     $objSQLConnection.ConnectionString = "Server=$srv;Integrated Security=SSPI;" 
     $objSQLConnection.Open() | Out-Null 
     write-host (get-date) + $srv
     $objSQLConnection.Close()
     invoke-expression "sqlcmd -E -S '$srv' -i F:\Monitor\PageVerify\Query_PageVerify.sql -s '|' -u -W -h -1 >> F:\Monitor\PageVerify\PageVerify_Reports.txt"
    
 }
 catch
 {
         $err = $Error[0].Exception ; 
            Write-Host -BackgroundColor Red -ForegroundColor White "Failed:" + (get-date) + $srv
         "Error caught: @" + (get-date) + " - " + $srv + " - " + $err.Message | out-File -filepath "F:\Monitor\PageVerify\Failures_log.txt" -append
         continue 
 }
}

##### EMAIL CONDITION PAGEVERIFY #####

$COUNT = (Get-Content F:\Monitor\PageVerify\PageVerify_Reports.txt).count
IF ($Count -gt 0)
{
 	Write Host "Sending Email..."
 	write-host "File Count="$COUNT "Row(s)"
	invoke-expression "sqlcmd -E -S SSCVPIDERA01 -i F:\Monitor\PageVerify\DB_Status_SendMail.sql -s ',' -W -h -1 > F:\Monitor\PageVerify\Email_output_DB_Status.txt"
	get-date >> F:\Monitor\PageVerify\Email_output_DB_Status_history.txt
	get-content F:\Monitor\PageVerify\Email_output_DB_Status.txt >> F:\Monitor\PageVerify\Email_output_DB_Status_history.txt
[GC]::Collect()
} 
Else
{
 	Write Host "Not Send any email"..
 	write-host "File Count="$COUNT "Row(s)"
 	write-host " ********************************* "

}

#################################################################################################################################################################################

### REVIEW SERVERS LIST RECOVERY MODEL ####

$FileExists = Test-Path F:\Monitor\RecoveryModel\RecoveryModel_Reports.txt
if ($FileExists) 
{
 	Remove-Item F:\Monitor\RecoveryModel\RecoveryModel_Reports.txt
	Remove-Item F:\Monitor\RecoveryModel\Email_output_DB_Status.txt
	Remove-Item F:\Monitor\RecoveryModel\Email_output_DB_Status_history.txt
	Remove-Item F:\Monitor\RecoveryModel\Failures_log.txt
}

foreach ($srv in get-content F:\Monitor\SERVERNAME.txt)
{
 try
 {
     $objSQLConnection.ConnectionString = "Server=$srv;Integrated Security=SSPI;" 
     $objSQLConnection.Open() | Out-Null 
     write-host (get-date) + $srv
     $objSQLConnection.Close()
     invoke-expression "sqlcmd -E -S '$srv' -i F:\Monitor\RecoveryModel\Query_RecoveryModel.sql -s '|' -u -W -h -1 >> F:\Monitor\RecoveryModel\RecoveryModel_Reports.txt"
    
 }
 catch
 {
         $err = $Error[0].Exception ; 
            Write-Host -BackgroundColor Red -ForegroundColor White "Failed:" + (get-date) + $srv
         "Error caught: @" + (get-date) + " - " + $srv + " - " + $err.Message | out-File -filepath "F:\Monitor\RecoveryModel\Failures_log.txt" -append
         continue 
 }
}

##### EMAIL CONDITION RECOVERY MODEL #####

$COUNT = (Get-Content F:\Monitor\RecoveryModel\RecoveryModel_Reports.txt).count
IF ($Count -gt 0)
{
 	Write Host "Sending Email..."
 	write-host "File Count="$COUNT "Row(s)"
	invoke-expression "sqlcmd -E -S SSCVPIDERA01 -i F:\Monitor\RecoveryModel\DB_Status_SendMail.sql -s ',' -W -h -1 > F:\Monitor\RecoveryModel\Email_output_DB_Status.txt"
	get-date >> F:\Monitor\RecoveryModel\Email_output_DB_Status_history.txt
	get-content F:\Monitor\RecoveryModel\Email_output_DB_Status.txt >> F:\Monitor\RecoveryModel\Email_output_DB_Status_history.txt
[GC]::Collect()
} 
Else
{
 	Write Host "Not Send any email"..
 	write-host "File Count="$COUNT "Row(s)"
 	write-host " ********************************* "

}

#################################################################################################################################################################################

### REVIEW SERVERS LIST DB STATUS ####

$FileExists = Test-Path F:\Monitor\DB_STATUS\DBstatus_Reports.txt
if ($FileExists) 
{
 	Remove-Item F:\Monitor\DB_STATUS\DBstatus_Reports.txt
	Remove-Item F:\Monitor\DB_STATUS\Email_output_DB_Status.txt
	Remove-Item F:\Monitor\DB_STATUS\Email_output_DB_Status_history.txt
	Remove-Item F:\Monitor\DB_STATUS\Failures_log.txt
}

foreach ($srv in get-content F:\Monitor\SERVERNAME.txt)
{
 try
 {
     $objSQLConnection.ConnectionString = "Server=$srv;Integrated Security=SSPI;" 
     $objSQLConnection.Open() | Out-Null 
     write-host (get-date) + $srv
     $objSQLConnection.Close()
     invoke-expression "sqlcmd -E -S '$srv' -i F:\Monitor\DB_STATUS\Query_DBstatus.sql -s '|' -u -W -h -1 >> F:\Monitor\DB_STATUS\DBstatus_Reports.txt"
    
 }
 catch
 {
         $err = $Error[0].Exception ; 
            Write-Host -BackgroundColor Red -ForegroundColor White "Failed:" + (get-date) + $srv
         "Error caught: @" + (get-date) + " - " + $srv + " - " + $err.Message | out-File -filepath "F:\Monitor\DB_STATUS\Failures_log.txt" -append
         continue 
 }
}

##### EMAIL CONDITION DB STATUS #####

$COUNT = (Get-Content F:\Monitor\DB_STATUS\DBstatus_Reports.txt).count
IF ($Count -gt 0)
{
 	Write Host "Sending Email..."
 	write-host "File Count="$COUNT "Row(s)"
	invoke-expression "sqlcmd -E -S SSCVPIDERA01 -i F:\Monitor\DB_STATUS\DB_Status_SendMail.sql -s ',' -W -h -1 > F:\Monitor\DB_STATUS\Email_output_DB_Status.txt"
	get-date >> F:\Monitor\DB_STATUS\Email_output_DB_Status_history.txt
	get-content F:\Monitor\DB_STATUS\Email_output_DB_Status.txt >> F:\Monitor\DB_STATUS\Email_output_DB_Status_history.txt
[GC]::Collect()
} 
Else
{
 	Write Host "Not Send any email"..
 	write-host "File Count="$COUNT "Row(s)"
 	write-host " ********************************* "

}

#################################################################################################################################################################################

### REVIEW SERVERS LIST VLOGS ####

$FileExists = Test-Path F:\Monitor\VLOGS\Vlog_Reports.txt
if ($FileExists) 
{
 	Remove-Item F:\Monitor\VLOGS\Vlog_Reports.txt
	Remove-Item F:\Monitor\VLOGS\Email_output_Vlog.txt
	Remove-Item F:\Monitor\VLOGS\Email_output_Vlog_history.txt
	Remove-Item F:\Monitor\VLOGS\Failures_log.txt
}

foreach ($srv in get-content F:\Monitor\SERVERNAME.txt)
{
 try
 {
     $objSQLConnection.ConnectionString = "Server=$srv;Integrated Security=SSPI;" 
     $objSQLConnection.Open() | Out-Null 
     write-host (get-date) + $srv
     $objSQLConnection.Close()
     invoke-expression "sqlcmd -E -S '$srv' -i F:\Monitor\VLOGS\Query_VLOGS.sql -s '|' -u -W -h -1 >> F:\Monitor\VLOGS\Vlog_Reports.txt"
    
 }
 catch
 {
         $err = $Error[0].Exception ; 
            Write-Host -BackgroundColor Red -ForegroundColor White "Failed:" + (get-date) + $srv
         "Error caught: @" + (get-date) + " - " + $srv + " - " + $err.Message | out-File -filepath "F:\Monitor\VLOGS\Failures_log.txt" -append
         continue 
 }
}

##### EMAIL SERVERS LIST VLOGS #####

$COUNT = (Get-Content F:\Monitor\VLOGS\Vlog_Reports.txt).count
IF ($Count -gt 0)
{
 	Write Host "Sending Email..."
 	write-host "File Count="$COUNT "Row(s)"
	invoke-expression "sqlcmd -E -S SSCVPIDERA01 -i F:\Monitor\VLOGS\Vlog_SendMail.sql -s ',' -W -h -1 > F:\Monitor\VLOGS\Email_output_Vlog.txt "
	get-date >> F:\Monitor\VLOGS\Email_output_Vlog_history.txt
	get-content F:\Monitor\VLOGS\Email_output_Vlog.txt >> F:\Monitor\VLOGS\Email_output_Vlog_history.txt
[GC]::Collect()
} 
Else
{
 	Write Host "Not Send any email"..
 	write-host "File Count="$COUNT "Row(s)"
 	write-host " ********************************* "

}

#################################################################################################################################################################################

### REVIEW SERVERS LIST FullBkps ####

$FileExists = Test-Path F:\Monitor\FullBkps\Query_FullBkps_Reports.txt
if ($FileExists) 
{
 	Remove-Item F:\Monitor\FullBkps\Query_FullBkps_Reports.txt
	Remove-Item F:\Monitor\FullBkps\Email_output_DB_Status.txt
	Remove-Item F:\Monitor\FullBkps\Email_output_DB_Status_history.txt
	Remove-Item F:\Monitor\FullBkps\Failures_log.txt
}

foreach ($srv in get-content F:\Monitor\SERVERNAME.txt)
{
 try
 {
     $objSQLConnection.ConnectionString = "Server=$srv;Integrated Security=SSPI;" 
     $objSQLConnection.Open() | Out-Null 
     write-host (get-date) + $srv
     $objSQLConnection.Close()
     invoke-expression "sqlcmd -E -S '$srv' -i F:\Monitor\FullBkps\Query_FullBkps.sql -s '|' -u -W -h -1 >> F:\Monitor\FullBkps\Query_FullBkps_Reports.txt"
    
 }
 catch
 {
         $err = $Error[0].Exception ; 
            Write-Host -BackgroundColor Red -ForegroundColor White "Failed:" + (get-date) + $srv
         "Error caught: @" + (get-date) + " - " + $srv + " - " + $err.Message | out-File -filepath "F:\Monitor\FullBkps\Failures_log.txt" -append
         continue 
 }
}

##### EMAIL CONDITION FullBkps #####

$COUNT = (Get-Content F:\Monitor\FullBkps\Query_FullBkps_Reports.txt).count
IF ($Count -gt 0)
{
 	Write Host "Sending Email..."
 	write-host "File Count="$COUNT "Row(s)"
	invoke-expression "sqlcmd -E -S SSCVPIDERA01 -i F:\Monitor\FullBkps\DB_Status_SendMail.sql -s ',' -W -h -1 > F:\Monitor\FullBkps\Email_output_DB_Status.txt"
	get-date >> F:\Monitor\FullBkps\Email_output_DB_Status_history.txt
	get-content F:\Monitor\FullBkps\Email_output_DB_Status.txt >> F:\Monitor\FullBkps\Email_output_DB_Status_history.txt
[GC]::Collect()
} 
Else
{
 	Write Host "Not Send any email"..
 	write-host "File Count="$COUNT "Row(s)"
 	write-host " ********************************* "

}

#################################################################################################################################################################################

### REVIEW SERVERS LIST Tlog ####

$FileExists = Test-Path F:\Monitor\Tlogs\Query_tlogs_Reports.txt
if ($FileExists) 
{
 	Remove-Item F:\Monitor\Tlogs\Query_tlogs_Reports.txt
	Remove-Item F:\Monitor\Tlogs\Email_output_DB_Status.txt
	Remove-Item F:\Monitor\Tlogs\Email_output_DB_Status_history.txt
	Remove-Item F:\Monitor\Tlogs\Failures_log.txt
}

foreach ($srv in get-content F:\Monitor\SERVERNAME.txt)
{
 try
 {
     $objSQLConnection.ConnectionString = "Server=$srv;Integrated Security=SSPI;" 
     $objSQLConnection.Open() | Out-Null 
     write-host (get-date) + $srv
     $objSQLConnection.Close()
     invoke-expression "sqlcmd -E -S '$srv' -i F:\Monitor\Tlogs\Query_tlogs.sql -s '|' -u -W -h -1 >> F:\Monitor\Tlogs\Query_tlogs_Reports.txt"
    
 }
 catch
 {
         $err = $Error[0].Exception ; 
            Write-Host -BackgroundColor Red -ForegroundColor White "Failed:" + (get-date) + $srv
         "Error caught: @" + (get-date) + " - " + $srv + " - " + $err.Message | out-File -filepath "F:\Monitor\Tlogs\Failures_log.txt" -append
         continue 
 }
}

##### EMAIL CONDITION Tlog#####

$COUNT = (Get-Content F:\Monitor\Tlogs\Query_tlogs_Reports.txt).count
IF ($Count -gt 0)
{
 	Write Host "Sending Email..."
 	write-host "File Count="$COUNT "Row(s)"
	invoke-expression "sqlcmd -E -S SSCVPIDERA01 -i F:\Monitor\Tlogs\DB_Status_SendMail.sql -s ',' -W -h -1 > F:\Monitor\Tlogs\Email_output_DB_Status.txt"
	get-date >> F:\Monitor\Tlogs\Email_output_DB_Status_history.txt
	get-content F:\Monitor\Tlogs\Email_output_DB_Status.txt >> F:\Monitor\Tlogs\Email_output_DB_Status_history.txt
[GC]::Collect()
} 
Else
{
 	Write Host "Not Send any email"..
 	write-host "File Count="$COUNT "Row(s)"
 	write-host " ********************************* "

}

#################################################################################################################################################################################

### REVIEW SERVERS LIST TEMPDB ####

$FileExists = Test-Path F:\Monitor\Tempdb\Query_tempdb_Reports.txt
if ($FileExists) 
{
 	Remove-Item F:\Monitor\Tempdb\Query_tempdb_Reports.txt
	Remove-Item F:\Monitor\Tempdb\Email_output_DB_Status.txt
	Remove-Item F:\Monitor\Tempdb\Email_output_DB_Status_history.txt
	Remove-Item F:\Monitor\Tempdb\Failures_log.txt
}

foreach ($srv in get-content F:\Monitor\SERVERNAME.txt)
{
 try
 {
     $objSQLConnection.ConnectionString = "Server=$srv;Integrated Security=SSPI;" 
     $objSQLConnection.Open() | Out-Null 
     write-host (get-date) + $srv
     $objSQLConnection.Close()
     invoke-expression "sqlcmd -E -S '$srv' -i F:\Monitor\Tempdb\Query_tempdb.sql -s '|' -u -W -h -1 >> F:\Monitor\Tempdb\Query_tempdb_Reports.txt"
    
 }
 catch
 {
         $err = $Error[0].Exception ; 
            Write-Host -BackgroundColor Red -ForegroundColor White "Failed:" + (get-date) + $srv
         "Error caught: @" + (get-date) + " - " + $srv + " - " + $err.Message | out-File -filepath "F:\Monitor\Tempdb\Failures_log.txt" -append
         continue 
 }
}

##### EMAIL CONDITION TEMPDB #####

$COUNT = (Get-Content F:\Monitor\Tempdb\Query_tempdb_Reports.txt).count
IF ($Count -gt 0)
{
 	Write Host "Sending Email..."
 	write-host "File Count="$COUNT "Row(s)"
	invoke-expression "sqlcmd -E -S SSCVPIDERA01 -i F:\Monitor\Tempdb\DB_Status_SendMail.sql -s ',' -W -h -1 > F:\Monitor\Tempdb\Email_output_DB_Status.txt"
	get-date >> F:\Monitor\Tempdb\Email_output_DB_Status_history.txt
	get-content F:\Monitor\Tempdb\Email_output_DB_Status.txt >> F:\Monitor\Tempdb\Email_output_DB_Status_history.txt
[GC]::Collect()
} 
Else
{
 	Write Host "Not Send any email"..
 	write-host "File Count="$COUNT "Row(s)"
 	write-host " ********************************* "

}

#################################################################################################################################################################################

### REVIEW SERVERS LIST FILES FULL ####

$FileExists = Test-Path F:\Monitor\FilesFull\Query_FilesFull_Reports.txt
if ($FileExists) 
{
 	Remove-Item F:\Monitor\FilesFull\Query_FilesFull_Reports.txt
	Remove-Item F:\Monitor\FilesFull\Email_output_DB_Status.txt
	Remove-Item F:\Monitor\FilesFull\Email_output_DB_Status_history.txt
	Remove-Item F:\Monitor\FilesFull\Failures_log.txt
}

foreach ($srv in get-content F:\Monitor\SERVERNAME.txt)
{
 try
 {
     $objSQLConnection.ConnectionString = "Server=$srv;Integrated Security=SSPI;" 
     $objSQLConnection.Open() | Out-Null 
     write-host (get-date) + $srv
     $objSQLConnection.Close()
     invoke-expression "sqlcmd -E -S '$srv' -i F:\Monitor\FilesFull\Query_FilesFull.sql -s '|' -u -W -h -1 >> F:\Monitor\FilesFull\Query_FilesFull_Reports.txt"
    
 }
 catch
 {
         $err = $Error[0].Exception ; 
            Write-Host -BackgroundColor Red -ForegroundColor White "Failed:" + (get-date) + $srv
         "Error caught: @" + (get-date) + " - " + $srv + " - " + $err.Message | out-File -filepath "F:\Monitor\FilesFull\Failures_log.txt" -append
         continue 
 }
}

##### EMAIL CONDITION FILES FULL #####

$COUNT = (Get-Content F:\Monitor\FilesFull\Query_FilesFull_Reports.txt).count
IF ($Count -gt 0)
{
 	Write Host "Sending Email..."
 	write-host "File Count="$COUNT "Row(s)"
	invoke-expression "sqlcmd -E -S SSCVPIDERA01 -i F:\Monitor\FilesFull\DB_Status_SendMail.sql -s ',' -W -h -1 > F:\Monitor\FilesFull\Email_output_DB_Status.txt"
	get-date >> F:\Monitor\FilesFull\Email_output_DB_Status_history.txt
	get-content F:\Monitor\FilesFull\Email_output_DB_Status.txt >> F:\Monitor\FilesFull\Email_output_DB_Status_history.txt
[GC]::Collect()
} 
Else
{
 	Write Host "Not Send any email"..
 	write-host "File Count="$COUNT "Row(s)"
 	write-host " ********************************* "

}

#################################################################################################################################################################################	

### REVIEW SERVERS LIST MAX AUTO GROWTH ####

$FileExists = Test-Path F:\Monitor\MaxAutoGrowth\Query_MaxAG_Reports.txt
if ($FileExists) 
{
 	Remove-Item F:\Monitor\MaxAutoGrowth\Query_MaxAG_Reports.txt
	Remove-Item F:\Monitor\MaxAutoGrowth\Email_output_DB_Status.txt
	Remove-Item F:\Monitor\MaxAutoGrowth\Email_output_DB_Status_history.txt
	Remove-Item F:\Monitor\MaxAutoGrowth\Failures_log.txt
}

foreach ($srv in get-content F:\Monitor\SERVERNAME.txt)
{
 try
 {
     $objSQLConnection.ConnectionString = "Server=$srv;Integrated Security=SSPI;" 
     $objSQLConnection.Open() | Out-Null 
     write-host (get-date) + $srv
     $objSQLConnection.Close()
     invoke-expression "sqlcmd -E -S '$srv' -i F:\Monitor\MaxAutoGrowth\Query_MaxAG.sql -s '|' -u -W -h -1 >> F:\Monitor\MaxAutoGrowth\Query_MaxAG_Reports.txt"
    
 }
 catch
 {
         $err = $Error[0].Exception ; 
            Write-Host -BackgroundColor Red -ForegroundColor White "Failed:" + (get-date) + $srv
         "Error caught: @" + (get-date) + " - " + $srv + " - " + $err.Message | out-File -filepath "F:\Monitor\MaxAutoGrowth\Failures_log.txt" -append
         continue 
 }
}

##### EMAIL CONDITION MAX AUTOGROWTH #####

$COUNT = (Get-Content F:\Monitor\MaxAutoGrowth\Query_MaxAG_Reports.txt).count
IF ($Count -gt 0)
{
 	Write Host "Sending Email..."
 	write-host "File Count="$COUNT "Row(s)"
	invoke-expression "sqlcmd -E -S SSCVPIDERA01 -i F:\Monitor\MaxAutoGrowth\DB_Status_SendMail.sql -s ',' -W -h -1 > F:\Monitor\MaxAutoGrowth\Email_output_DB_Status.txt"
	get-date >> F:\Monitor\MaxAutoGrowth\Email_output_DB_Status_history.txt
	get-content F:\Monitor\MaxAutoGrowth\Email_output_DB_Status.txt >> F:\Monitor\MaxAutoGrowth\Email_output_DB_Status_history.txt
[GC]::Collect()
} 
Else
{
 	Write Host "Not Send any email"..
 	write-host "File Count="$COUNT "Row(s)"
 	write-host " ********************************* "

}

#################################################################################################################################################################################	

### REVIEW SERVERS LIST MIN AUTO GROWTH ####

$FileExists = Test-Path F:\Monitor\MinAutoGrowth\Query_MinAG_Reports.txt
if ($FileExists) 
{
 	Remove-Item F:\Monitor\MinAutoGrowth\Query_MinAG_Reports.txt
	Remove-Item F:\Monitor\MinAutoGrowth\Email_output_DB_Status.txt
	Remove-Item F:\Monitor\MinAutoGrowth\Email_output_DB_Status_history.txt
	Remove-Item F:\Monitor\MinAutoGrowth\Failures_log.txt
}

foreach ($srv in get-content F:\Monitor\SERVERNAME.txt)
{
 try
 {
     $objSQLConnection.ConnectionString = "Server=$srv;Integrated Security=SSPI;" 
     $objSQLConnection.Open() | Out-Null 
     write-host (get-date) + $srv
     $objSQLConnection.Close()
     invoke-expression "sqlcmd -E -S '$srv' -i F:\Monitor\MinAutoGrowth\Query_MinAG.sql -s '|' -u -W -h -1 >> F:\Monitor\MinAutoGrowth\Query_MinAG_Reports.txt"
    
 }
 catch
 {
         $err = $Error[0].Exception ; 
            Write-Host -BackgroundColor Red -ForegroundColor White "Failed:" + (get-date) + $srv
         "Error caught: @" + (get-date) + " - " + $srv + " - " + $err.Message | out-File -filepath "F:\Monitor\MinAutoGrowth\Failures_log.txt" -append
         continue 
 }
}

##### EMAIL CONDITION MIN AUTOGROWTH #####

$COUNT = (Get-Content F:\Monitor\MinAutoGrowth\Query_MinAG_Reports.txt).count
IF ($Count -gt 0)
{
 	Write Host "Sending Email..."
 	write-host "File Count="$COUNT "Row(s)"
	invoke-expression "sqlcmd -E -S SSCVPIDERA01 -i F:\Monitor\MinAutoGrowth\DB_Status_SendMail.sql -s ',' -W -h -1 > F:\Monitor\MinAutoGrowth\Email_output_DB_Status.txt"
	get-date >> F:\Monitor\MinAutoGrowth\Email_output_DB_Status_history.txt
	get-content F:\Monitor\MinAutoGrowth\Email_output_DB_Status.txt >> F:\Monitor\MinAutoGrowth\Email_output_DB_Status_history.txt
[GC]::Collect()
} 
Else
{
 	Write Host "Not Send any email"..
 	write-host "File Count="$COUNT "Row(s)"
 	write-host " ********************************* "

}

#################################################################################################################################################################################	

### REVIEW SERVERS LIST PERCENT AUTO GROWTH ####

$FileExists = Test-Path F:\Monitor\PercentGrowth\Query_PercentGrowth_Reports.txt
if ($FileExists) 
{
 	Remove-Item F:\Monitor\PercentGrowth\Query_PercentGrowth_Reports.txt
	Remove-Item F:\Monitor\PercentGrowth\Email_output_DB_Status.txt
	Remove-Item F:\Monitor\PercentGrowth\Email_output_DB_Status_history.txt
	Remove-Item F:\Monitor\PercentGrowth\Failures_log.txt
}

foreach ($srv in get-content F:\Monitor\SERVERNAME.txt)
{
 try
 {
     $objSQLConnection.ConnectionString = "Server=$srv;Integrated Security=SSPI;" 
     $objSQLConnection.Open() | Out-Null 
     write-host (get-date) + $srv
     $objSQLConnection.Close()
     invoke-expression "sqlcmd -E -S '$srv' -i F:\Monitor\PercentGrowth\Query_PercentGrowth.sql -s '|' -u -W -h -1 >> F:\Monitor\PercentGrowth\Query_PercentGrowth_Reports.txt"
    
 }
 catch
 {
         $err = $Error[0].Exception ; 
            Write-Host -BackgroundColor Red -ForegroundColor White "Failed:" + (get-date) + $srv
         "Error caught: @" + (get-date) + " - " + $srv + " - " + $err.Message | out-File -filepath "F:\Monitor\PercentGrowth\Failures_log.txt" -append
         continue 
 }
}

##### EMAIL CONDITION PERCENT AUTOGROWTH #####

$COUNT = (Get-Content F:\Monitor\PercentGrowth\Query_PercentGrowth_Reports.txt).count
IF ($Count -gt 0)
{
 	Write Host "Sending Email..."
 	write-host "File Count="$COUNT "Row(s)"
	invoke-expression "sqlcmd -E -S SSCVPIDERA01 -i F:\Monitor\PercentGrowth\DB_Status_SendMail.sql -s ',' -W -h -1 > F:\Monitor\PercentGrowth\Email_output_DB_Status.txt"
	get-date >> F:\Monitor\PercentGrowth\Email_output_DB_Status_history.txt
	get-content F:\Monitor\PercentGrowth\Email_output_DB_Status.txt >> F:\Monitor\PercentGrowth\Email_output_DB_Status_history.txt
[GC]::Collect()
} 
Else
{
 	Write Host "Not Send any email"..
 	write-host "File Count="$COUNT "Row(s)"
 	write-host " ********************************* "

}

#################################################################################################################################################################################	

### REVIEW SERVERS FILES GROUPS GETTING FULL ####

$FileExists = Test-Path F:\Monitor\FileGroups\Query_FileGroups_Reports.txt
if ($FileExists) 
{
 	Remove-Item F:\Monitor\FileGroups\Query_FileGroups_Reports.txt
	Remove-Item F:\Monitor\FileGroups\Email_output_DB_Status.txt
	Remove-Item F:\Monitor\FileGroups\Email_output_DB_Status_history.txt
	Remove-Item F:\Monitor\FileGroups\Failures_log.txt
}

foreach ($srv in get-content F:\Monitor\SERVERNAME.txt)
{
 try
 {
     $objSQLConnection.ConnectionString = "Server=$srv;Integrated Security=SSPI;" 
     $objSQLConnection.Open() | Out-Null 
     write-host (get-date) + $srv
     $objSQLConnection.Close()
     invoke-expression "sqlcmd -E -S '$srv' -i F:\Monitor\FileGroups\Query_FileGroups.sql -s '|' -u -W -h -1 >> F:\Monitor\FileGroups\Query_FileGroups_Reports.txt"
    
 }
 catch
 {
         $err = $Error[0].Exception ; 
            Write-Host -BackgroundColor Red -ForegroundColor White "Failed:" + (get-date) + $srv
         "Error caught: @" + (get-date) + " - " + $srv + " - " + $err.Message | out-File -filepath "F:\Monitor\FileGroups\Failures_log.txt" -append
         continue 
 }
}

##### EMAIL CONDITION FILES GROUPS GETTING FULL #####

$COUNT = (Get-Content F:\Monitor\FileGroups\Query_FileGroups_Reports.txt).count
IF ($Count -gt 0)
{
 	Write Host "Sending Email..."
 	write-host "File Count="$COUNT "Row(s)"
	invoke-expression "sqlcmd -E -S SSCVPIDERA01 -i F:\Monitor\FileGroups\DB_Status_SendMail.sql -s ',' -W -h -1 > F:\Monitor\FileGroups\Email_output_DB_Status.txt"
	get-date >> F:\Monitor\FileGroups\Email_output_DB_Status_history.txt
	get-content F:\Monitor\FileGroups\Email_output_DB_Status.txt >> F:\Monitor\FileGroups\Email_output_DB_Status_history.txt
[GC]::Collect()
} 
Else
{
 	Write Host "Not Send any email"..
 	write-host "File Count="$COUNT "Row(s)"
 	write-host " ********************************* "

}

#################################################################################################################################################################################	

### REVIEW SERVERS LONG HOLD LOCKS ####

$FileExists = Test-Path F:\Monitor\HoldLocks\Query_HoldLocks_Reports.txt
if ($FileExists) 
{
 	Remove-Item F:\Monitor\HoldLocks\Query_HoldLocks_Reports.txt
	Remove-Item F:\Monitor\HoldLocks\Email_output_DB_Status.txt
	Remove-Item F:\Monitor\HoldLocks\Email_output_DB_Status_history.txt
	Remove-Item F:\Monitor\HoldLocks\Failures_log.txt
}

foreach ($srv in get-content F:\Monitor\SERVERNAME.txt)
{
 try
 {
     $objSQLConnection.ConnectionString = "Server=$srv;Integrated Security=SSPI;" 
     $objSQLConnection.Open() | Out-Null 
     write-host (get-date) + $srv
     $objSQLConnection.Close()
     invoke-expression "sqlcmd -E -S '$srv' -i F:\Monitor\HoldLocks\Query_HoldLocks.sql -s '|' -u -W -h -1 >> F:\Monitor\HoldLocks\Query_HoldLocks_Reports.txt"
    
 }
 catch
 {
         $err = $Error[0].Exception ; 
            Write-Host -BackgroundColor Red -ForegroundColor White "Failed:" + (get-date) + $srv
         "Error caught: @" + (get-date) + " - " + $srv + " - " + $err.Message | out-File -filepath "F:\Monitor\HoldLocks\Failures_log.txt" -append
         continue 
 }
}

##### EMAIL CONDITION LONG HOLD LOCKS #####

$COUNT = (Get-Content F:\Monitor\HoldLocks\Query_HoldLocks_Reports.txt).count
IF ($Count -gt 0)
{
 	Write Host "Sending Email..."
 	write-host "File Count="$COUNT "Row(s)"
	invoke-expression "sqlcmd -E -S SSCVPIDERA01 -i F:\Monitor\HoldLocks\DB_Status_SendMail.sql -s ',' -W -h -1 > F:\Monitor\HoldLocks\Email_output_DB_Status.txt"
	get-date >> F:\Monitor\HoldLocks\Email_output_DB_Status_history.txt
	get-content F:\Monitor\HoldLocks\Email_output_DB_Status.txt >> F:\Monitor\HoldLocks\Email_output_DB_Status_history.txt
[GC]::Collect()
} 
Else
{
 	Write Host "Not Send any email"..
 	write-host "File Count="$COUNT "Row(s)"
 	write-host " ********************************* "

}

#################################################################################################################################################################################	

### REVIEW SERVERS LONG RUNNING QUERY ####

$FileExists = Test-Path F:\Monitor\LongQuery\Query_LongQuery_Reports.txt
if ($FileExists) 
{
 	Remove-Item F:\Monitor\LongQuery\Query_LongQuery_Reports.txt
	Remove-Item F:\Monitor\LongQuery\Email_output_DB_Status.txt
	Remove-Item F:\Monitor\LongQuery\Email_output_DB_Status_history.txt
	Remove-Item F:\Monitor\LongQuery\Failures_log.txt
}

foreach ($srv in get-content F:\Monitor\SERVERNAME.txt)
{
 try
 {
     $objSQLConnection.ConnectionString = "Server=$srv;Integrated Security=SSPI;" 
     $objSQLConnection.Open() | Out-Null 
     write-host (get-date) + $srv
     $objSQLConnection.Close()
     invoke-expression "sqlcmd -E -S '$srv' -i F:\Monitor\LongQuery\Query_LongQuery.sql -s '|' -u -W -h -1 >> F:\Monitor\LongQuery\Query_LongQuery_Reports.txt"
    
 }
 catch
 {
         $err = $Error[0].Exception ; 
            Write-Host -BackgroundColor Red -ForegroundColor White "Failed:" + (get-date) + $srv
         "Error caught: @" + (get-date) + " - " + $srv + " - " + $err.Message | out-File -filepath "F:\Monitor\LongQuery\Failures_log.txt" -append
         continue 
 }
}

##### EMAIL CONDITION LONG RUNNING QUERY #####

$COUNT = (Get-Content F:\Monitor\LongQuery\Query_LongQuery_Reports.txt).count
IF ($Count -gt 0)
{
 	Write Host "Sending Email..."
 	write-host "File Count="$COUNT "Row(s)"
	invoke-expression "sqlcmd -E -S SSCVPIDERA01 -i F:\Monitor\LongQuery\DB_Status_SendMail.sql -s ',' -W -h -1 > F:\Monitor\LongQuery\Email_output_DB_Status.txt"
	get-date >> F:\Monitor\LongQuery\Email_output_DB_Status_history.txt
	get-content F:\Monitor\LongQuery\Email_output_DB_Status.txt >> F:\Monitor\LongQuery\Email_output_DB_Status_history.txt
[GC]::Collect()
} 
Else
{
 	Write Host "Not Send any email"..
 	write-host "File Count="$COUNT "Row(s)"
 	write-host " ********************************* "

}

#################################################################################################################################################################################	