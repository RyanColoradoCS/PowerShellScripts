# Install-Module -Name AzureAD
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
# Write-Host $groupId

# This checks for empty rows
foreach ($row in $data) {
    if (-not [string]::IsNullOrEmpty($row.EmailAddress) -and -not [string]::IsNullOrEmpty($row.Action)){

        # Write-Host "Row not empty"
        
        try {

            Write-Output "Output: Email: $($row.EmailAddress), Action: $($row.Action))"

            # Get the user ID based on the email address
            $user = Get-AzureADUser -Filter "UserPrincipalName eq '$($row.EmailAddress)'"
            if ($user -eq $null) {
                Write-Output "User '$($row.EmailAddress)' not found."
                continue
            }
            $userId = [string]$user.ObjectId
            Write-Host $userId

            # Add the user to the group
            Add-AzureADGroupMember -ObjectId $groupID -RefObjectId $userId

            Write-Output "Successfully added $($row.EmailAddress) from the group."
        } catch{
            Write-Output "Failed to add $($row.EmailAddress) to the group. Error: $_"
        }
    }
    else{
        continue
    }
}