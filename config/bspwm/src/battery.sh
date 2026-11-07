#!/bin/bash
# https://github.com/Jimmy4TK/WorkSpace

while true; do
  bat_status=$(cat /sys/class/power_supply/BAT0/status)
  bat_charge=$(cat /sys/class/power_supply/BAT0/capacity)
  if [[ $bat_status == "Discharging" && $bat_charge -le 10 ]]; then
    dunstify "Bateria Baja" -i $HOME/.config/bspwm/assets/low_battery.png "Cargame la concha de tu madre"
  fi

  if [[ $bat_status == "Not charging" || $bat_status == "Full" ]]; then
    dunstify "Carga Completa" -i $HOME/.config/bspwm/assets/full_battery.png "Desenchufame culiado"
  fi

  sleep 60
done
