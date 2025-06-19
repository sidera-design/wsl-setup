# wsl-setup
Set up WSL on Windows and build an environment for using Devcontainer.

Windows上でWSLの開発環境を構築するツール群。

### 前準備

Windowsの設定で署名なしスクリプトの実行を許可しておく。
`[システム]-[開発者向け]-[PowerShell] → ON`


### Script List

- setup_win.ps1 : WindowsのOS環境をWSL2インストール可能な設定にする
- install.ps1 : WSLにUbuntuをインストールして開発環境を設定する
  （内部で以下のファイルを呼び出して実行）
  - setup_git.ps1 : Gitを設定する
  - setup.sh : WSL上の設定シェルスクリプト
- uninstall.ps1 : WSLからUbuntuを取り除く
