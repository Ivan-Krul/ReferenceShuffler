Clear-Host

function Write-List
{
    param
    (
        [Array]$list
    )
    for($i = 0; $i -lt $list.Count; $i += 1)
    {
        Write-Host "$($i)`t: $($list[$i])"
    }
}

function Check-AdditionalDirectories
{
    param
    (
        [System.IO.FileInfo]$currentPath,
        [System.IO.FileInfo]$filePath
    )

    $checkItOut = Get-Content $filePath -Encoding UTF8
    $filePathlist = $checkItOut.Split("`n")
    $allFiles = @()

    Write-List $filePathlist

    foreach($path in $filePathlist)
    {
        Set-Location -Path $path
        Write-Host "Import from`t: $($path)"
        $allFilesLocal = Get-ChildItem -Path $Directory -File -Name -Recurse
        for($i = 0; $i -lt $allFilesLocal.Count; $i++)
		{
			$allFilesLocal[$i] = "$($path)$($allFilesLocal[$i])"
		}
        Write-Host "Fetched     : $($allFilesLocal.Count)"
        $allFiles += $allFilesLocal
        Set-Location $currentPath
    }
    Set-Location $currentPath
    return $allFiles
}

function Test-StringAgainstRegexList {
    param(
        [string]$inputString,
        [string[]]$regexList
    )

    $matchFound = $false

    foreach ($regex in $regexList) {
        if ($inputString -cmatch $regex) {
            $matchFound = $true
            Write-Host "Not mathced by `"$($regex)`": $($file)"
            break
        }
    }

    return -not $matchFound
}

function Parse-Ignore
{
    param
    (
        [System.IO.FileInfo]$IgnoreFilePath,
        [string[]]$allFiles
    )

    $ignorePatterns = Get-Content -Path $IgnoreFilePath -Encoding UTF8
    $ignorePatternList = $ignorePatterns.Split("`n")
    Write-List $ignorePatternList

    $filteredFiles = @()

    foreach ($file in $allFiles)
    {
        if(Test-StringAgainstRegexList -inputString $file -regexList $ignorePatternList)
        {
            $filteredFiles += $file
        }
    }

    return $filteredFiles
}

function Write-FileSize
{
    param(
        [Int64]$Size
    )

    [Int64]$Bytes = $Size % 1KB
    [Int64]$KBytes = ($Size / 1KB) % 1KB
    [Int64]$MBytes = ($Size / 1MB) % 1KB
    [Int64]$GBytes = ($Size / 1GB) % 1TB

    Write-Host "Size of file(s): $($GBytes) GB $($MBytes) MB $($KBytes) KB $($Bytes) B"
}

$location = Get-Location
$allFiles = Check-AdditionalDirectories $location.Path "pathToCheckItOut.txt"
$files = Parse-Ignore "ignore.txt" $allFiles

New-Item "content.txt" -Force

$totalSize = 0
foreach($file in $files)
{
    $prop = Get-Item $file
    $totalSize += $prop.Length
    $file >> "content.txt"
}

Write-FileSize $totalSize
Pause