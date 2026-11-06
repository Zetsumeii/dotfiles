#!/bin/sh
   
# Merge X resources
[ -f ~/.Xresources ] && xrdb -merge ~/.Xresources

setxkbmap -layout fr
numlockx on

feh --bg-fill /home/zetsumei/dotfiles/wallpapers/wallhaven-6ld5kx.png
picom &
dwmblocks &
flameshot &
exec dwm
