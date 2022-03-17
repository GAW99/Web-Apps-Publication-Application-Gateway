#. ($PSScriptRoot+"\ESAE.ps1")
$filename = "CA IIS Private Certificate.cer"
$OutputFileName = $filename.Substring(0,$filename.IndexOf('.'))+"_Alligned.txt"

$fileContentBytes = Get-Content -Path $($PSScriptRoot+'\'+$FileName)
$fileContentBytes.Length

$Temp2 =  [System.Collections.Generic.List[System.Object]]$fileContentBytes
$Temp2.RemoveAt($Temp2.Count-1)
$Temp2.RemoveAt(0)

[string]$result = $null
foreach ($item in $Temp2) 
{
    $result += $item
}

$result |  Out-File -FilePath $($PSScriptRoot+'\'+$OutputFileName)