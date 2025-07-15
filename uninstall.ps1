# 定数設定
$DefaultDistroName = "Ubuntu-Sample"

if ($args.Count -gt 0) {
    $WslDistroName = $args[0]
} else {
    $WslDistroName = $DefaultDistroName
}


# WSLの設定を確認
if (-not (Get-Command wsl -ErrorAction SilentlyContinue)) {
    Write-Warning "WSLがインストールされていません。"
    exit 0
}

# Ubuntuのインストールを確認
$distros = wsl -d $WslDistroName --list --quiet 2>$null
if (-not ($distros -contains "$WslDistroName")) {
    Write-Host "$WslDistroName はWSLとしてインストールされていません。"
    exit 0
}

# 実行中のWSLインスタンスをシャットダウン
try {
    wsl -d $WslDistroName --shutdown
    if ($LASTEXITCODE -ne 0) {
        Write-Error "wsl -d $WslDistroName --shutdown の実行に失敗しました。"
        exit 1
    }
}
catch {
    Write-Error "wsl -d $WslDistroName --shutdown の実行中にエラーが発生しました。"
    exit 1
}
# Ubuntuのアンインストール
try {
    Write-Host "$WslDistroName をアンインストールします。" -ForegroundColor Green
    $confirmation = Read-Host "$WslDistroName に含まれる全てのデータが消去されますがよろしいですか？[Y]"
    if ($confirmation -ne "Y" -and $confirmation -ne "y") {
        Write-Host "アンインストールをキャンセルします。"
        exit 0
    }
    wsl --unregister $WslDistroName
    if ($LASTEXITCODE -ne 0) {
        Write-Error "$WslDistroName のアンインストールに失敗しました。"
        exit 1
    }
    Write-Host "$WslDistroName をWSLからアンインストールしました。"
}
catch {
    Write-Error "$WslDistroName のアンインストール中にエラーが発生しました。"
    exit 1
}
