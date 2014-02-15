#example 1:

Add-Type -Path C:\EWS\Microsoft.Exchange.WebServices.dll

$svc = New-Object `
-TypeName Microsoft.Exchange.WebServices.Data.ExchangeService

$svc.AutoDiscoverUrl(�administrator@contoso.com�)

$msg = New-Object `
-TypeName Microsoft.Exchange.WebServices.Data.EmailMessage `
-ArgumentList $svc

$msg.Subject = "Test E-Mail"
$msg.Body = "This is a test"
$msg.From = �administrator@contoso.com�
$msg.ToRecipients.Add("sysadmin@contoso.com")
$msg.SendAndSaveCopy()


#example 2:

$to = �sysadmin@contoso.com�,�IT@contoso.com�,�help@contoso.com�
$to | ForEach-Object {$msg.ToRecipients.Add($_)}


#example 3:

$msg.ToRecipients.Add(�sales@contoso.com�) | Out-Null


#example 4:

$msg.CcRecipients.Add(�sales@contoso.com�) | Out-Null
$msg.BccRecipients.Add(�dmsith@contoso.com�) | Out-Null


#example 5:

$msg.Send()


#example 6:

function Send-EWSMailMessage {
  param(
  [Parameter(
    Position=0,
    Mandatory=$true,
    ValueFromPipelineByPropertyName=$true
  )]
  [String[]]
  $PrimarySmtpAddress,

  [Parameter(
    Position=1, Mandatory=$true
  )]
  [String]
  $From,					

  [Parameter(
    Position=2, Mandatory=$true
  )]
  [String]
  $Subject,

  [Parameter(
    Position=3, Mandatory=$true
  )]
  [String]
  $Body,
  
  [Parameter(
    Position=4, Mandatory=$false
  )]
  [String[]]
  $Cc,
  
  [Parameter(
    Position=5, Mandatory=$false
  )]
  [String[]]
  $Bcc
  
  )

  begin {
    Add-Type -Path C:\EWS\Microsoft.Exchange.WebServices.dll
  }

  process {	
    $svc = New-Object `
    -TypeName Microsoft.Exchange.WebServices.Data.ExchangeService
    
    $svc.AutodiscoverUrl($From)

    $msg = New-Object `
    -TypeName Microsoft.Exchange.WebServices.Data.EmailMessage `
    -ArgumentList $svc
    
    $msg.Subject = $Subject
    $msg.Body = $Body

    $PrimarySmtpAddress | %{ $msg.ToRecipients.Add($_) | Out-Null }
	
	if ($Cc -ne $null)
	{
		$msg.CcRecipients.Add($Cc) | Out-Null
	}
	
	if ($Bcc -ne $null)
	{
		$msg.BccRecipients.Add($Bcc) | Out-Null
	}

    $msg.SendAndSaveCopy()
  }
}


#example 7:

Get-Mailbox -OrganizationalUnit contoso.com/sales | 
  Send-EWSMailMessage -From administrator@contoso.com `
  -Subject 'Sales Meeting' `
  -Body 'Tomorrows sales meeting has been cancelled' `
  -Cc administrator@contoso.com `
  -Bcc manager@contoso.com


#example 8:

Send-EWSMailMessage -From administrator@contoso.com `
-PrimarySmtpAddress helpdesk@contoso.com,afinley@contoso.com `
-Subject 'Critical alert on MBX01' `
-Body 'MBX01 Server is low on disk space'
-Cc itmanager@contoso.com
