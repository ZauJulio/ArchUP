#!/bin/sh

# Author: Zaujulio - zauhdf@gmail.com
# Date: 2022-04-15
# Arch Linux, GNOME 42

# Restore backup

echo "
      ___           ___           ___           ___           ___           ___   
     /  /\         /  /\         /  /\         /__/\         /__/\         /  /\  
    /  /::\       /  /::\       /  /:/         \  \:\        \  \:\       /  /::\ 
   /  /:/\:\     /  /:/\:\     /  /:/           \__\:\        \  \:\     /  /:/\:\/
  /  /:/~/::\   /  /:/~/:/    /  /:/  ___   ___ /  /::\   ___  \  \:\   /  /:/~/:/
 /__/:/ /:/\:\ /__/:/ /:/___ /__/:/  /  /\ /__/\  /:/\:\ /__/\  \__\:\ /__/:/ /:/ 
 \  \:\/:/__\/ \  \:\/:::::/ \  \:\ /  /:/ \  \:\/:/__\/ \  \:\ /  /:/ \  \:\/:/  
  \  \::/       \  \::/~~~~   \  \:\  /:/   \  \::/       \  \:\  /:/   \  \::/   
   \  \:\        \  \:\        \  \:\/:/     \  \:\        \  \:\/:/     \  \:\   
    \  \:\        \  \:\        \  \::/       \  \:\        \  \::/       \  \:\  
     \__\/         \__\/         \__\/         \__\/         \__\/         \__\/  
"

read -p ":: Proceed? [Y/n] " -n 1 -r
echo      # (optional) move to a new line
sudo echo # (optional) get temp permissions

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo ":: ArchUP exit"
  exit 1
fi

if [[  ! -d "./dump" || ! "$(ls -A ./dump)" ]]; then
  echo "[ArchUP] RESTORE | Backup folder is empty, nothing to restore"
  exit 1
fi

echo "[ArchUP] Restore backup"

################
##   Configs  ##
################
echo "[ArchUP] Restore | Configs:"

# Pacman configuration file
echo -e ' \t - /etc/pacman.conf'
sudo cp ./dump/system/pacman.conf /etc/pacman.conf

# Git config
echo -e ' \t - .gitconfig'
cp ./dump/bash/gitconfig ~/.gitconfig

# Bash | ZSH config
echo -e ' \t - .bashrc, .zshrc'
cp ./dump/bash/bashrc ~/.bashrc
cp ./dump/bash/zshrc ~/.zshrc

# Commands history
echo -e ' \t - .zsh_history'
cp ./dump/bash/zsh_history ~/.zsh_history

# Webcam udev rules
echo -e ' \t - /etc/udev/rules.d/*'
sudo cp ./dump/system/udev/rules.d/* /etc/udev/rules.d/

# Kernel parameters
echo -e ' \t - /etc/sysctl.conf'
sudo cp ./dump/system/sysctl.conf /etc/sysctl.conf

# Grub
echo -e ' \t - /etc/default/grub'
sudo cp ./dump/system/grub/grub /etc/default/grub

# Grub theme
echo -e ' \t - /boot/grub/themes/*'
sudo cp /dump/system/grub/themes/* /boot/grub/themes/

# Keys
echo -e ' \t - KEYS/*'
cp ./dump/keys/* ~/KEYS

# SSH
echo -e ' \t - SSH'
sudo cp ./dump/ssh/user_config/* ~/.ssh
sudo cp ./dump/ssh/etc/* /etc/ssh

################
##    Gnome   ##
################
echo "[ArchUP] RESTORE | Gnome:"

# Keybindings
echo -e ' \t - Gnome keybindings'
dconf load '/org/gnome/desktop/wm/keybindings/' <./dump/gnome/keybindings/wm.dconf
dconf load '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/' <./dump/gnome/keybindings/media-keys.dconf

# Themes, icons and backgrounds
echo -e ' \t - Gnome themes, icons, backgrounds, extensions'
cp ./dump/gnome/themes/* ~/.themes
cp ./dump/gnome/icons/* ~/.icons
cp ./dump/gnome/backgrounds/* ~/.local/share/backgrounds
cp ./dump/gnome/gnome-shell-extensions/* ~/.local/share/gnome-shell/extensions

################
##    Apps    ##
################
echo "[ArchUP] RESTORE | Apps:"

# Guake config
echo -e ' \t - Guake config'
guake --restore-preferences ./dump/apps/guake/guake.cfg

################
##  Packages  ##
################
echo "[ArchUP] RESTORE | Packages:"

# Pacman | AUR packages
echo -e ' \t - Pacman, AUR'
yay -Syyu --noconfirm $(cat ./dump/packages/yay.txt)

# Flatpak packages
echo -e ' \t - Flatpak'
flatpak install -y $(cat ./dump/packages/flatpak.txt)

# Snap packages
echo -e ' \t - Snap'
sudo snap install $(cat ./dump/packages/snap.txt)

# NPM packages
echo -e ' \t - NPM'
npm i -g $(cat ./dump/packages/npm_packages.txt)

