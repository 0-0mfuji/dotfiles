#!/bin/bash

# 鍵のファイル名（変更可能）
KEY_NAME="kagi"
KEY_PATH="$HOME/.ssh/$KEY_NAME"
CONFIG_PATH="$HOME/.ssh/config"

# 既存の鍵があればバックアップ
if [ -f "$KEY_PATH" ]; then
    echo "[Info] 既存の鍵が見つかりました。バックアップを作成します。"
    mv "$KEY_PATH" "$KEY_PATH.bak"
    mv "$KEY_PATH.pub" "$KEY_PATH.pub.bak"
fi

# 鍵を生成
echo "[Step] GitHub用のSSH鍵を生成します..."
ssh-keygen -t ed25519 -N "" -f "$KEY_PATH"

# OSに応じて公開鍵をクリップボードにコピー
echo "[Step] 公開鍵をクリップボードにコピーします..."
if command -v pbcopy &>/dev/null; then
    pbcopy < "$KEY_PATH.pub"
    echo "[OK] 公開鍵をクリップボードにコピーしました（Mac）"
elif command -v xclip &>/dev/null; then
    xclip -selection clipboard < "$KEY_PATH.pub"
    echo "[OK] 公開鍵をクリップボードにコピーしました（Linux）"
else
    echo "[警告] pbcopy または xclip が見つかりません。公開鍵を手動でコピーしてください:"
    cat "$KEY_PATH.pub"
fi

# ~/.ssh/config に設定を追加（なければ）
echo "[Step] ~/.ssh/config にGitHubの設定を追加します..."
if ! grep -q "Host github.com" "$CONFIG_PATH" 2>/dev/null; then
    {
        echo ""
        echo "Host github.com"
        echo "  IdentityFile $KEY_PATH"
        echo "  User git"
    } >> "$CONFIG_PATH"
    chmod 600 "$CONFIG_PATH"
    echo "[OK] SSH設定を更新しました。"
else
    echo "[Info] ~/.ssh/config に既に GitHub の設定があります。"
fi

# 接続テストは行わない
echo "[注意] 接続テスト（ssh -T git@github.com）は実行していません。必要であれば後で手動で行ってください。"

# 完了メッセージ
echo "[完了] GitHub用SSH鍵の設定が完了しました。"
echo "🔑 公開鍵を GitHub に貼り付けてください：https://github.com/settings/keys"
