#bin/bash

interface=$(/bin/cat ~/.config/bspwm/src/.interface 2> /dev/null)
if [ -n "$interface" ]; then
  echo "󰈀 $(ifconfig $interface | grep 'inet ' | awk '{print $2}')"
else
  echo "Configura la interfaz haciendo 'echo interfaz de red de tu equipo (se puede ver con ifconfig) > .config/bspwm/src/interface"
fi
