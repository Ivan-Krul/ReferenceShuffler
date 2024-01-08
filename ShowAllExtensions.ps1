$list = Get-ChildItem -Recurse
$uniqueExtension = @()

$isExist = 0

foreach($el in $list) {
    $isExist = 0

    foreach($ext in $uniqueExtension){
        if($ext -eq $el.Extension) {
            $isExist = 1
            break
        }
    }

    if($isExist -eq 0) {
        $uniqueExtension += $el.Extension
    }
        
}

Write-Host $uniqueExtension
