Import-Module '.\Modules\WslUtils\WslUtils.psd1' -Force

# 定数設定
$WslSetupFileName = "setup.sh"
$DefaultDistroName = "Ubuntu-Sample"

# 引数でディストロ名が指定されていなければ既定のディストロ名を使う
if ($args.Count -gt 0) {
    $WslDistroName = $args[0]
}
else {
    $WslDistroName = $DefaultDistroName
}

# WSLの設定を確認
if (-not (Get-Command wsl -ErrorAction SilentlyContinue)) {
    Write-Warning "WSL機能がインストールされていません。WSLを有効する必要があります。"
    Write-Host "先に .\setup_win.ps1 を実行してください。"
    exit 1
}

# WSLでインストール済みディストリビューションを取得
if (-not (Test-WslDistroExists $WslDistroName) ) {
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
Install-WslGit -Distro $WslDistroName

# $WslSetupFileName を WSL の /tmp ディレクトリにコピーして実行
$setupShPath = Join-Path -Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath "$WslSetupFileName"
Invoke-WslScript $setupShPath -Distro $WslDistroName


# WSL設定の終了
Write-Host ""
Write-Host "WSLの設定は正常に完了しました。" -ForegroundColor Green
Write-Host ""
exit 0
