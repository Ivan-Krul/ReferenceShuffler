$list = Get-ChildItem -Recurse -Name

foreach($el in $list) {
    $item = Get-Item $el
    if($item.Extension -eq ".jpeg") {
		Write-Host $el
        Rename-Item $item "$($item.Name).jpg"
    }
}

