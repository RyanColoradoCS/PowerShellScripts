
# Install-Module Microsoft.Graph -Scope CurrentUser -Force
# Connect-MgGraph -Scopes "User.Read.All"  

# Define department name
$DepartmentName = "Department Name"

# Build the filter string correctly
$filter = "department eq '$DepartmentName'"

# Get users with that department
$users = Get-MgUser -Filter $filter -Property displayName,mail,userPrincipalName,givenName,surname,jobTitle -All |
         Select-Object displayName,mail,userPrincipalName,givenName,surname,jobTitle

# Output user principal names
foreach ($user in $users) {
    $upn = $user.userPrincipalName
    Write-Host "$upn"
}
