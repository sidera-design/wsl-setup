#!/bin/bash

# Abort script if any command returns an error.
set -euo pipefail
# set -euxo pipefail    # for debugging

echo -e "\e[36maptのパッケージリストを更新します。\e[0m"
echo -e "root権限が必要になるため、WSLのパスワードを入力してください。"
sudo apt-get update

# Python setup
# カラー出力の例
echo -e "\e[36mPython3をデフォルトに設定します。\e[0m"
sudo apt install -y python-is-python3
