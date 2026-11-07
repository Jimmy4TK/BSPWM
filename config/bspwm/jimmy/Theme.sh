#!/usr/bin/env bash
# Basado en gh0stzk/dotfiles (https://github.com/gh0stzk/dotfiles), GPL-3.0. Copyright (C) 2021-2026 gh0stzk. Modificado por Jimmy Falco (Jimmy4TK), 2026.

# Terminate existing processes if necessary.
. "${HOME}"/.config/bspwm/src/Process.bash

# Bspwm border		# Fade true|false	# Shadows true|false	# Corner radius		# Shadow color
BORDER_WIDTH="0"	P_FADE="true"		P_SHADOWS="true"		P_CORNER_R="20"		SHADOW_C="#000000"

# (Lovelace) colorscheme from Elenapan
bg="#1D1F28"  fg="#FDFDFD"

black="#282A36"   red="#F37F97"   green="#5ADECD"   yellow="#F2A272"
blackb="#414458"  redb="#FF4971"  greenb="#18E3C8"  yellowb="#FF8037"

blue="#8897F4"   magenta="#C574DD"   cyan="#79E6F3"   white="#FDFDFD"
blueb="#556FFF"  magentab="#B043D1"  cyanb="#3FDCEE"  whiteb="#BEBEC1"

# Set bspwm configuration
set_bspwm_config() {
	bspc config border_width ${BORDER_WIDTH}
	bspc config top_padding 53
	bspc config bottom_padding 1
	bspc config left_padding 1
	bspc config right_padding 1
	bspc config normal_border_color "${magenta}"
	bspc config active_border_color "${green}"
	bspc config focused_border_color "${blue}"
	bspc config presel_feedback_color "${redb}"
}

# Launch theme
launch_theme() {
	# Set random wallpaper for actual rice
	feh --no-fehbg --bg-fill "${HOME}"/.config/bspwm/jimmy/walls

	# Launch dunst notification daemon
	dunst -config "${HOME}"/.config/bspwm/dunstrc &

	# Launch polybar
	for mon in $(polybar --list-monitors | cut -d":" -f1); do
		(MONITOR=$mon polybar jimmy1 -c "${HOME}"/.config/bspwm/jimmy/config.ini) &
		(MONITOR=$mon polybar jimmy2 -c "${HOME}"/.config/bspwm/jimmy/config.ini) &
		(MONITOR=$mon polybar jimmy3 -c "${HOME}"/.config/bspwm/jimmy/config.ini) &
		(MONITOR=$mon polybar jimmy4 -c "${HOME}"/.config/bspwm/jimmy/config.ini) &
		(MONITOR=$mon polybar jimmy5 -c "${HOME}"/.config/bspwm/jimmy/config.ini) &
		(MONITOR=$mon polybar jimmy6 -c "${HOME}"/.config/bspwm/jimmy/config.ini) &
	done
}

### Apply Configurations

set_bspwm_config
launch_theme
