@{ 
    Value = {param($a,$b) 
        Write-Verbose "$a~$b" -Verbose
        gps 
    } 
}
