# This is for cloud only Azure accounts

# Define the path to your CSV file
# $csvPath = "C:\path\to\your\data.csv"

# Import the CSV file
$data = Import-Csv -Path $csvPath

# Display the imported data
$data

# How to access specific columns of a CSV in PowerShell
<#
foreach ($row in $data) {
    Write-Output "Name: $($row.Name), Age: $($row.Age), City: $($row.City)"
}
#>

# This checks for empty values in the first 2 columns
foreach ($row in $data) {
    if (-not [string]::IsNullOrEmpty($row.UPN) -and -not [string]::IsNullOrEmpty($row.PrimarySMTP)){
        Write-Host "Output: UPN: $($row.UPN) changing to new primary email: $($row.PrimarySMTP)"

        <#
        # Get everything before '@' if you need the same first part
        $username = $row.EmailAddress -split "@" | Select-Object -First 1
        Write-Output $username
        #>
        
        # Get secondary emails
        $proxyAddresses = $row.SecondarySMTPs -split ","
        # Formatting: Proxy addresses must be prefixed correctly and formatted as valid SMTP addresses
        $formattedProxyAddresses = $proxyAddresses | ForEach-Object { "smtp:$($_.Trim())" }
        Write-Host "Proxy emails:"
        Write-Host $proxyAddresses
        Write-Host $formattedProxyAddresses
        
        # Use UPN with Get-Mailbox
        Write-Host "Getting mailbox information..."
        Get-Mailbox -Identity $row.UPN | Select-Object -ExpandProperty EmailAddresses

        # Set the primary SMTP address for the user
        #Set-Mailbox -Identity "UserIdentity" -PrimarySmtpAddress "newemail@domain.com"

        # Set the primary SMTP address for the user
        # This changes the primary address to the value you specify, while preserving the old one as a secondary
        Set-Mailbox -Identity $row.UPN -WindowsEmailAddress $row.PrimarySMTP
        Set-Mailbox -Identity $row.UPN -EmailAddresses @{add=$formattedProxyAddresses}
        
        
    }
    else{
        Write-Output "Output: Email: $($row.UPN) updating to Domain: $($row.PrimarySMTP) failed."
        continue
    }
}

