#!/bin/bash

# Author: Enríquez González https://github.com/AlvinPix
# instagram: @alvinpx_271
# facebook: @alvin.gonzalez.13139

# VARIABLE DATABASE AND OTHER THINGS
RUTE=$(pwd)

# COLOR USE THE SCRIPT
Black='\033[1;30m'
Red='\033[1;31m'
Green='\033[1;32m'
Yellow='\033[1;33m'
Blue='\033[1;34m'
Purple='\033[1;35m'
Cyan='\033[1;36m'
White='\033[1;37m'
NC='\033[0m'
blue='\033[0;34m'
white='\033[0;37m'
lred='\033[0;31m'
IWhite="\[\033[0;97m\]"

# CHECK ROOT USER
if [ $(id -u) -ne 0 ]; then
	echo ""
	echo -e "${White} [${Blue}i${White}] You must be root user to run the script"
exit
fi

install_addons () {
	# Detectar el usuario no-root que ejecuto el script (via sudo)
	local REAL_USER="${SUDO_USER:-$(whoami)}"
	local REAL_HOME="/home/${REAL_USER}"

	echo ""
	echo -e "${White} [${Blue}i${White}] Last step installing the powerlevel10k, fzf, sudo-plugin, and others for the root user"
	echo -e "${White} [${Blue}i${White}] Real user detected: ${Red}${REAL_USER}${White}"
	sleep 3
	echo ""
	cd ${RUTE} ; cp -r scripts /root
	cd ${RUTE}/root ; cp -r .p10k.zsh /root; cp -r ${RUTE}/root/.zshrc /root/.zshrc
	cd /root ; git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
	echo ""
	cd /root ; git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
	~/.fzf/install
	echo ""
}

# CALLS
reset
install_addons
