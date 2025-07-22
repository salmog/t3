
# to add new dir to push additional files from to the repo:
	#cd ~/t4
	#git init
	#git remote add origin git@github.com:salmog/t4.git  # Replace with your actual repo
	#git branch -M main
	#git add .
	#git commit -m "Initial commit"
	#git push -u origin main


#!/bin/bash
set -e

# === CONFIGURATION ===
GIT_USER_NAME="salmog"
GIT_USER_EMAIL="shay.almog.mbox@gmail.com"
SSH_KEY_PATH="$HOME/.ssh/key5"               # Change if your key is elsewhere
REPO_SSH_URL="git@github.com:salmog/t3.git"
REPO_LOCAL_DIR="$HOME/t3"
TICKERS=("QQQ" "SPY" "IBIT" "IWM")
INTERVALS=("1d" "1h" "4h" "1wk")

# === 1. Install Git if missing ===
echo "=== 1. Installing Git if missing ==="
if ! command -v git &>/dev/null; then
    apt update && apt install -y git
fi

# === 2. Git Identity Config ===
echo "=== 2. Configuring Git identity ==="
git config --global user.name "$GIT_USER_NAME"
git config --global user.email "$GIT_USER_EMAIL"

# === 3. SSH Key Setup ===
echo "=== 3. Checking for SSH private key ==="
if [ ! -f "$SSH_KEY_PATH" ]; then
    echo "❌ SSH key not found at $SSH_KEY_PATH"
    echo "Run this to create it:"
    echo "  ssh-keygen -t ed25519 -C \"$GIT_USER_EMAIL\" -f $SSH_KEY_PATH"
    echo "Then add $SSH_KEY_PATH.pub to GitHub: https://github.com/settings/keys"
    exit 1
fi

echo "=== 4. Starting SSH agent and adding key ==="
eval "$(ssh-agent -s)"
ssh-add "$SSH_KEY_PATH"

# === 5. Clone Repo If Needed ===
echo "=== 5. Cloning repo if missing ==="
if [ ! -d "$REPO_LOCAL_DIR/.git" ]; then
    git clone "$REPO_SSH_URL" "$REPO_LOCAL_DIR"
else
    echo "Repo already exists: $REPO_LOCAL_DIR"
fi

cd "$REPO_LOCAL_DIR"
git remote set-url origin "$REPO_SSH_URL"

# === 6. Create Folder Structure for All Tickers ===
echo "=== 6. Creating folder and file structure ==="
for ticker in "${TICKERS[@]}"; do
    dir="data/$ticker"
    mkdir -p "$dir"
    for interval in "${INTERVALS[@]}"; do
        touch "$dir/${ticker}_${interval}.csv"
    done
    touch "$dir/indicators.json"
    touch "$dir/meta.json"
done

# === 7. Git Add/Commit/Push ===
echo "=== 7. Git push only if there are new changes ==="
git add data/
if git diff --cached --quiet; then
    echo "✅ No new changes to commit."
else
    git commit -m "Add folder and file structure for tickers"
    git push origin main
    echo "✅ Changes pushed successfully."
fi

echo "=== ✅ ALL DONE ==="
