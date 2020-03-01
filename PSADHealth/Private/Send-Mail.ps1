function Send-Mail {
    [cmdletBinding()]
    Param(
        [Parameter(Mandatory,ValueFromPipeline)]
        [String]
        $emailOutput,

        [string]
        $emailSubject = "Notification PSADHealth",

        [switch]
        $BodyAsHtml

    )
    
    Write-Verbose "Sending Email"
    Write-eventlog -LogName "Application" -Source "PSMonitor" -EventID 17034 -EntryType Information -message "ALERT Email Sent" -category "17034"
    Write-Verbose "Output is --  $emailOutput"
  
    # Get mail parameters
    $configuration = Get-ADConfig

    $MailFrom = $configuration.MailFrom
    $MailTo = $Configuration.MailTo -as [string[]]
    $SmtpServer = $configuration.SMTPServer
    $SmtpPort = $configuration.SMTPPort

    # Load module for credentials if authentification is required
    $useSsl = $configuration.SMTPUseSsl
    if ($useSsl) {
        try {
            Import-Module CredentialManager
        }
        catch {
            $errorMsg = "Unable to load module CredentialManager"
            Write-Verbose -Message $errorMsg
            Write-Error -Exception $_
            Write-EventLog -LogName "Application" -Source "PSMonitor" -EventID 17060 -EntryType Error -Message $errorMsg -Category "17060"
            $useSsl = $false
        }
    }

    # Load credentials
    if ($useSsl) {
        try {
            $c = (Get-StoredCredential -Target $configuration.MailCredentialToken).GetNetworkCredential()
            $cobj = [pscredential]::new($c.UserName, $c.SecurePassword)
        }
        catch {
            $errorMsg = "Unable to load credentails for SMTP - CredentialManager"
            Write-Verbose -Message $errorMsg
            Write-Error -Exception $_
            Write-EventLog -LogName "Application" -Source "PSMonitor" -EventID 17061 -EntryType Error -Message $errorMsg -Category "17061"
            $useSsl = $false
        }
    }
    
    Write-Verbose -Message "Try to send mail (UseSsl: $useSsl)..."
    try {
        if ($useSsl) {
            Send-MailMessage -Subject $emailSubject -Body $emailOutput -From $MailFrom -To $MailTo -SmtpServer $SmtpServer -Port $SmtpPort -UseSsl -Credential $cobj -BodyAsHtml:($BodyAsHtml)
        }
        else {
            Send-MailMessage -Subject $emailSubject -Body $emailOutput -From $MailFrom -To $MailTo -SmtpServer $SmtpServer -Port $SmtpPort -BodyAsHtml:($BodyAsHtml)
        }
        Write-Verbose -Message "... success!"
    }
    catch {
        Write-Verbose -Message "... failure!"
        Write-Error -Exception $_
        Write-EventLog -LogName "Application" -Source "PSMonitor" -EventID 17062 -EntryType Error -Message "ALERT - email can't be sent!" -Category "17062"
    }
   
}