#bin/bash

target=$(/bin/cat ~/.config/bspwm/src/.target 2> /dev/null)
if [ -n "$target" ]; then
  echo "󰓾 $target"
else
  echo "󰓾 No target"
fi
