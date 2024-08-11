# Introduction

This PowerShell script runs a Postman collection using the specified environment and workspace's global variable, generates a JUnitReport.xml, summarizes it, saves it into a JSON file, and then sends the JSON summary file to a notification URL.

# Prerequisite

## Softwares

The system that runs this PowerShell script should have the following software installed:
1. npm: Install it using the Node.js installer available on the cloud.
2. newman: Install it using `npm install newman -g`.
3. newman-reporter-junitfull: Install it using `npm install newman-reporter-junitfull -g`.

## Parameters

The PowerShell script requires the following parameters:

1. `apiKey`: A Postman API key. Get it from your Postman account.
2. `collectionId`: The ID of the Postman collection you would like to run.
3. `environmentId`: The ID of the Postman environment you would like to use.
4. `workspaceId`: The ID where the Postman collection is located. This will be used to download the global variables to be used.
5. `systemName`: A reference to the environment being used. Readable name of the environment ID.
6. `notificationUrl`: (optional) A POST endpoint that accepts a JSON body. This is where the JSON summary will be sent.
7. `outputDirectory`: (optional) The directory where all generated and downloaded files will be stored.
8. `addSuffix`: (optional) \[boolean\], Indicated whether there is a date and time suffix of the generated files `JUnitReport.xml` and `Summary.json`. Suffix format: `_<systemName>_yyyyMMdd_HHmm` example: `JUnitReport_TEST-01_20240810_1452.xml`

# How to Run

To run the PowerShell script, execute the following command:
## Simple
`.\collection-runner.ps1 -apiKey "PMAK-66b1b8ae71xxxxxxxx3a2277-7bexxxxxa27841e492xxxxxxxxxxb6eee5" -collectionId "32379480-dxxxxx72-1d40-4ef3-b102-xxxxxxxx3bf0" -environmentId "32xxx480-xxxxxxxx-25f2-4ca8-xxx-139xxx542f8" -workspaceId "1a63ce0e-xxxx-43a2-9251-xxxxxxx5ce9c" -systemName "TEST-01"`

### Complete

`.\collection-runner.ps1 -apiKey "PMAK-66b1b8ae71xxxxxxxx3a2277-7bexxxxxa27841e492xxxxxxxxxxb6eee5" -collectionId "32379480-dxxxxx72-1d40-4ef3-b102-xxxxxxxx3bf0" -environmentId "32xxx480-xxxxxxxx-25f2-4ca8-xxx-139xxx542f8" -workspaceId "1a63ce0e-xxxx-43a2-9251-xxxxxxx5ce9c" -systemName "TEST-01" -notificationUrl "https://www.example.com/test-result" -outputDirectory ".\results" -addSuffix 1`