$modulePath = $PSScriptRoot
$moduleName = $modulePath | Split-Path -Leaf

$pesterPaths = @(
    @{
        Path = ".\$moduleName.Tests.ps1"
    } ,

    @{
        Path = '.\Private'
        Parameters = @{}
    } ,

    @{
        Path = '.\Public'
        Parameters = @{}
    }
)


$pesterPaths | ForEach-Object -Process {
    $thisPath = $_
    if ($thisPath.Parameters) {
        $thisPath.Parameters.Module = $Global:TestModule
    }

    $params = @{
        Path = $thisPath
        OutputFormat = 'NUnitXml'
        OutputFile = 'TestResults.xml'
    }

    $res = Invoke-Pester @params -PassThru

    if ($env:APPVEYOR -eq [bool]::TrueString) {
        (New-Object 'System.Net.WebClient').UploadFile("https://ci.appveyor.com/api/testresults/nunit/${env:APPVEYOR_JOB_ID}", (Resolve-Path -Path $params.OutputFile))
        if ($res.FailedCount -gt 0) { throw "$($res.FailedCount) tests failed."}
    }
}