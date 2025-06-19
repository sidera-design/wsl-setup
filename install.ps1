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
        Write-Host "インストール後にユーザー名とパスワードを設定してください。" -ForegroundColor Cyan
        Write-Host "その後WSLに処理が移るので exit で終了してから、再度このスクリプトを実行してください。" -ForegroundColor Cyan
        wsl --install -d Ubuntu
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Ubuntuのインストールに失敗しました。"
            Write-Host ""
            exit 1
        }
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

if (-not (Get-Command git.exe -ErrorAction SilentlyContinue)) {
    Write-Warning "Windows上にGitがインストールされていません。"
    Write-Host "インストールしてから再度このスクリプトを実行してください。" -ForegroundColor Cyan
    Read-Host "[Enter]でGitのダウンロードページを表示します。"
    Write-Host ""
    Start-Process "https://git-scm.com/downloads"
    exit 1
}

# # Gitの設定
# $setupGitScript = Join-Path -Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath "setup_git.ps1"
# if (Test-Path $setupGitScript) {  
#     & $setupGitScript
#     if ($LASTEXITCODE -ne 0) {
#         exit 1
#     }
# } else {
#     Write-Error "setup_git.ps1 が見つかりません。"
#     exit 1
# }


# setup.sh を WSL の /tmp ディレクトリにコピーして実行
$setupShPath = Join-Path -Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath "setup.sh"
if (Test-Path $setupShPath) {
    $setupShWslPath = wsl -- wslpath -u "'$setupShPath'"
    if ($LASTEXITCODE -ne 0) {
        Write-Error "setup.sh のパス変換に失敗しました。"
        exit 1
    }
    # /tmp ディレクトリにコピー
    wsl cp "$setupShWslPath" /tmp/setup.sh
    # setup.sh 実行
    Write-Host "WSL上で setup.sh を実行します。" -ForegroundColor Green
    wsl bash /tmp/setup.sh
    if ($LASTEXITCODE -ne 0) {
        Write-Error "setup.sh の実行に失敗しました。"
        exit 1
    }
} else {
    Write-Error "setup.sh が見つかりません。"
    exit 1
}
