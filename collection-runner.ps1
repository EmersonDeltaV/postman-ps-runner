param (
    [string]$apiKey,
    [string]$collectionId,
    [string]$environmentId,
    [string]$workspaceId,
    [string]$systemName,
	[string]$notificationUrl,
	[string]$outputDirectory,
	[boolean]$addSuffix
)

# Define the Postman API endpoints
$collectionUrl = "https://api.getpostman.com/collections/$collectionId"
$environmentUrl = "https://api.getpostman.com/environments/$environmentId"
$globalVariablesUrl = "https://api.getpostman.com/workspaces/$workspaceId/global-variables?apikey=$apiKey"

# Define the output file names
$collectionFile = "collection.json"
$environmentFile = "environment.json"
$globalVariablesFile = "globals.json"

$junitFilename = "JUnitReport.xml"
$jsonSummaryFilename = "Summary.json"

[int]$epochTime = Get-Date -UFormat %s
$epochTime = $epochTime * 1000
Write-Output $epochTime

if($addSuffix -eq $true)
{
	$currentTime = Get-Date
	[string]$fileSufix = $currentTime.ToString("-yyyyMMdd_HHmm")

	$junitFilename = "JUnitReport-" + $systemName + $fileSufix + ".xml"
	$jsonSummaryFilename = "Summary-" + $systemName + $fileSufix + ".json"
}

if(-not [string]::IsNullOrEmpty($outputDirectory))
{
	$collectionFile = Join-Path -Path $outputDirectory -ChildPath $collectionFile
	$environmentFile = Join-Path -Path $outputDirectory -ChildPath $environmentFile
	$globalVariablesFile = Join-Path -Path $outputDirectory -ChildPath $globalVariablesFile
	$junitFilename = Join-Path -Path $outputDirectory -ChildPath $junitFilename
	$jsonSummaryFilename = Join-Path -Path $outputDirectory -ChildPath $jsonSummaryFilename
}

# Download the collection
Invoke-RestMethod -Uri $collectionUrl -Headers @{ "X-Api-Key" = $apiKey } | ConvertTo-Json -Depth 100 | Out-File $collectionFile

# Download the environment
Invoke-RestMethod -Uri $environmentUrl -Headers @{ "X-Api-Key" = $apiKey } | ConvertTo-Json -Depth 100 | Out-File $environmentFile

# Download the environment
Invoke-RestMethod -Uri $globalVariablesUrl | ConvertTo-Json -Depth 100 | Out-File $globalVariablesFile

# Run Newman with the specified parameters
newman run $collectionFile -e $environmentFile -g $globalVariablesFile -r junit --reporter-junit-export $junitFilename -k

# Print a success message
Write-Host "Collection and environment downloaded successfully. Collection saved as $collectionFile, environment saved as $environmentFile."
Write-Host "Newman run completed. JUnit report exported as $junitFilename"


# READING THE JUNITREPORT.XML
[xml]$xml = Get-Content -Path $junitFilename

$totalTests = 0
$failedTests = 0
$failedTestList = ""

# Iterate through the test cases
foreach ($testsuite in $xml.testsuites.testsuite) {
    $totalTests += [int]$testsuite.tests
    foreach ($testcase in $testsuite.testcase) {
        if ($testcase.failure) {
            $failedTests++
            $failedTestList += $testcase.name + "<br/>"
        }
    }
}

# Create a summary object
$summary = @{
    TotalTests = $totalTests
    FailedTests = $failedTests
    FailedTestList = $failedTestList
    System = $systemName
    Datetime = $epochTime
}

# Convert the summary object to JSON and save it to a file
$summary | ConvertTo-Json | Set-Content -Path $jsonSummaryFilename


Write-Output "Summary saved to $jsonSummaryFilename"

# SEND NOTIFICATION
if ($failedTests -ge 1 -and -not [string]::IsNullOrEmpty($notificationUrl)) {
    $jsonContent = Get-Content -Path $jsonSummaryFilename -Raw
    Invoke-RestMethod -Uri $notificationUrl -Method Post -Body $jsonContent -ContentType "application/json"
    Write-Output "Result Summary sent to notificationUrl"
}
else {
    Write-Output "Skipped Sending Notification: No failed tests or notificationUrl not provided"
}