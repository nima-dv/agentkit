# Wires this kit into Claude Code. Idempotent: safe to rerun any time.
# Rerun after DVMind or any other installer rewrites ~/.claude/CLAUDE.md.
#
# Junctions, not copies, so editing the repo takes effect immediately and nothing
# drifts. Junctions need no admin rights on Windows (symlinks do).

$ErrorActionPreference = 'Stop'
$kit      = Split-Path $PSScriptRoot -Parent
$claudeIn = "$env:USERPROFILE\.claude"

function Set-Junction($link, $target) {
    if (Test-Path -LiteralPath $link) {
        $item = Get-Item -LiteralPath $link -Force
        if ($item.LinkType -eq 'Junction') {
            if ($item.Target -contains $target) { Write-Host "ok       $link"; return }
            Remove-Item -LiteralPath $link -Force -Confirm:$false
        }
        else {
            # A real directory. Never clobber content that is not ours.
            $count = @(Get-ChildItem -LiteralPath $link -Force -ErrorAction SilentlyContinue).Count
            if ($count -gt 0) {
                Write-Warning "SKIPPED  $link is a real directory with $count item(s). Move them into $target, delete it, then rerun."
                return
            }
            Remove-Item -LiteralPath $link -Force -Confirm:$false
        }
    }
    New-Item -ItemType Junction -Path $link -Target $target | Out-Null
    Write-Host "linked   $link -> $target"
}

Set-Junction "$claudeIn\agents" "$kit\agents"
Set-Junction "$claudeIn\skills" "$kit\skills"

# CLAUDE.md: render the versioned pointer, keeping one dated backup.
# {{KIT}} expands to wherever this repo actually lives, so moving the repo and
# rerunning this script re-points everything instead of leaving stale paths.
$src      = "$kit\tools\claude\CLAUDE.md"
$dst      = "$claudeIn\CLAUDE.md"
$rendered = [System.IO.File]::ReadAllText($src).Replace('{{KIT}}', $kit)
$utf8     = New-Object System.Text.UTF8Encoding($false)

if (-not (Test-Path -LiteralPath $dst)) {
    [System.IO.File]::WriteAllText($dst, $rendered, $utf8)
    Write-Host "created  $dst"
}
elseif ([System.IO.File]::ReadAllText($dst) -ceq $rendered) {
    Write-Host "ok       $dst"
}
else {
    $backup = "$dst.bak-$((Get-Item $dst).LastWriteTime.ToString('yyyyMMdd-HHmmss'))"
    Copy-Item $dst $backup -Force
    [System.IO.File]::WriteAllText($dst, $rendered, $utf8)
    Write-Host "updated  $dst  (previous saved to $(Split-Path $backup -Leaf))"
}

& "$kit\tools\index-skills.ps1"
Write-Host "`nDone. Start a new session to pick up CLAUDE.md changes."
