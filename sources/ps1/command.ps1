add-pssnapin sqlserverprovidersnapin100 -ErrorAction silentlycontinue
add-pssnapin sqlservercmdletsnapin100 -ErrorAction silentlycontinue
import-module sqlps -DisableNameChecking -ErrorAction SilentlyContinue

$DBServer = $args[0]
$DB = $args[1]

$col = @()
$finalCol = @()
$count = $args[2]

$workperiod = Invoke-Sqlcmd -Query "select top 1 * from  WorkPeriods order by id desc" -ServerInstance $DBServer -Database $DB -username "sa" -password "samba.123"
$startDate = ($workperiod.StartDate).ToString("yyyy-MM-dd HH:mm:ss") 
$endDate = ($workperiod.EndDate).ToString("yyyy-MM-dd HH:mm:ss") 

#Invoke-Sqlcmd -Query "Select * from Tickets where Date > '$startDate' and  Date < '$endDate'" -ServerInstance $DBServer -Database $DB -username "sa" -password "samba.123" | foreach { [array]$col += $_.Id }
Invoke-Sqlcmd -Query "Select * from Tickets where Date > '$startDate'" -ServerInstance $DBServer -Database $DB -username "sa" -password "samba.123" | foreach { [array]$col += $_.Id }


foreach ($id in $col) {

  $c = Invoke-Sqlcmd -Query "Select *  from AccountTransactions where Name like '%Cash%' and AccountTransactionDocumentId = $id" -ServerInstance $DBServer -Database $DB -username "sa" -password "samba.123"
  $transactionCount =  Invoke-Sqlcmd -Query "Select *  from AccountTransactions where  AccountTransactionDocumentId = $id" -ServerInstance $DBServer -Database $DB -username "sa" -password "samba.123"
  if (($c -ne $null) -and $transactionCount.count -le 2) {
    $finalCol += $id
  }

}

$select = Get-random  $finalCol -count $count

foreach ($i in $select) {
  $query = @"
delete from Orders where TicketId = $i
delete from Calculations where TicketId = $i
delete from TicketEntities where Ticket_Id = $i
delete from Calculations where TicketId= $i
delete from PaidItems where TicketId = $i
delete from Payments where TicketId = $i
delete from Orders where TicketId = $i
delete from Tickets where Id = $i
delete from  AccountTransactions where AccountTransactionDocumentId = $i
"@
 
  Invoke-Sqlcmd -Query $query -ServerInstance $DBServer -Database $DB -username "sa" -password "samba.123"   
  
}


