param(
    [Parameter(Mandatory = $true)]
    [int]$PreviousRevision,

    [Parameter(Mandatory = $true)]
    [int]$CurrentRevision,

    [string]$WorkingCopy = (Get-Location).Path
)

$ErrorActionPreference = "Stop"

if ($PreviousRevision -ge $CurrentRevision) {
    throw "PreviousRevision 必须小于 CurrentRevision。"
}

if (-not (Test-Path -LiteralPath $WorkingCopy)) {
    throw "工作副本路径不存在：$WorkingCopy"
}

$repoUrl = (& svn info --show-item url -- "$WorkingCopy").Trim()
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($repoUrl)) {
    throw "无法读取 SVN 仓库 URL：$WorkingCopy"
}

$xmlText = (& svn diff --summarize --xml -r "$PreviousRevision`:$CurrentRevision" -- "$repoUrl" | Out-String)
if ($LASTEXITCODE -ne 0) {
    throw "svn diff 执行失败。"
}

[xml]$diff = $xmlText

$moduleMap = [ordered]@{
    "server/dldl-server/dldl-game-server/" = "dldl-game-server"
    "server/dldl-server/dldl-cross-server/" = "dldl-cross-server"
    "server/dldl-server/dldl-protobuf3/" = "dldl-protobuf3"
    "server/dldl-server/dldl-config/" = "dldl-config"
    "server/dldl-server/dldl-battle/" = "dldl-battle"
    "server/dldl-server/dldl-share/" = "dldl-share"
    "server/game-starfish/" = "game-starfish"
    "server/game-rpc/" = "game-rpc"
    "server/ayjs-agent/" = "ayjs-agent"
    "proto/" = "dldl-protobuf3"
}

function Normalize-Path([string]$PathText) {
    $normalized = [System.Uri]::UnescapeDataString($PathText).Replace('\', '/')
    $serverIndex = $normalized.IndexOf('/server/', [System.StringComparison]::OrdinalIgnoreCase)
    $protoIndex = $normalized.IndexOf('/proto/', [System.StringComparison]::OrdinalIgnoreCase)
    if ($serverIndex -ge 0) {
        return $normalized.Substring($serverIndex + 1)
    }
    if ($protoIndex -ge 0) {
        return $normalized.Substring($protoIndex + 1)
    }
    return $normalized.TrimStart('/')
}

function Get-StatusCode([string]$Item) {
    switch ($Item) {
        "added" { return "A" }
        "modified" { return "M" }
        "deleted" { return "D" }
        "replaced" { return "R" }
        default { return $Item }
    }
}

$jarChanges = [ordered]@{}
$csvChanges = [ordered]@{}
$deleted = [ordered]@{}
$unmapped = [System.Collections.Generic.HashSet[string]]::new()

foreach ($entry in @($diff.diff.paths.path)) {
    $path = Normalize-Path ([string]$entry.'#text')
    $status = Get-StatusCode ([string]$entry.item)

    if (-not ($path.StartsWith("server/", [System.StringComparison]::OrdinalIgnoreCase) -or
              $path.StartsWith("proto/", [System.StringComparison]::OrdinalIgnoreCase))) {
        continue
    }

    $lower = $path.ToLowerInvariant()
    if ($lower.EndsWith(".jar")) {
        if ($status -eq "D") { $deleted[$path] = $status } else { $jarChanges[$path] = $status }
        continue
    }

    if ($lower.EndsWith(".csv")) {
        if ($status -eq "D") { $deleted[$path] = $status } else { $csvChanges[$path] = $status }
        continue
    }

    $mapped = $false
    foreach ($prefix in $moduleMap.Keys) {
        if ($path.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase)) {
            $module = $moduleMap[$prefix]
            $candidate = Get-ChildItem -LiteralPath (Join-Path $WorkingCopy "server/bin") -Recurse -File -Filter "$module*.jar" -ErrorAction SilentlyContinue |
                Select-Object -First 1
            $jarPath = if ($candidate) { $candidate.FullName.Substring($WorkingCopy.Length).TrimStart('\', '/') -replace '\', '/' } else { "server/bin/**/$module-*.jar（需先构建产物）" }
            $jarChanges[$jarPath] = "M"
            $mapped = $true
            break
        }
    }
    if (-not $mapped) {
        [void]$unmapped.Add("[$status] $path")
    }
}

Write-Output "Revision: r$PreviousRevision -> r$CurrentRevision"
Write-Output ""
Write-Output "需要上传的 JAR："
if ($jarChanges.Count -eq 0) { Write-Output "- 无" } else { $jarChanges.Keys | Sort-Object | ForEach-Object { Write-Output "- [$($jarChanges[$_])] $_" } }
Write-Output ""
Write-Output "需要上传的 CSV："
if ($csvChanges.Count -eq 0) {
    Write-Output "- 无"
} else {
    $csvChanges.Keys | Sort-Object | ForEach-Object {
        $note = if ($_ -like "server/config/src/*") { "（需重新导出/同步后上传）" } else { "" }
        Write-Output "- [$($csvChanges[$_])] $_$note"
    }
}
Write-Output ""
Write-Output "需要删除/下线："
$deletedKeys = $deleted.Keys | Sort-Object
if ($deletedKeys.Count -eq 0) { Write-Output "- 无" } else { $deletedKeys | ForEach-Object { Write-Output "- [$($deleted[$_])] $_" } }
Write-Output ""
Write-Output "待确认："
if ($unmapped.Count -eq 0) { Write-Output "- 无" } else { $unmapped | Sort-Object | ForEach-Object { Write-Output "- $_" } }
