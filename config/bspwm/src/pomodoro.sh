#!/bin/bash
# https://github.com/Jimmy4TK/WorkSpace

pomodoro=$HOME/.config/bspwm/src/.pomodoro
echo 1 > $pomodoro

case "$1" in
  --open)
    while [ $(cat $pomodoro) -eq 1 ]; do
      dunstify "Pomodoro" "Empiezan los 40 minutos de concentracion"
      sleep 1200 # 1200 segundos = 20 minutos

      dunstify "Pomodoro" "Faltan 20 minutos para el descanso"
      sleep 1200

      if [[ $(cat $pomodoro) -eq 1 ]]; then
        kitty --class=FloaTerm -o initial_window_width=842 -o initial_window_height=495 -e bash -c "$HOME/.config/bspwm/src/pomodoro.sh --rest" > /dev/null 2>&1
      else
        break 
      fi
    done
    ;;
  --close)
    echo 0 > "$HOME/.config/bspwm/src/.pomodoro"
    ;;
  --rest)
    declare -A map_ascii
    map_ascii[1,0]='  /$$$$$$   '
    map_ascii[2,0]=' /$$$_  $$  '
    map_ascii[3,0]='| $$$$\ $$  '
    map_ascii[4,0]='| $$ $$ $$  '
    map_ascii[5,0]='| $$\ $$$$  '
    map_ascii[6,0]='| $$ \ $$$  '
    map_ascii[7,0]='|  $$$$$$/  '
    map_ascii[8,0]=' \______/   '
    map_ascii[1,1]='   /$$      '
    map_ascii[2,1]='  /$$$$     '
    map_ascii[3,1]=' |_  $$     '
    map_ascii[4,1]='   | $$     '
    map_ascii[5,1]='   | $$     '
    map_ascii[6,1]='   | $$     '
    map_ascii[7,1]=' /$$$$$$$$  '
    map_ascii[8,1]='|________/  '
    map_ascii[1,2]='  /$$$$$$   '
    map_ascii[2,2]=' /$$__  $$  '
    map_ascii[3,2]='|__/  \ $$  '
    map_ascii[4,2]='  /$$$$$$/  '
    map_ascii[5,2]=' /$$____/   '
    map_ascii[6,2]='| $$        '
    map_ascii[7,2]='| $$$$$$$$  '
    map_ascii[8,2]='|________/  '
    map_ascii[1,3]='  /$$$$$$   '
    map_ascii[2,3]=' /$$__  $$  '
    map_ascii[3,3]='|__/  \ $$  '
    map_ascii[4,3]='   /$$$$$/  '
    map_ascii[5,3]='  |___  $$  '
    map_ascii[6,3]=' /$$  \ $$  '
    map_ascii[7,3]='|  $$$$$$/  '
    map_ascii[8,3]=' \______/   '
    map_ascii[1,4]=' /$$   /$$  '
    map_ascii[2,4]='| $$  | $$  '
    map_ascii[3,4]='| $$  | $$  '
    map_ascii[4,4]='| $$$$$$$$  '
    map_ascii[5,4]='|_____  $$  '
    map_ascii[6,4]='      | $$  '
    map_ascii[7,4]='      | $$  '
    map_ascii[8,4]='      |__/  '
    map_ascii[1,5]=' /$$$$$$$   '
    map_ascii[2,5]='| $$____/   '
    map_ascii[3,5]='| $$        '
    map_ascii[4,5]='| $$$$$$$   '
    map_ascii[5,5]='|_____  $$  '
    map_ascii[6,5]=' /$$  \ $$  '
    map_ascii[7,5]='|  $$$$$$/  '
    map_ascii[8,5]=' \______/   '
    map_ascii[1,6]='  /$$$$$$   '
    map_ascii[2,6]=' /$$__  $$  '
    map_ascii[3,6]='| $$  \__/  '
    map_ascii[4,6]='| $$$$$$$   '
    map_ascii[5,6]='| $$__  $$  '
    map_ascii[6,6]='| $$  \ $$  '
    map_ascii[7,6]='|  $$$$$$/  '
    map_ascii[8,6]=' \______/   '
    map_ascii[1,7]=' /$$$$$$$$  '
    map_ascii[2,7]='|_____ $$/  '
    map_ascii[3,7]='     /$$/   '
    map_ascii[4,7]='    /$$/    '
    map_ascii[5,7]='   /$$/     '
    map_ascii[6,7]='  /$$/      '
    map_ascii[7,7]=' /$$/       '
    map_ascii[8,7]='|__/        '
    map_ascii[1,8]='  /$$$$$$   '
    map_ascii[2,8]=' /$$__  $$  '
    map_ascii[3,8]='| $$  \ $$  '
    map_ascii[4,8]='|  $$$$$$/  '
    map_ascii[5,8]=' >$$__  $$  '
    map_ascii[6,8]='| $$  \ $$  '
    map_ascii[7,8]='|  $$$$$$/  '
    map_ascii[8,8]=' \______/   '
    map_ascii[1,9]='  /$$$$$$   '
    map_ascii[2,9]=' /$$__  $$  '
    map_ascii[3,9]='| $$  \ $$  '
    map_ascii[4,9]='|  $$$$$$$  '
    map_ascii[5,9]=' \____  $$  '
    map_ascii[6,9]=' /$$  \ $$  '
    map_ascii[7,9]='|  $$$$$$/  '
    map_ascii[8,9]=' \______/   '
    map_ascii[1,10]='      '
    map_ascii[2,10]=' /$$  '
    map_ascii[3,10]='|__/  '
    map_ascii[4,10]='      '
    map_ascii[5,10]='      '
    map_ascii[6,10]=' /$$  '
    map_ascii[7,10]='|__/  '
    map_ascii[8,10]='      '
    tiempo_descanso=300
    while [ $tiempo_descanso -ne 0 ]; do
      minutos=$(( $tiempo_descanso / 60 ))
      segundos=$(( $tiempo_descanso % 60 ))
      segundos_digito_1=$(( $segundos / 10 ))
      segundos_digito_2=$(( $segundos % 10 ))
      clear
      echo "



      

      "
      for i in {1..8}; do
        echo "                              ${map_ascii["${i},${minutos}"]} ${map_ascii["${i},10"]} ${map_ascii["${i},${segundos_digito_1}"]} ${map_ascii["${i},${segundos_digito_2}"]}"
      done
      sleep 1
      ((tiempo_descanso-=1))
    done
    ;;
esac
