# Yay
pacman -S --needed git base-devel
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si

cd ~

rm -rf yay

# Jetbrains Mono font
wget https://download.jetbrains.com/fonts/JetBrainsMono-2.242.zip
unzip JetBrainsMono-2.242.zip "fonts/ttf/*" -d /usr/share/fonts

rm JetBrainsMono-2.242.zip