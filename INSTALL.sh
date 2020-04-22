#moebuntu icons
dir=$(pwd)
sudo tar xf  $dir/icons/MoePinkIcons_181013.tar.xz -C /usr/share/icons
xfconf-query -c xsettings -p /Net/IconThemeName -s MoePinkIcons

#moebuntu themes
sudo tar xf $dir/themes/Moe-Orange13.tar.xz -C /usr/share/themes
sudo tar xf $dir/themes/Moe-Pink13.tar.xz -C /usr/share/themes
sudo tar xf $dir/themes/Moe-Purple13.tar.xz -C /usr/share/themes
sudo tar xf $dir/themes/Moe-Red13.tar.xz -C /usr/share/themes
sudo tar xf $dir/themes/Moe-Yellow13.tar.xz -C /usr/share/themes
xfconf-query -c xsettings -p /Net/ThemeName -s Moe-Pink13
xfconf-query -c xfwm4 -p /general/theme -s Moe-Pink13


#For QT5
sudo apt install qt5-style-plugins
#For QT5
out=$(cat ~/.profile | grep "export QT_QPA_PLATFORMTHEME=gtk2" | wc -l)
str="export QT_QPA_PLATFORMTHEME=gtk2"
if [ $out = 0 ]; then echo "export QT_QPA_PLATFORMTHEME=gtk2" >> ~/.profile ; fi


#moebuntu shell2
#sudo tar xf $dir/shells/MoeOrangeShell2.tar.xz -C /usr/share/themes
#sudo tar xf $dir/shells/MoePinkShell2.tar.xz -C /usr/share/themes
#sudo tar xf $dir/shells/MoePurpleShell2.tar.xz -C /usr/share/themes
#sudo tar xf $dir/shells/MoeRedShell2.tar.xz -C /usr/share/themes
#sudo tar xf $dir/shells/MoeYellowShell2.tar.xz -C /usr/share/themes


#Log and Plymouth
#sudo mv /usr/share/gnome-shell/theme/ubuntu.css /usr/share/gnome-shell/theme/ubuntu.bak.css
#sudo cp /usr/share/themes/MoePinkShell2/gnome-shell/gnome-shell.css /usr/share/gnome-shell/theme/ubuntu.css
#sudo mv /usr/share/plymouth/ubuntu-logo.png /usr/share/plymouth/ubuntu-logo.bak.png
#sudo cp /usr/share/themes/MoePinkShell2/ubuntu-logo.png /usr/share/plymouth/ubuntu-logo.png

exit

