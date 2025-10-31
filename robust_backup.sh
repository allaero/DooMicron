#!/bin/bash
cd ~/printer_data/config

# Check for corruption and fix it
if ! git fsck --no-dangling 2>&1 | grep -q "^$"; then
    echo "Corruption detected, attempting repair..."
    git gc --prune=now
    git fsck --full
fi

# Try to add and commit
git add .
if ! git commit -m "Auto backup from $(date +'%Y-%m-%d %H:%M:%S')"; then
    echo "Commit failed, repo may be corrupted. Reinitializing..."
    rm -rf .git
    git init
    git branch -M main
    git remote add origin https://github.com/allaero/DooMicron.git
    git add .
    git commit -m "Recovered backup from $(date +'%Y-%m-%d %H:%M:%S')"
    git push -u origin main --force
    exit 0
fi

# Try to push, pull if rejected
if ! git push origin main; then
    echo "Push rejected, pulling and retrying..."
    git pull origin main --rebase
    git push origin main
fi
