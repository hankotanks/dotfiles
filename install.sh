#!/bin/bash

# configure sudo and install basics
su - root -c "
apt update && apt upgrade
# sudo
apt install -y --no-install-recommends sudo
# X
apt install -y --no-install-recommends xorg xinit xclip
# i3
apt install -y --no-install-recommends i3 alacritty
# basics
apt install -y --no-install-recommends build-essential wget tmux git tree neovim unzip clangd cmake
usermod -aG sudo $USER
"

# link dotfiles
SOURCE_DIR="$PWD/dotfiles"
if [[ ! -d "$SOURCE_DIR" ]]; then
    echo "Failed to install dotfiles"
else
    find "$SOURCE_DIR" -type f | while read -r FILE; do
        REL_PATH="${FILE#$SOURCE_DIR/}"
	TARGET="$HOME/$REL_PATH"
        mkdir -p "$(dirname "$TARGET")"
        if [[ -e "$TARGET" || -L "$TARGET" ]]; then
            echo "Removing: $TARGET"
            rm -rf "$TARGET"
        fi
        ln -s "$FILE" "$TARGET"
        echo "Linked: $FILE"
     done
     echo "Successfully installed dotfiles"
fi

