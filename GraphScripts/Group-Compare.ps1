# Install MS Graph and connect
# Install-Module Microsoft.Graph -Scope CurrentUser
# Connect-MgGraph -Scopes "Group.Read.All", "User.Read.All"


# Get the group ID by name
# PA-Oreland-2-0085-SG-Licensing
# $group = Get-MgGroup -Filter "displayName eq 'Your Group Name'"
$group = Get-MgGroup -Filter "displayName eq 'Your Group Name'"

# Get members of the group
$users = Get-MgGroupMember -GroupId $group.Id

# test it worked
# it does!

# array to store emails from the Azure Group
$groupEmails = @()


foreach ($user in $users) {
    # Get-MgGroupMember returns a generic DirectoryObject, so need to use Get-MgUser 
    $user = Get-MgUser -UserId $user.Id -Property ProxyAddresses, DisplayName, UserPrincipalName
    
    # Get all email addresses
    $smtpAddresses = $user.ProxyAddresses | Where-Object { $_ -like "SMTP:*" -or $_ -like "smtp:*" }
    # Write-Host "Name: $($user.DisplayName), UPN: $($user.UserPrincipalName), Emails: "
    # Add UPN to emails
    $groupEmails += $user.UserPrincipalName
    
    # can probably exclude onmicrosoft.com, but no need really
    foreach ($smtp in $smtpAddresses) {
        # Write-Host "- $smtp"
        # Clean the address string and remove "SMTP:" or "smtp:"
        $cleanAddress = $smtp -replace "^SMTP:", "" -replace "^smtp:", ""
        # Add to the array
        $groupEmails += $cleanAddress
    }
    #Write-Host ""

}

# Get users from CSV file
# $csvData = Import-Csv -Path "C:\Path\To\Your\File.csv"
$csvData = Import-Csv -Path "C:\Users\RyanYoung\Documents\Employee_IT_Census_-_Azure.csv"

# test it worked
# it does!
<#
foreach ($row in $csvData) {
    # Write-Host "Name: $($row.PreferredName), Email: $($row.WorkEmail)"
}
#>

# Create an array to hold custom PS objects
$results = @()

# Compare users to group
foreach ($row in $csvData) {
    $email = $row.WorkEmail.Trim().ToLower()
    $existsInGroup = $groupEmails -contains $email

    # Check if the need to be added to group
    if ($groupEmails -contains $email) {
        Write-Host "$($row.PreferredName) <$email> exists in the group."
    } else {
        Write-Host "$($row.PreferredName) <$email> does NOT exist in the group."
    }

    # Check if user exists in Azure AD
    $azureUser = Get-MgUser -Filter "userPrincipalName eq '$email'"

    if ($azureUser) {
        $existsInTenant = $true
    } else {
        $existsInTenant = $false
}


    # Create a custom object
    $obj = [PSCustomObject]@{
        Name           = $row.PreferredName
        WorkEmail      = $email
        ExistsInGroup  = $existsInGroup
        ExistsInTenant = $existsInTenant
    }
    # Add to results array
    $results += $obj

}

# Outpute the remaining users to a CSV file
$results | Export-Csv -Path "C:\Users\RyanYoung\Documents\GroupMembershipCheck.csv" -NoTypeInformation
