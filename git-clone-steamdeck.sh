#!/bin/bash

REPO_URL="https://github.com/thaGG/steamdeck.git"
REPO_DIR="$HOME/steamdeck"

if [ ! -d "$REPO_DIR/.git" ]; then
    git clone "$REPO_URL" "$REPO_DIR"
else
    cd "$REPO_DIR" || exit 1
    git pull
fi