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


# Setup Proxy
echo
echo -e "\e[36mインターネット接続のためにProxyを設定します。\e[0m"

unset HISTFILE  # 履歴ファイル無効化（念のため）
 
# PROXY情報
source ~/.profile 2>/dev/null || true

if [[ -n "${PROXY_USER:-}" && "${HTTP_PROXY:-}" == *"${PROXY_USER}"* ]]; then
    echo "既にPROXY_USERが設定されているため、Proxy設定をスキップします。"
else
    PROXY_HOST="172.16.44.6"     # PROXYサーバアドレス
    PROXY_PORT="8080"

    echo
    read -p "Proxy用ユーザー名を入力: " PROXY_USER

    while true; do
        read -s -p "Proxy用のパスワードを入力: " PROXY_PASSWORD
        echo
        read -s -p "確認用にパスワードを再入力: " PROXY_PASSWORD_CONFIRM
        echo
        if [[ "$PROXY_PASSWORD" == "$PROXY_PASSWORD_CONFIRM" ]]; then
            break
        else
            echo "パスワードが一致しません。もう一度入力してください。"
        fi
    done
    echo
    
    export HTTP_PROXY="http://${PROXY_USER}:${PROXY_PASSWORD}@${PROXY_HOST}:${PROXY_PORT}"
    export HTTPS_PROXY="$HTTP_PROXY"
    export https_proxy="$HTTP_PROXY"

    # プロキシ環境変数を~/.profileと~/.bashrcの末尾に追加
    echo "" >> ~/proxy_env
    echo "# Proxy settings added by setup.sh" >> ~/proxy_env
    echo "export PROXY_USER=\"${PROXY_USER}\"" >> ~/proxy_env
    echo "export HTTP_PROXY=\"${HTTP_PROXY}\"" >> ~/proxy_env
    echo "export HTTPS_PROXY=\"${HTTPS_PROXY}\"" >> ~/proxy_env
    echo "export http_proxy=\"${HTTPS_PROXY}\"" >> ~/proxy_env

    # ~/.profile はVSCodeのDevcontainerで読み込まれるため必要
    cat ~/proxy_env >> ~/.profile
    # ~/.bashrc は wsl bash -c XXX などで読み込まれるため必要
    cat ~/proxy_env >> ~/.bashrc
    # wsl XXX のように直接起動のコマンドには反映されないので注意

    unset PROXY_PASSWORD  # メモリ上から削除（念のため）
    
    echo
    echo "Proxy用の環境変数を追加しました。"
fi
echo


