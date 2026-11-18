# Luu code -> pull main -> push main. Dung ngay neu co loi/xung dot.
param([string]$Message = 'Cap nhat code du an')
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Split-Path -Parent $PSScriptRoot)
function Invoke-Git {
    param([string[]]$GitArgs)
    & git @GitArgs
    if ($LASTEXITCODE -ne 0) { throw ('Git that bai: git ' + ($GitArgs -join ' ')) }
}
try {
    $branch = & git branch --show-current
    if ($LASTEXITCODE -ne 0) { throw 'Khong doc duoc nhanh Git.' }
    if ($branch -ne 'main') { throw "Dang o nhanh '$branch'. Hay gop code sang main truoc; script chi dong bo main." }
    $mergePath = & git rev-parse --git-path MERGE_HEAD
    if (Test-Path -LiteralPath $mergePath) { throw 'Hay xu ly merge hien tai va commit truoc.' }
    Invoke-Git -GitArgs @('add', '--all', '--', '.', ':!target', ':!.idea', ':!*.iml')
    & git diff --cached --quiet
    $diffExit = $LASTEXITCODE
    if ($diffExit -eq 1) { Invoke-Git -GitArgs @('commit', '-m', $Message) }
    elseif ($diffExit -ne 0) { throw 'Khong kiem tra duoc cac file da stage.' }
    Invoke-Git -GitArgs @('pull', '--no-rebase', '--no-edit', 'origin', 'main')
    Invoke-Git -GitArgs @('push', 'origin', 'HEAD:main')
    Write-Host 'THANH CONG: local va origin/main da dong bo.' -ForegroundColor Green
    exit 0
} catch {
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host 'Da dung. Chay git status de xem chi tiet; khong force push.'
    exit 1
}
