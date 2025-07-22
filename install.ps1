# 定数設定
$GitSetupFileName = "setup_git.ps1"
$WslSetupFileName = "setup.sh"
$DefaultDistroName = "Ubuntu-Sample"

if ($args.Count -gt 0) {
    $WslDistroName = $args[0]
} else {
    $WslDistroName = $DefaultDistroName
}

# WSLの設定を確認
if (-not (Get-Command wsl -ErrorAction SilentlyContinue)) {
    Write-Warning "WSL機能がインストールされていません。WSLを有効にしてから再度実行してください。"
    exit 1
}

# WSLでインストール済みディストリビューションを取得
$distros = wsl --list --quiet 2>$null

if (-not ($distros -contains "$WslDistroName") ){
    Write-Host "WSLに '$WslDistroName' がインストールされていません。" 
    try {
        Write-Host "Ubuntu ($WslDistroName) をインストールします。" -ForegroundColor Green
        Write-Host "------------------------ 操作手順 --------------------------------" -ForegroundColor Cyan
        Write-Host "インストール後にWSLのユーザー名とパスワードを設定してください。" -ForegroundColor Cyan
        Write-Host "その後WSLのシェル(bash)が起動するので exit コマンドで終了してください。" -ForegroundColor Cyan
        Write-Host "------------------------------------------------------------------" -ForegroundColor Cyan
        wsl --install -d Ubuntu --name $WslDistroName
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Ubuntu ($WslDistroName) のインストールに失敗しました。"
            Write-Host ""
            exit 1
        }
        Write-Host "Ubuntu ($WslDistroName) のインストールが完了しました。"
        Write-Host ""
    }
    catch {
        Write-Error "Ubuntu ($WslDistroName) のインストール中にエラーが発生しました。"
        Write-Host ""
        exit 1
    }
}
else {
    Write-Host "WSL に '$WslDistroName' が存在します。"
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
    $setupShWslPath = wsl -d $WslDistroName -- wslpath -u "'$setupShPath'"
    $setupShHomePath = "/tmp/$WslSetupFileName"
    if ($LASTEXITCODE -ne 0) {
        Write-Error "$WslSetupFileName のパス変換に失敗しました。"
        exit 1
    }
    # /tmp ディレクトリにコピー
    wsl -d $WslDistroName -- cp "$setupShWslPath" "$setupShHomePath"
    if ($LASTEXITCODE -ne 0) {
        Write-Error "$setupShWslPath から $setupShHomePath へのコピーに失敗しました。"
        exit 1
    }
    # 改行コードをLinux形式に変換
    wsl -d $WslDistroName -- sed -i "'s/\r$//'" "$setupShHomePath"
    if ($LASTEXITCODE -ne 0) {
        Write-Error "$setupShHomePath の改行コードの変換失敗しました。"
        exit 1
    }
    # $WslSetupFileName 実行
    Write-Host ""
    Write-Host "WSL上で設定スクリプト($WslSetupFileName)を実行します。" -ForegroundColor Green
    wsl -d $WslDistroName -- bash "$setupShHomePath"
    if ($LASTEXITCODE -ne 0) {
        Write-Error "$setupShHomePath の実行に失敗しました。"
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
