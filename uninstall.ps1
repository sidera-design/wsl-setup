# WSLの設定を確認
if (-not (Get-Command wsl -ErrorAction SilentlyContinue)) {
    Write-Warning "WSLがインストールされていません。"
    exit 0
}

# Ubuntuのインストールを確認
$distros = wsl --list --quiet 2>$null
if (-not ($distros -contains 'Ubuntu')) {
    Write-Host "Ubuntuは既にインストールされていません。"
    exit 0
}

# 実行中のWSLインスタンスをシャットダウン
try {
    wsl --shutdown
    if ($LASTEXITCODE -ne 0) {
        Write-Error "wsl --shutdown の実行に失敗しました。"
        exit 1
    }
}
catch {
    Write-Error "wsl --shutdown の実行中にエラーが発生しました。"
    exit 1
}
# Ubuntuのアンインストール
try {
    Write-Host "Ubuntuをアンインストールします。" -ForegroundColor Green
    wsl --unregister Ubuntu
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Ubuntuのアンインストールに失敗しました。"
        exit 1
    }
    Write-Host "Ubuntuをアンインストールしました。"
}
catch {
    Write-Error "Ubuntuのアンインストール中にエラーが発生しました。"
    exit 1
}
