$items = Get-ChildItem
    
$uniqueExtension = @()
$countExtension =  @()

$isExist = 0
$listAuthNames = @()
$listFutuNames = @()

foreach($item in $items) {
    $isExist = -1

    for ($i = 0; $i -lt $uniqueExtension.Count; $i++) {
        if($uniqueExtension[$i] -eq $item.Extension) {
            $isExist = $i
            $countExtension[$i] += 1
            break
        }
    }

    if($isExist -eq -1) {
        if($item.Extension -eq ".ps1") {
            continue
        }
        
        $uniqueExtension += $item.Extension
        $countExtension += 0
        $isExist = $uniqueExtension.Length - 1
    }
    $listAuthNames += $item.Name.Split(" ")[0]
    $listFutuNames += "$($countExtension[$isExist])$($uniqueExtension[$isExist])"
    Write-Host $item.Name
    Write-Host "$($countExtension[$isExist])$($uniqueExtension[$isExist])"
    #Rename-Item $item "$($countExtension[$isExist])$($uniqueExtension[$isExist])"
}
Write-Host $listAuthNames
Write-Host $listFutuNames

