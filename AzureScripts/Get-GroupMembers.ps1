# Install-Module -Name AzureAD
# Connect to Microsoft 365
Connect-AzureAD

# Define the group name or ID
$groupName = "Enter_Group_Name"

# Get the group object using the exact group name
$group = Get-AzureADGroup -Filter "DisplayName eq '$groupName'"

$members = Get-AzureADGroupMember -ObjectId $group.ObjectId -All $true

# Create an array to store member details
$memberDetails = @()

# Loop through each member and add their details to the array
foreach ($member in $members) {
    
    # Output user info for trouble shooting
    #Write-Host $member.DisplayName
    #Write-Host $member.UserPrincipalName
    #Write-Host $member.Mail

    # Create custom object for outputting to csv file
    $memberDetails += [PSCustomObject]@{
        DisplayName = $member.DisplayName
        UserPrincipalName = $member.UserPrincipalName
        Email = $member.Mail
    }
}

# Export the member details to a CSV file
$memberDetails | Export-Csv -Path "Path\To\File\GroupMembers.csv" -NoTypeInformation

# Disconnect from Microsoft 365
Disconnect-AzureAD