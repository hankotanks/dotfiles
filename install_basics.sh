#!/bin/bash
# X dependenceies
sudo apt install -y --no-install-recommends xorg xinit xclip 
# i3
sudo apt install -y --no-install-recommends i3 alacritty
# basics
sudo apt install -y --no-install-recommends build-essential wget tmux git tree neovim unzip clangd cmake

# link dotfiles
SOURCE_DIR="$PWD/userhome"
if [[ ! -d "$SOURCE_DIR" ]]; then
    echo "Source directory '$SOURCE_DIR' does not exist."
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
     echo "Dotfiles have been installed"
fi
