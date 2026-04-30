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
apt install -y --no-install-recommends build-essential wget curl tmux git tree unzip clangd cmake
curl -L https://github.com/neovim/neovim-releases/releases/download/v0.12.2/nvim-linux-x86_64.deb -o /tmp/nvim-linux-x86_64.deb
dpkg -i /tmp/nvim-linux-x86_64.deb
apt -f install
usermod -aG sudo $USER
"

SOURCE_DIR="$PWD/dotfiles"
process() {
    if [ -e "$1/.git" ]; then
	rm -f "${HOME%/}${1#$SOURCE_DIR}"
	ln -s "$1" "${HOME%/}${1#$SOURCE_DIR}"
	echo "$1 -> ${HOME%/}${1#$SOURCE_DIR}"
    else
	mkdir -p "${HOME%/}${1#$SOURCE_DIR}"
	find "$1" -mindepth 1 -maxdepth 1 -type f | while read -r FILE; do
	    rm -f "${HOME%/}${FILE#$SOURCE_DIR}"
	    ln -s "$FILE" "${HOME%/}${FILE#$SOURCE_DIR}"
            echo "$FILE -> ${HOME%/}${FILE#$SOURCE_DIR}"
        done
        find "$1" -mindepth 1 -maxdepth 1 -type d | while read -r SUB; do
	    process "$SUB"
        done

    fi
}

# link dotfiles
if [[ ! -d "$SOURCE_DIR" ]]; then
    echo "Failed to install dotfiles"
else
    process "$SOURCE_DIR"
    echo "Successfully installed dotfiles"
fi

