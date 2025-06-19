# 定数設定
$GitSetupFileName = "setup_git.ps1"
$WslSetupFileName = "setup.sh"


# WSLの設定を確認
if (-not (Get-Command wsl -ErrorAction SilentlyContinue)) {
    Write-Warning "WSLがインストールされていません。WSLを有効にしてから再度実行してください。"
    exit 1
}

# WSLでインストール済みディストリビューションを取得
$distros = wsl --list --quiet 2>$null

if (-not ($distros -contains 'Ubuntu')) {
    Write-Host "Ubuntuがインストールされていません。" 
    try {
        Write-Host "Ubuntuをインストールします。" -ForegroundColor Green
        Write-Host "インストール後にWSLのユーザー名とパスワードを設定してください。" -ForegroundColor Cyan
        Write-Host "その後WSLのシェル(bash)が起動するので exit コマンドで終了してください。" -ForegroundColor Cyan
        wsl --install -d Ubuntu
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Ubuntuのインストールに失敗しました。"
            Write-Host ""
            exit 1
        }
        Write-Host "Ubuntuのインストールが完了しました。"
        Write-Host ""
    }
    catch {
        Write-Error "Ubuntuのインストール中にエラーが発生しました。"
        Write-Host ""
        exit 1
    }
}
else {
    Write-Host "Ubuntuは既にインストールされています。"
}

# Gitの設定
$setupGitScript = Join-Path -Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath "$GitSetupFileName"
if (Test-Path $setupGitScript) {  
    & $setupGitScript
    if ($LASTEXITCODE -ne 0) {
        exit 1
    }
} else {
    Write-Error "$GitSetupFileName が見つかりません。"
    exit 1
}


# $WslSetupFileName を WSL の /tmp ディレクトリにコピーして実行
$setupShPath = Join-Path -Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath "$WslSetupFileName"
if (Test-Path $setupShPath) {
    $setupShWslPath = wsl -- wslpath -u "'$setupShPath'"
    if ($LASTEXITCODE -ne 0) {
        Write-Error "$WslSetupFileName のパス変換に失敗しました。"
        exit 1
    }
    # /tmp ディレクトリにコピー
    wsl cp "$setupShWslPath" /tmp/$WslSetupFileName
    # $WslSetupFileName 実行
    Write-Host ""
    Write-Host "WSL上で設定スクリプト($WslSetupFileName)を実行します。" -ForegroundColor Green
    wsl bash /tmp/$WslSetupFileName
    if ($LASTEXITCODE -ne 0) {
        Write-Error "$WslSetupFileName の実行に失敗しました。"
        exit 1
    }
} else {
    Write-Error "$WslSetupFileName が見つかりません。"
    exit 1
}

# WSL設定の終了
Write-Host ""
Write-Host "WSLの設定は正常に完了しました。" -ForegroundColor Green
Write-Host ""
exit 0
