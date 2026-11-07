#!/bin/bash

sleep 1 && maim /tmp/locking_screen.png &
wait

convert -blur 0x12 /tmp/locking_screen.png /tmp/screen_blur.png

convert -composite /tmp/screen_blur.png ~/.config/bspwm/assets/RickYMorty.png -gravity Center -geometry +0+0 /tmp/screen.png

xset dpms 5 5 5

i3lock -i /tmp/screen.png

kill -SIGSTOP $(pgrep -f pomodoro)
kill -SIGSTOP $(pgrep -f dunst)
while pgrep -x 'i3lock' > /dev/null; do
  sleep 5
done

kill -SIGCONT $(pgrep -f pomodoro)
kill -SIGCONT $(pgrep -f dunst)
rm /tmp/*screen*.png
xset dpms 0 0 0
