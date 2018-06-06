### POWERSHELL ###

### REMOVE OLD SERVERS LIST ###

#$FileExists = Test-Path F:\Monitor\SERVERNAME.txt
#if ($FileExists) 
#{
# 	Remove-Item F:\Monitor\SERVERNAME.txt
#}

#################################################################################################################################################################################

### CREATE SERVERS NAME FILE ###

#invoke-expression "sqlcmd -E -S SSCVPIDERA01 -i F:\Monitor\GetServers.sql -s ',' -W -h -1 > F:\Monitor\SERVERNAME.txt"
#	$x = get-content F:\Monitor\SERVERNAME.txt
#	$x[1..$x.count] | set-content F:\Monitor\SERVERNAME.txt 
#	$FILE = Get-Content F:\Monitor\SERVERNAME.txt 
#	$output = $FILE[0..($FILE.count - 3)] > SERVERNAME.txt

#################################################################################################################################################################################

### REVIEW SERVERS LONG RUNNING JOBS CYCLE ####


$FileExists = Test-Path F:\Monitor\LongRunningJobs\Longrunning_Report.txt
if ($FileExists) 
{
 	Remove-Item F:\Monitor\LongRunningJobs\Longrunning_Report.txt
    Remove-Item F:\Monitor\LongRunningJobs\Longrunning_Operators.txt
}

$objSQLConnection = New-Object System.Data.SqlClient.SqlConnection

foreach ($srv in get-content F:\Monitor\LongRunningJobs\SERVERNAME.txt)
{
 try
 {
     $objSQLConnection.ConnectionString = "Server=$srv;Integrated Security=SSPI;" 
     $objSQLConnection.Open() | Out-Null 
     write-host (get-date) + $srv
     $objSQLConnection.Close()
     invoke-expression "sqlcmd -E -S '$srv' -i F:\Monitor\LongRunningJobs\Longrunning.sql -s '|' -u -W -h -1 >> F:\Monitor\LongRunningJobs\Longrunning_report.txt" 
     invoke-expression "sqlcmd -E -S '$srv' -i F:\Monitor\LongRunningJobs\get_Operators.sql -s '|' -u -W -h -1 >> F:\Monitor\LongRunningJobs\Longrunning_Operators.txt"
    
 }
 catch
 {
         $err = $Error[0].Exception ; 
            Write-Host -BackgroundColor Red -ForegroundColor White "Failed:" + (get-date) + $srv
         "Error caught: @" + (get-date) + " - " + $srv + " - " + $err.Message | out-File -filepath "F:\Monitor\LongRunningJobs\Failures_log.txt" -append
         continue 
 }
}

##### EMAIL CONDITION LONG RUNNIG JOB #####

$COUNT = (Get-Content F:\Monitor\LongRunningJobs\Longrunning_Report.txt).count
IF ($Count -gt 0)
{
 	Write Host "Sending Email..."
 	write-host "File Count="$COUNT "Row(s)"
	invoke-expression "sqlcmd -E -S SSCVPIDERA01 -i F:\Monitor\LongRunningJobs\Longrunning_SendMail.sql -s ',' -W -h -1 > F:\Monitor\LongRunningJobs\Email_output_Longrunning.txt"
	get-date >> F:\Monitor\LongRunningJobs\Email_output_Longrunning_history.txt
	get-content F:\Monitor\LongRunningJobs\Email_output_Longrunning.txt >> F:\Monitor\LongRunningJobs\Email_output_Longrunning_history.txt
[GC]::Collect()
} 
ELSE
{
 	Write Host "Not Send any email"..
 	write-host "File Count="$COUNT "Row(s)"
 	write-host " ********************************* "

}
