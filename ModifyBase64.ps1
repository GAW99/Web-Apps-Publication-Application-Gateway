$fileContentBytes = Get-Content -Path 'C:\Users\admin.GAW00\Desktop\26\root64.cer'
$fileContentBytes.Length

$Temp2 =  [System.Collections.Generic.List[System.Object]]$fileContentBytes
$Temp2.RemoveAt($Temp2.Count-1)
$Temp2.RemoveAt(0)

$Temp2
[string]$result = $null
foreach ($item in $Temp2) 
{
    $result += $item
}

$result |  Out-File -FilePath 'C:\Users\admin.GAW00\Desktop\26\root64_Alligned.txt'