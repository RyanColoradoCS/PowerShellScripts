# Define the path to your CSV file
$csvPath = "C:\path\to\your\data.csv"

# Import the CSV file
$data = Import-Csv -Path $csvPath

# Display the imported data
$data

# Access specific columns
<#
foreach ($row in $data) {
    Write-Output "Name: $($row.Name), Age: $($row.Age), City: $($row.City)"
}
#>

# This checks for empty rows
foreach ($row in $data) {
    if (-not [string]::IsNullOrEmpty($row.EmailAddress) -and -not [string]::IsNullOrEmpty($row.Action)){
        Write-Output "Output: Email: $($row.EmailAddress), Age: $($row.Action))"
    }
    else{
        continue
    }
}