# Install-Module -Name AzureAD
# Import-Module -Name AzureAD
# Connect-AzureAD

# Define the group and users
$groupName = "YourGroup"

# Define the path to your CSV file
$csvPath = "C:\path\to\your\data.csv"

# Import the CSV file
$data = Import-Csv -Path $csvPath

# Display the imported data
$data

# Get the group's ObjectId
$group = Get-AzureADGroup -Filter "DisplayName eq '$groupName'"
if ($group -eq $null) {
    Write-Output "Group '$groupName' not found."
    exit
}
$groupId = $group.ObjectId
#Write-Host $groupId

# This checks for empty rows and removes users
foreach ($row in $data) {
    if (-not [string]::IsNullOrEmpty($row.UserPrincipalName) -and -not [string]::IsNullOrEmpty($row.Action)) {

        try {
            Write-Output "Ouutput: Email: $($row.UserPrincipalName), Action: $($row.Action)"
            
            # Get the user ID based on the email address
            $user = Get-AzureADUser -Filter "UserPrincipalName eq '$($row.UserPrincipalName)'"
            if ($user -eq $null) {
                Write-Output "User '$($row.UserPrincipalName)' not found."
                continue
            }
            $userId = [string]$user.ObjectId
            Write-Host $userId

            # Remove the user from the group
            Remove-AzureADGroupMember -ObjectId $groupId -MemberId $userId

            Write-Output "Successfully removed $($row.UserPrincipalName) from the group."
            
        } catch {
            Write-Output "Failed to remove $($row.UserPrincipalName) from the group. Error: $_"
        }
    } else {
        continue
    }
}