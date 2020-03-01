Function Test-DCsOnline {
    [cmdletBinding()]
    Param()

    Begin {
        Import-Module ActiveDirectory
        #Creates a global $configuration variable
        $null = Get-ADConfig
    }

    Process {
        $DClist = (get-adgroupmember "Domain Controllers").name

        ForEach ($server in $DClist){

            if  ((!(Test-Connection -ComputerName $Server -quiet -count 4)))
            {
                $Subject = "Server $Server is offline"
                $EmailBody = @"


        Server named <font color="Red"><b> $Server </b></font> is offline!
        Time of Event: <font color="Red"><b> $((get-date))</b></font><br/>
        <br/>
        THIS EMAIL WAS AUTO-GENERATED. PLEASE DO NOT REPLY TO THIS EMAIL.
"@

                Send-Mail -emailOutput $EmailBody -emailSubject $Subject -BodyAsHtml

            } #End if
        }#End Foreach
    }
    End {}
}