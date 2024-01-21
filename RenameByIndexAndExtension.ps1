$items = Get-ChildItem
    
function Extract-StringFromFilename {
    param (
        [string]$filename,
        [string]$pattern
    )

    if ($filename -match $pattern) {
        return $matches[0]
    } else {
        return $null
    }
}

function Get-UniqueAuthors {
    param(
        [System.IO.FileInfo[]] $list
    )

    $uniqueList = @()

    foreach($item in $list) {
        $resStr = Extract-StringFromFilename -filename $item.Name -pattern "(((u|t|(4c))-)|@)[a-zA-Z0-9_-]+"

        if($resStr -eq "") {
            continue
        }

        $isNotExist = 1

        foreach($writed in $uniqueList) {
            if($writed -eq $resStr) {
                $isNotExist = 0
                break
            }
        }

        if($isNotExist -eq 1) {
            $uniqueList += $resStr
        }
    }

    return $uniqueList
}

function Count-Uniques {
    param (
        [String[]] $items,
        [String[]] $listUniques
    )

    $counter = New-Object int[] $listUniques.Count
    for($i = 0; $i -lt $listUniques.Count; $i += 1) {
        $counter[$i] = 0
    }

    foreach($item in $items){
        $resStr = Extract-StringFromFilename -filename $item -pattern "(((u|t|(4c))-)|@)[a-zA-Z0-9_-]+"

        if(-not $resStr) {
            continue
        }

        for($i = 0; $i -lt $listUniques.Count; $i += 1) {
            
            if($listUniques[$i] -eq $resStr) {
                $counter[$i] += 1
                break
            }
        }
    }

    return $counter
}

function Move-ToRelatedFolders {
    param (
        [System.IO.FileInfo[]] $list
    )

    foreach($item in $list) {
        $resStr = Extract-StringFromFilename -filename $item.Name -pattern "(((u|t|(4c))-)|@)[a-zA-Z0-9_-]+"

        if($resStr -eq "") {
            continue
        }

        Write-Host $resStr

        Move-Item -LiteralPath $item -Destination $resStr
    }
}

function Rename-SubFolderGuts {
    param (
        [String[]] $listUniq,
        [int[]] $counts
    )

    $currentLocation = Get-Location

    for($i = 0; $i -lt $listUniq.Count; $i += 1) {
        Set-Location $listUniq[$i]
        $localItems = Get-ChildItem -File
        Write-Host "$($listUniq[$i]) Current Location: $(Get-Location)"
        
        foreach($item in $localItems) {
            $extension = $item.Extension
            Rename-Item -LiteralPath $item.FullName -NewName "$($counts[$i])$($extension)"
            $counts[$i] -= 1
        }

        Set-Location $currentLocation
    }
}

$list = Get-ChildItem -File
$uniqNames = Get-UniqueAuthors -list $list

foreach($name in $uniqNames) {
    New-Item -ItemType Directory -Name $name
}


$counts = Count-Uniques -items $list -listUniques $uniqNames

Move-ToRelatedFolders -list $list
Rename-SubFolderGuts -listUniq $uniqNames -counts $counts