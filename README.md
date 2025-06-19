# wsl-setup
Set up WSL on Windows and build an environment for using Devcontainer.

Windows上でWSLの開発環境を構築するツール群。

### 前準備

Windowsの設定で署名なしスクリプトの実行を許可しておく。
`[システム]-[開発者向け]-[PowerShell] → ON`


### Script List

- setup.ps1 : WindowsのOS設定をWSL2がインストール可能にする
- install.ps1 : WSLをインストールして開発環境を設定する
