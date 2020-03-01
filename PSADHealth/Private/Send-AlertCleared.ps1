function Send-AlertCleared {
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

    Send-Mail -emailOutput $emailOutput -emailSubject "AlertCleared - $emailSubject" -BodyAsHtml:($BodyAsHtml)
}