#moebuntu icons query
xfconf-query -c xsettings -p /Net/IconThemeName -s Mint-X

#moebuntu themes query
xfconf-query -c xsettings -p /Net/ThemeName -s Mint-X
xfconf-query -c xfwm4 -p /general/theme -s Mint-X

#remove icons
sudo rm -rRf /usr/share/icons/MoePinkIcons

#remove themes
sudo rm -rRf /usr/share/themes/Moe-Pink13
sudo rm -rRf /usr/share/themes/Moe-Yellow13
sudo rm -rRf /usr/share/themes/Moe-Orange13
sudo rm -rRf /usr/share/themes/Moe-Red13
sudo rm -rRf /usr/share/themes/Moe-Purple13

exit

