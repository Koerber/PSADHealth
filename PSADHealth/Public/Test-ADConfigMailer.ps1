function Test-ADConfigMailer {


    begin { $null = Get-ADConfig }


    process {
        Send-Mail -emailOutput "If you can read this, your scripts can alert via email!" -emailSubject "Testing PSADHealth Mail Capability"
    }
    
}