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



# PROXY情報
source ~/.profile 2>/dev/null || true

# インターネット接続確認
printf "\n"
printf "${CYAN}インターネット接続のためにProxyを設定します。${NC}\n"
if curl -sfI -o /dev/null -m 3 https://www.google.com; then
    printf "\n"
    printf "インターネット接続は既に有効です。Proxy設定をスキップします。\n"
else
    # Setup Proxy
    unset HISTFILE  # 履歴ファイル無効化（念のため）

    # Proxyサーバ情報の入力
    printf "\n"
    read -p "ProxyサーバのIPアドレスを入力（デフォルト： 172.16.44.6）: " PROXY_HOST
    read -p "Proxyサーバのポート番号を入力（デフォルト： 8080）: " PROXY_PORT
    export PROXY_SERVER="${PROXY_HOST:-172.16.44.6}:${PROXY_PORT:-8080}"
    export HTTPS_PROXY="http://${PROXY_SERVER}"
    export DISP_PROXY="${HTTPS_PROXY}"

    # Proxyユーザーの入力
    if ! curl -sfI -o /dev/null -m 3 https://www.google.com; then
        read -p "Proxy用ユーザー名を入力（デフォルト： ${USER}）: " PROXY_USER
        export PROXY_USER="${PROXY_USER:-$USER}"
        export HTTPS_PROXY="http://${PROXY_USER}@${PROXY_SERVER}"
        export DISP_PROXY="${HTTPS_PROXY}"

        # Proxyユーザーのパスワード入力
        if ! curl -sfI -o /dev/null -m 3 https://www.google.com; then
            while true; do
                read -s -p "Proxy用のパスワードを入力: " PROXY_PASSWORD
                printf "\n"
                read -s -p "確認用にパスワードを再入力: " PROXY_PASSWORD_CONFIRM
                printf "\n"
                if [[ "${PROXY_PASSWORD}" == "${PROXY_PASSWORD_CONFIRM}" ]]; then
                    break
                else
                    printf "パスワードが一致しません。もう一度入力してください。\n"
                fi
            done
            export HTTPS_PROXY="http://${PROXY_USER}:${PROXY_PASSWORD}@${PROXY_SERVER}"
            export DISP_PROXY="http://${PROXY_USER}:XXXXXX@${PROXY_SERVER}"
        fi
    fi
    export https_proxy="${HTTPS_PROXY}"
    export HTTP_PROXY="${HTTPS_PROXY}"
    printf "\n"
    printf "HTTP_PROXY, HTTPS_PROXY を ${DISP_PROXY} に設定します。\n"

    if ! curl -sfI -o /dev/null -m 5 https://www.google.com; then
        printf "${RED}Proxy設定後もインターネットに接続できません。設定を確認してください。${NC}\n"
        exit 1
    fi

    # プロキシ環境変数を~/.profileと~/.bashrcの末尾に追加
    echo "" >> ~/proxy_env
    echo "# Proxy settings added by setup.sh" >> ~/proxy_env
    echo "export PROXY_USER=\"${PROXY_USER}\"" >> ~/proxy_env
    echo "export HTTP_PROXY=\"${HTTP_PROXY}\"" >> ~/proxy_env
    echo "export HTTPS_PROXY=\"${HTTPS_PROXY}\"" >> ~/proxy_env
    echo "export http_proxy=\"${HTTPS_PROXY}\"" >> ~/proxy_env
    echo "export NO_PROXY=\"localhost,127.0.0.1,::1,10.0.0.0/8,*.internal\"" >> ~/proxy_env

    # ~/.profile はVSCodeのDevcontainerで読み込まれるため必要
    cat ~/proxy_env >> ~/.profile
    # ~/.bashrc は wsl bash -c XXX などで読み込まれるため必要
    cat ~/proxy_env >> ~/.bashrc
    rm -f ~/proxy_env
    # wsl -- XXX の直接起動のコマンドは ~/.bashrc を読み込まないため
    # wsl -- bash -lc "XXX" でログインシェル内で起動することを推奨する

    unset PROXY_PASSWORD  # メモリ上から削除（念のため）
    
    printf "\n"
    printf "Proxy用の環境変数を追加しました。\n"
fi

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
