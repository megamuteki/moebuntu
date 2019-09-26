#moebuntu icons query
xfconf-query -c xsettings -p /Net/IconThemeName -s MoePinkIcons
#moebuntu themes query
xfconf-query -c xsettings -p /Net/ThemeName -s Moe-Pink13
xfconf-query -c xfwm4 -p /general/theme -s Moe-Pink13

#For QT5
out=$(cat ~/.profile | grep "export QT_QPA_PLATFORMTHEME=gtk2" | wc -l)
str="export QT_QPA_PLATFORMTHEME=gtk2"

if [ $out = 0 ]; then echo "export QT_QPA_PLATFORMTHEME=gtk2" >> ~/.profile ; fi

exit

