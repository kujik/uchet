<#
.SYNOPSIS
    Массовая перекодировка исходников Delphi (Uchet) из Windows-1251 в UTF-8 (с BOM).

.DESCRIPTION
    Файлы, которые уже в UTF-8 (есть BOM либо весь файл валидно читается как UTF-8),
    автоматически пропускаются — трогать их не нужно.

    Обрабатываются только *.pas, *.dpr, *.inc — то есть исходный код.
    Файлы *.dfm НЕ трогаются намеренно: кириллица в них и так хранится как числовые
    коды (#1042#1077...), поэтому кодировка .dfm не может "сломаться" и трогать их незачем.

.USAGE
    Пробный прогон (ничего не меняет, только список файлов):
        powershell -ExecutionPolicy Bypass -File .\convert_to_utf8.ps1

    Реальная перекодировка:
        powershell -ExecutionPolicy Bypass -File .\convert_to_utf8.ps1 -Apply

    После -Apply рекомендуется:
        git diff --stat
    бегло посмотреть, что изменились только .pas/.dpr/.inc и дифф выглядит разумно;
    если что-то не так — git checkout -- <file> откатит файл обратно.
#>

param(
    [switch]$Apply,
    [string]$RootPath = "R:\Projects\Uchet"
)

$Extensions = @('.pas', '.dpr', '.inc')

$SkipDirs = @(
    '__history', '__recovery', 'Backups', 'backup', 'Deleted', 'Log',
    'Test', 'Tasks', 'AddFiles', 'Alt', 'Icons', 'Doc', 'Updater', '.git'
)

# На некоторых сборках PowerShell (7+/.NET Core) кодовая страница 1251 не
# зарегистрирована по умолчанию — регистрируем провайдер на всякий случай.
try {
    [System.Text.Encoding]::GetEncoding(1251) | Out-Null
} catch {
    Add-Type -AssemblyName System.Text.Encoding.CodePages -ErrorAction SilentlyContinue
    [System.Text.Encoding]::RegisterProvider([System.Text.CodePagesEncodingProvider]::Instance)
}

$Cp1251     = [System.Text.Encoding]::GetEncoding(1251)
$Utf8Strict = New-Object System.Text.UTF8Encoding($false, $true)   # без BOM, строгая проверка при чтении
$Utf8Bom    = New-Object System.Text.UTF8Encoding($true)           # с BOM, для записи

function Test-IsUtf8 {
    param([byte[]]$Bytes)
    if ($Bytes.Length -ge 3 -and $Bytes[0] -eq 0xEF -and $Bytes[1] -eq 0xBB -and $Bytes[2] -eq 0xBF) {
        return $true
    }
    try {
        [void]$Utf8Strict.GetString($Bytes)
        return $true
    } catch {
        return $false
    }
}

function Test-IsSkippedDir {
    param([string]$FullPath, [string]$Root)
    $rel = $FullPath.Substring($Root.Length).TrimStart('\')
    $parts = $rel -split '\\'
    foreach ($p in $parts) {
        if ($SkipDirs -contains $p) { return $true }
    }
    return $false
}

Write-Host "Сканирую $RootPath ..."

$files = Get-ChildItem -Path $RootPath -Recurse -File -ErrorAction SilentlyContinue |
    Where-Object { $Extensions -contains $_.Extension.ToLower() } |
    Where-Object { -not (Test-IsSkippedDir -FullPath $_.FullName -Root $RootPath) }

$results = [ordered]@{
    'already-utf8'     = @()
    'needs-conversion' = @()
    'converted'        = @()
    'error'            = @()
}

foreach ($file in $files) {
    $bytes = [System.IO.File]::ReadAllBytes($file.FullName)
    $isUtf8 = Test-IsUtf8 -Bytes $bytes

    if ($isUtf8) {
        $results['already-utf8'] += $file.FullName
        continue
    }

    if (-not $Apply) {
        $results['needs-conversion'] += $file.FullName
        continue
    }

    try {
        $text = $Cp1251.GetString($bytes)
        [System.IO.File]::WriteAllText($file.FullName, $text, $Utf8Bom)
        $results['converted'] += $file.FullName
    } catch {
        $results['error'] += "$($file.FullName): $($_.Exception.Message)"
    }
}

Write-Host ""
foreach ($key in $results.Keys) {
    Write-Host "$($key): $($results[$key].Count)"
}

$interesting = if ($Apply) { 'converted' } else { 'needs-conversion' }
Write-Host ""
Write-Host "Файлы ($interesting):"
$results[$interesting] | ForEach-Object { Write-Host "  $_" }

if ($results['error'].Count -gt 0) {
    Write-Host ""
    Write-Host "!!! Были ошибки — эти файлы НЕ тронуты:"
    $results['error'] | ForEach-Object { Write-Host "  $_" }
}

if (-not $Apply) {
    Write-Host ""
    Write-Host "Это пробный прогон (dry-run), файлы не менялись."
    Write-Host "Проверьте список выше, затем запустите: .\convert_to_utf8.ps1 -Apply"
}
