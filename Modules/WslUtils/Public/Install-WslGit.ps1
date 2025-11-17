function Install-WslGit {
  param(
    [string]$Distro = $null
  )
  # ディストロ名を解決
  $DistroName = Resolve-WslDistro $Distro 
  
  Write-Host ""
  Write-Host "Gitの設定を行います。" -ForegroundColor Green

  # 定数の設定
  $GitCredentialManagerPath = "C:\Program Files\Git\mingw64\bin\git-credential-manager.exe"

  # GitがWindowsにインストールされているか確認
  if (-not (Get-Command git.exe -ErrorAction SilentlyContinue)) {
      Write-Warning "Windows上にGitがインストールされていません。"
      Write-Host "インストールしてから再度このスクリプトを実行してください。" -ForegroundColor Cyan
      Read-Host "[Enter]でGitのダウンロードページを表示します。"
      Start-Process "https://git-scm.com/downloads"
      Write-Host ""
      exit 1
  }

  # Git Credential Managerのパスを確認
  if (-not (Test-Path $GitCredentialManagerPath)) {
      Write-Error "Git Credential Managerが見つかりません。"
      Write-Host "Git Credential Managerが以下のパスに正しくインストールされているか確認してください。" -ForegroundColor Cyan
      Write-Host "  $GitCredentialManagerPath"
      Write-Host "【参考】Gitバージョンの差異による可能性があります。" -ForegroundColor DarkGray
      Write-Host "  v2.36.1～v2.38.x : mingw64\libexec\git-core\git-credential-manager.exe" -ForegroundColor DarkGray
      Write-Host "  v2.36.0以前 : mingw64\bin\git-credential-manager-core.exe” -ForegroundColor DarkGray
      Write-Host ""
      exit 1
  }
  

  # WSL上でgitのバージョンを表示
  Write-Host "Gitバージョンを確認します。" -ForegroundColor Cyan
  $winGitVersion = git --version
  $wslGitVersion = wsl -d $DistroName -- git --version
  Write-Host " Windows: $winGitVersion"
  Write-Host " WSL: $wslGitVersion"

  Write-Host "WSL上のgit config を設定します。" -ForegroundColor Cyan
  # Gitユーザー名を設定
  $gitUserName = git config --global user.name
  if (-not $gitUserName) {
      Write-Warning "Gitにユーザー名が設定されていません。設定します。"
      $gitUserName = Read-Host "Git用ユーザー名を入力してください"
      git config --global user.name $gitUserName
  }
  Write-Host " Gitユーザー名: $gitUserName"
  wsl -d $DistroName -- bash -lc "git config --global user.name '$gitUserName'"
  # Gitメールアドレスを設定
  $gitUserEmail = git config --global user.email
  if (-not $gitUserEmail) {
      Write-Warning "Gitにメールアドレスが設定されていません。設定します。"
      $gitUserEmail = Read-Host "Git用メールアドレスを入力してください"
      git config --global user.email $gitUserEmail
  }
  Write-Host " Gitメールアドレス: $gitUserEmail"
  wsl -d $DistroName -- bash -lc "git config --global user.email '$gitUserEmail'"
  # Git Credential Managerの設定
  $GcmPathWSL = Convert-PathToWsl $GitCredentialManagerPath -Distro $DistroName
  wsl -d $DistroName -- bash -lc 'mkdir -p ~/bin'
  wsl -d $DistroName -- bash -lc "ln -sf '$GcmPathWSL' ~/bin/git-credential-manager"
  wsl -d $DistroName -- bash -lc 'git config --global credential.helper $HOME/bin/git-credential-manager'
}