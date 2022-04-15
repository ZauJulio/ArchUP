#!/bin/sh

# Author: Zaujulio - zauhdf@gmail.com
# Date: 2022-04-15
# Arch Linux, GNOME 42

# Save current backup

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

# Check if backup folder exists and if it is not empty
if [[ -d "./dump" && "$(ls -A ./dump)" ]]; then
  TIMESTAMP=$(date +%s)
  NAME="${TIMESTAMP}.bk.zip"

  echo "[ArchUP] BACKUP | Backup already exists, saving current as ${NAME} on /history"

  mkdir -p ./history

  nohup zip -r "./history/${NAME}" ./dump % >arch_up.log &
else # Create backup folder
  mkdir -p ./dump
  mkdir -p ./dump/keys
  mkdir -p ./dump/bash
  mkdir -p ./dump/system
  mkdir -p ./dump/system/udev
  mkdir -p ./dump/system/grub
  mkdir -p ./dump/ssh/user_config
  mkdir -p ./dump/ssh/etc
  mkdir -p ./dump/gnome/keybindings
  mkdir -p ./dump/gnome/themes
  mkdir -p ./dump/gnome/icons
  mkdir -p ./dump/gnome/backgrounds
  mkdir -p ./dump/gnome/gnome-shell-extensions
  mkdir -p ./dump/apps/guake
  mkdir -p ./dump/packages/
fi

echo "[ArchUP] BACKUP | Creating new backup"

################
##   Configs  ##
################
echo "[ArchUP] BACKUP | Configs:"

# Pacman configuration file
echo -e ' \t - /etc/pacman.conf'
cp /etc/pacman.conf ./dump/system/pacman.conf

# Git config
echo -e ' \t - .gitconfig'
cp ~/.gitconfig ./dump/bash/gitconfig

# Bash | ZSH config
echo -e ' \t - .bashrc, .zshrc'
cp ~/.bashrc ./dump/bash/bashrc
cp ~/.zshrc ./dump/bash/zshrc

# Commands history
echo -e ' \t - .zsh_history'
cp ~/.zsh_history ./dump/bash/zsh_history

# Webcam udev rules
echo -e ' \t - /etc/udev/rules.d/*'
cp -r /etc/udev/rules.d ./dump/system/udev/rules.d

# Kernel parameters
echo -e ' \t - /etc/sysctl.conf'
cp /etc/sysctl.conf ./dump/system/sysctl.conf

# Grub
echo -e ' \t - /etc/default/grub'
cp /etc/default/grub ./dump/system/grub/grub

# Grub theme
echo -e ' \t - /boot/grub/themes/*'
cp -r /boot/grub/themes ./dump/system/grub/themes

# Keys
echo -e ' \t - KEYS/*'
cp -r ~/KEYS/* ./dump/keys/

# SSH
echo -e ' \t - SSH'
sudo cp -r ~/.ssh/* ./dump/ssh/user_config
sudo cp -r /etc/ssh ./dump/ssh/etc

################
##    Gnome   ##
################
echo "[ArchUP] BACKUP | Gnome:"

# Keybindings
echo -e ' \t - Gnome keybindings'
dconf dump '/org/gnome/desktop/wm/keybindings/' >./dump/gnome/keybindings/wm.dconf
dconf dump '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/' >./dump/gnome/keybindings/media-keys.dconf

# Themes, icons and backgrounds
echo -e ' \t - Gnome themes, icons, backgrounds, extensions'
cp -r ~/.themes/* ./dump/gnome/themes
cp -r ~/.icons/* ./dump/gnome/icons
cp -r ~/.local/share/backgrounds/* ./dump/gnome/backgrounds
cp -r -f ~/.local/share/gnome-shell/extensions/* ./dump/gnome/gnome-shell-extensions

################
##    Apps    ##
################
echo "[ArchUP] BACKUP | Apps:"

# Guake config
echo -e ' \t - Guake config'

guake --save-preferences ./dump/apps/guake/guake.cfg

################
##  Packages  ##
################
echo "[ArchUP] BACKUP | Packages:"

# Pacman | AUR packages
echo -e ' \t - Pacman, AUR'
yay -Qe | cut -f 1 -d " " | paste -sd " " >./dump/packages/yay.txt

# Flatpak packages
echo -e ' \t - Flatpak'
flatpak list --columns=name | paste -sd " " >./dump/packages/flatpak.txt

# Snap packages
echo -e ' \t - Snap'
snap list | awk '{print $1}' | tail -n +2 | tr '\n' ' ' >./dump/packages/snap.txt

# NPM packages
echo -e ' \t - NPM'
awk -F"── " '{print $2}' <<<$(npm list -g --depth=0 | cut -f 1 -d "@" | awk 'NR>1') | paste -sd " " >./dump/packages/npm_packages.txt

wait < <(jobs -p) # Wait for all jobs to finish
