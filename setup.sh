#!/bin/bash

# Abort script if any command returns an error.
set -euo pipefail
# set -euxo pipefail    # for debugging

# 変数に色コードを定義
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color (リセットコード)

printf "\n"
printf "${CYAN}aptのパッケージリストを更新します。${NC}\n"
printf "root権限が必要になるため、WSLのパスワードを入力してください。\n"
(
    set -x
    sudo apt-get update
)

# Python setup
printf "\n"
printf "${CYAN}Python3をデフォルトに設定します。${NC}\n"
(
    set -x
    sudo apt install -y python-is-python3
)
printf "\n"
(
    set -x
    python --version
)

# podman setup
printf "\n"
printf "${CYAN}podmanをインストールします。${NC}\n"
(
    set -x
    # podmanのインストール
    # 公式ドキュメント: https://podman.io/getting-started/installation
    # Ubuntu 22.04の場合、標準リポジトリからインストール可能
    sudo apt install -y \
        podman \
        podman-docker
)

# podman setup
printf "\n"
printf "${CYAN}Dockerエミュレーション利用時の警告を抑制します。${NC}\n"
(
    sudo mkdir -p /etc/containers
    sudo touch /etc/containers/nodocker
)

printf "\n"
