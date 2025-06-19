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
        Write-Host "Ubuntuのインストールを完了しました。"
        Write-Host "インストール後にユーザー名とパスワードを設定してください。"
        Write-Host "その後WSLに処理が移るので exit で終了してから、再度実行してください。"
        wsl --install -d Ubuntu
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Ubuntuのインストールに失敗しました。"
            exit 1
        }
    }
    catch {
        Write-Error "Ubuntuのインストール中にエラーが発生しました。"
        exit 1
    }
}
else {
    Write-Host "Ubuntuは既にインストールされています。"
}

if (-not (Get-Command git.exe -ErrorAction SilentlyContinue)) {
    Write-Warning "Windows上にGitがインストールされていません。インストールしてから再度実行してください。"
    Read-Host "[Enter]でGitのダウンロードページを表示します。"
    Start-Process "https://git-scm.com/downloads"
    exit 1
}
