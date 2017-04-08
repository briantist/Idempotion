$Subs = @(
    @{
        Path = 'Classes'
        Export = $false
        Recurse = $false
        Filter = '*.Class.ps1'
        Exclude = @(
                '*.Tests.ps1'
        )
    } ,

    @{
        Path = 'Private'
        Export = $false
        Recurse = $false
        Filter = '*-*.ps1'
        Exclude = @(
                '*.Tests.ps1'
        )
    } ,

    @{
        Path = 'Public'
        Export = $true
        Recurse = $false
        Filter = '*-*.ps1'
        Exclude = @(
                '*.Tests.ps1'
        )
    } 
) 


$thisModule = [System.IO.Path]::GetFileNameWithoutExtension($PSCommandPath)
$varName = "__${thisModule}_Export_All"
$exportAll = Get-Variable -Scope Global -Name $varName -ValueOnly -ErrorAction Ignore

$Subs | ForEach-Object -Process {
    $sub = $_
    $thisDir = $PSScriptRoot | Join-Path -ChildPath $sub.Path | Join-Path -ChildPath '*'
    $thisDir | 
    Get-ChildItem -Filter $sub.Filter -Exclude $sub.Exclude -Recurse:$sub.Recurse -ErrorAction Ignore | ForEach-Object -Process {
        try {
            $Unit = $_.FullName
            . $Unit
            if ($sub.Export -or $exportAll) {
                Export-ModuleMember -Function $_.BaseName
            }
        } catch {
            $e = "Could not import '$Unit' with exception: `n`n`n$($_.Exception)" -as $_.Exception.GetType()
            throw $e
        }
    }
}