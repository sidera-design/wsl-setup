#!/bin/bash

# Abort script if any command returns an error.
set -euo pipefail
# set -euxo pipefail    # for debugging

echo
echo -e "\e[36maptのパッケージリストを更新します。\e[0m"
echo "root権限が必要になるため、WSLのパスワードを入力してください。"
sudo apt-get update

# Python setup
echo
echo -e "\e[36mPython3をデフォルトに設定します。\e[0m"
sudo apt install -y python-is-python3
echo
python --version

# podman setup
echo
echo -e "\e[36mpodmanをインストールします。\e[0m"
sudo apt install -y \
    podman \
    podman-docker
echo
podman --version
podman info > /dev/null
