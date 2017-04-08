param(
    [Switch]
    $Finalize
)

$modulePath = $PSScriptRoot
$moduleName = $modulePath | Split-Path -Leaf

$pesterPaths = @(
    @{
        Path = ".\$moduleName.Tests.ps1"
    } ,

    @{
        Path = '.\Private'
        Parameters = @{
            Module = $Global:TestModule
        }
    } ,

    @{
        Path = '.\Public'
        Parameters = @{
            Module = $Global:TestModule
        }
    }
)

$params = @{
    Path = $pesterPaths
}

if ($Finalize) {
    $params.OutputFormat = 'NUnitXml'
    $params.OutputFile = 'TestResults.xml'
}

$res = Invoke-Pester @params -PassThru

if ($Finalize) {
    (New-Object 'System.Net.WebClient').UploadFile("https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)", (Resolve-Path .\TestsResults.xml))
    if ($res.FailedCount -gt 0) { throw "$($res.FailedCount) tests failed."}
}