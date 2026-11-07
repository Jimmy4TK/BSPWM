#!/usr/bin/env bash
#   Script to install my dotfiles (Ubuntu/Debian)
#   Author: Jimmy4TK
#   url: https://github.com/Jimmy4TK

CRE=$(tput setaf 1)
CYE=$(tput setaf 3)
CGR=$(tput setaf 2)
CBL=$(tput setaf 4)
BLD=$(tput bold)
CNC=$(tput sgr0)

backup_folder="$HOME/.Backup_config"
error_log="$HOME/.DotError.log"
date=$(date +%Y%m%d-%H%M%S)

# Directorio donde esta clonado el repo (el del propio script)
repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

########## ---------- You must not run this as root ---------- ##########

if [ "$(id -u)" = 0 ]; then
    echo "No uses usuario root."
    exit 1
fi

if ! command -v apt-get >/dev/null 2>&1; then
    printf "%s%sEste script es para Ubuntu/Debian (apt). Para Arch usa la rama 'main'.%s\n" "${BLD}" "${CRE}" "${CNC}"
    exit 1
fi

########## ---------- Welcome ---------- ##########

printf "Bienvenido!\n"
printf '%s%sEste script revisa las dependencias necesarias y las instala.\nDespues de eso creara un backup de tus archivos y copia los nuevos archivos en tu computadora.\n\nEstos dotfiles no modifican nada de tu configuracion de sistema.\nSe pedira tu contraseña de root para descargar las dependecias necesarias y/o para cambiar a zsh shell si no es la tuya por defecto.\n\nEste script no tiene la potencia para romper tu sistema, solo copia archivos de mi repositorio a tu HOME directory.%s\n\n' "${BLD}" "${CRE}" "${CNC}"

while true; do
    read -rp " Queres continuar pibe? [y/N]: " yn
    case $yn in
        [Yy]* ) break ;;
        [Nn]* ) exit ;;
        * ) printf " Error: Escribi 'y' o 'n'\n\n" ;;
    esac
done
clear

########## ---------- Install packages ---------- ##########

printf "Instalando paquetes necesarios...\n"

# Probado en Ubuntu 24.04. En 22.04 no existen 'pamixer' ni 'eza' (eza se instala con cargo mas abajo)
dependencias=(build-essential pkg-config curl wget bat net-tools bspwm sxhkd unzip git dunst feh gvfs-backends kitty \
              imagemagick jq jgmenu maim npm picom polybar libdbusmenu-glib-dev libdbusmenu-gtk3-dev papirus-icon-theme \
              xclip ranger rofi tmux policykit-1-gnome fonts-inconsolata fonts-jetbrains-mono fonts-terminus-otb \
              xdo xdotool zsh zsh-autosuggestions zsh-syntax-highlighting libwebp-dev python3-gi \
              x11-utils x11-xserver-utils x11-xkb-utils webp-pixbuf-loader xdg-user-dirs i3lock xss-lock \
              pamixer brightnessctl redshift bluez network-manager fzf ripgrep fontconfig eza \
              libgtk-3-dev libglib2.0-dev libpango1.0-dev libcairo2-dev libgdk-pixbuf-2.0-dev)

is_installed() {
    dpkg-query -W -f='${Status}' "$1" 2>/dev/null | grep -q 'install ok installed'
}

printf "%s%sActualizando lista de paquetes...%s\n" "${BLD}" "${CBL}" "${CNC}"
sudo apt-get update >/dev/null 2>> "$error_log"

printf "%s%sRevisando paquetes necesarios...%s\n" "${BLD}" "${CBL}" "${CNC}"
for paquete in "${dependencias[@]}"; do
    if ! is_installed "$paquete"; then
        if sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "$paquete" >/dev/null 2>> "$error_log"; then
            printf "%s%s%s %sSe instalo correctamente.%s\n" "${BLD}" "${CYE}" "$paquete" "${CBL}" "${CNC}"
            sleep 1
        else
            printf "%s%s%s %sNo se instalo correctamente. Mira %s%s %spara mas detalles.%s\n" "${BLD}" "${CYE}" "$paquete" "${CRE}" "${CBL}" "$error_log" "${CRE}" "${CNC}"
            sleep 1
        fi
    else
        printf '%s%s%s %sYa esta instalado en tu sistema!%s\n' "${BLD}" "${CYE}" "$paquete" "${CGR}" "${CNC}"
        sleep 1
    fi
done
sleep 5
clear

########## ---------- Preparing Folders ---------- ##########

# Verifies if the archive user-dirs.dirs doesn't exist in ~/.config
if [ ! -e "$HOME/.config/user-dirs.dirs" ]; then
    xdg-user-dirs-update
fi

########## ---------- Backup files ---------- ##########

printf "Backupeando archivos\n"

printf "Las configuraciones de Neovim y tmux son opcionales. Si ya tenes alguna configurada y no te gustaria cambiarla apreta 'n' en su pregunta. Si tu respuesta es 'y' tu configuracion actual va a ser movida al archivo de backups.\n\n"

# Pregunta y/n; deja la respuesta en la variable cuyo nombre se pasa
ask_yn() {
    local answer
    while true; do
        read -rp "$1 (y/n): " answer
        if [[ "$answer" == "y" || "$answer" == "n" ]]; then
            printf -v "$2" '%s' "$answer"
            break
        else
            echo "Entrada invalida. Ingresa 'y' o 'n'."
        fi
    done
}

ask_yn "Queres probar mi configuracion de NeoVim?" try_nvim
ask_yn "Queres probar mi configuracion de tmux?" try_tmux

printf "\nLos archivos de BackUp estan en %s%s%s%s \n\n" "${BLD}" "${CRE}" "$backup_folder" "${CNC}"
sleep 10

[ ! -d "$backup_folder" ] && mkdir -p "$backup_folder"

for folder in bspwm picom rofi eww sxhkd dunst kitty polybar ranger zsh zsh-config; do
    if [ -d "$HOME/.config/$folder" ]; then
        if mv "$HOME/.config/$folder" "$backup_folder/${folder}_$date" 2>> "$error_log"; then
            printf "%s%s%s Se hizo el backup correctamente %s%s/%s_%s%s\n" "${BLD}" "${CGR}" "$folder" "${CBL}" "$backup_folder" "$folder" "$date" "${CNC}"
            sleep 1
        else
            printf "%s%sFallo el backup de la carpeta %s. Revisa %sDotError.log%s\n" "${BLD}" "${CRE}" "$folder" "${CBL}" "${CNC}"
            sleep 1
        fi
    else
        printf "%s%s%s La carpeta no existe, %sno necesita backup%s\n" "${BLD}" "${CGR}" "$folder" "${CYE}" "${CNC}"
        sleep 1
    fi
done

# Backup de las configuraciones opcionales que se van a reemplazar
for optional in nvim tmux; do
    try_var="try_$optional"
    [[ ${!try_var} == "y" ]] || continue
    if [ -d "$HOME/.config/$optional" ]; then
        if mv "$HOME/.config/$optional" "$backup_folder/${optional}_$date" 2>> "$error_log"; then
            printf "%s%s Carpeta de %s backupeada correctamente en %s%s/%s_%s%s\n" "${BLD}" "${CGR}" "$optional" "${CBL}" "$backup_folder" "$optional" "$date" "${CNC}"
            sleep 1
        else
            printf "%s%sFallo el backup de la carpeta %s. Revisa %sDotError.log%s\n" "${BLD}" "${CRE}" "$optional" "${CBL}" "${CNC}"
            sleep 1
        fi
    else
        printf "%s%s La carpeta %s no existe, %sno necesita backup%s\n" "${BLD}" "${CGR}" "$optional" "${CYE}" "${CNC}"
        sleep 1
    fi
done

for file in .zshrc .zsh_functions; do
    if [ -f "$HOME/$file" ]; then
        if mv "$HOME/$file" "$backup_folder/${file}_$date" 2>> "$error_log"; then
            printf "%s%s%s archivo backupeado correctamente en %s%s/%s_%s%s\n" "${BLD}" "${CGR}" "$file" "${CBL}" "$backup_folder" "$file" "$date" "${CNC}"
        else
            printf "%s%sFallo el backup de %s. Revisa %sDotError.log%s\n" "${BLD}" "${CRE}" "$file" "${CBL}" "${CNC}"
        fi
    else
        printf "%s%sEl archivo %s no existe, %sno necesita backup%s\n" "${BLD}" "${CGR}" "$file" "${CYE}" "${CNC}"
    fi
done

printf "%s%sListorti!!%s\n\n" "${BLD}" "${CGR}" "${CNC}"
sleep 5

########## ---------- Copy the Rice! ---------- ##########

printf "Instalando dotfiles..\n"
printf "Copiando archivos a sus directorios correspondientes..\n"

mkdir -p "$HOME/.config" "$HOME/.local/bin" "$HOME/.local/share"

for dirs in "$repo_dir"/config/*; do
    dir_name=$(basename "$dirs")
    # nvim y tmux tienen sus propios repos y se clonan mas abajo
    if [[ $dir_name == "nvim" || $dir_name == "tmux" ]]; then
        continue
    fi
    if cp -R "$dirs" "$HOME/.config/" 2>> "$error_log"; then
        printf "%s%s%s %sconfiguracion instalada correctamente%s\n" "${BLD}" "${CYE}" "$dir_name" "${CGR}" "${CNC}"
        sleep 1
    else
        printf "%s%s%s %sla configuracion fallo, revisa %sDotError.log %spara más detalles.%s\n" "${BLD}" "${CYE}" "$dir_name" "${CRE}" "${CBL}" "${CRE}" "${CNC}"
        sleep 1
    fi
done

for folder in applications; do
    if cp -r "$repo_dir/share/$folder" "$HOME/.local/share/" 2>> "$error_log"; then
        printf "%s%s%s %sCarpeta copiada correctamente!%s\n" "${BLD}" "${CYE}" "$folder" "${CGR}" "${CNC}"
        sleep 1
    else
        printf "%s%s%s %sfallo la copia de la carpeta, revisa %sDotError.log %spara más detalles.%s\n" "${BLD}" "${CYE}" "$folder" "${CRE}" "${CBL}" "${CRE}" "${CNC}"
        sleep 1
    fi
done

# Installing zsh config (repo Zsh-Config)
printf "%s%sClonando configuracion de zsh%s\n" "${BLD}" "${CBL}" "${CNC}"
if git clone --depth 1 https://github.com/Jimmy4TK/Zsh-Config "$HOME/.config/zsh-config" 2>> "$error_log"; then
    ln -sf "$HOME/.config/zsh-config/.zshrc" "$HOME/.zshrc"
    # Alias de ejemplo, solo si el usuario no tiene los suyos
    [ -e "$HOME/.zsh_aliases" ] || cp "$HOME/.config/zsh-config/.zsh_aliases.example" "$HOME/.zsh_aliases" 2>> "$error_log"
    # Funciones de zsh para BSPWM (pomodoro, target, eww...)
    cp "$repo_dir/home/.zsh_functions" "$HOME/.zsh_functions" 2>> "$error_log"
    # En Ubuntu los paquetes de apt instalan los plugins en /usr/share/<plugin>/<plugin>.zsh
    sed -i --follow-symlinks 's|source $ZSH/plugins/$plugin/${plugin}.plugin.zsh|source /usr/share/$plugin/${plugin}.zsh|' "$HOME/.zshrc"
    printf "%s%sConfiguracion de zsh instalada%s\n" "${BLD}" "${CGR}" "${CNC}"
else
    printf "\n%s%sFallo la instalacion de la configuracion de zsh. Necesita instalación manual%s\n" "${BLD}" "${CRE}" "${CNC}"
fi
fc-cache -r >/dev/null 2>&1

printf "\n\n%s%sArchivos copiados correctamente!!%s\n" "${BLD}" "${CGR}" "${CNC}"
sleep 4

########## ---------- Installing Cargo & others ---------- ##########

printf "Instalando Fonts, Neovim, Cargo, Eww, Eza, autoenv & Greenclip\n"

# Installing Fonts
printf "%s%sInstalando fonts%s\n" "${BLD}" "${CBL}" "${CNC}"
mkdir -p "$HOME/.local/share/fonts"
if (
    fetch() { wget -q -O "$2" "$1" || exit 1; }
    mkdir -p "$HOME/.local/share/fonts" || exit 1
    cd "$HOME/.local/share/fonts" || exit 1

    fetch https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip JetBrainsMono.zip
    unzip -n -q JetBrainsMono.zip || exit 1
    rm -f JetBrainsMono.zip

    if [ ! -f MaterialDesignIconsDesktop.ttf ]; then
        git clone --depth 1 https://github.com/Templarian/MaterialDesign-Font || exit 1
        mv MaterialDesign-Font/MaterialDesignIconsDesktop.ttf ./MaterialDesignIconsDesktop.ttf || exit 1
        rm -rf MaterialDesign-Font
    fi

    fetch https://github.com/ryanoasis/nerd-fonts/raw/v3.0.2/patched-fonts/Iosevka/Regular/IosevkaNerdFont-Regular.ttf IosevkaNerdFont-Regular.ttf
    fetch https://raw.githubusercontent.com/google/fonts/main/ofl/bebasneue/BebasNeue-Regular.ttf BebasNeue-Regular.ttf

    fetch https://github.com/FortAwesome/Font-Awesome/releases/download/6.7.2/fontawesome-free-6.7.2-desktop.zip fontawesome.zip
    unzip -j -o -q fontawesome.zip "fontawesome-free-6.7.2-desktop/otfs/Font Awesome 6 Free-Solid-900.otf" || exit 1
    rm -f fontawesome.zip

    for style in Regular RegularItalic Medium SemiBold Bold ExtraBold; do
        fetch "https://raw.githubusercontent.com/vmware/clarity-city/master/TrueType/ClarityCity-$style.ttf" "ClarityCity-$style.ttf"
    done

    fc-cache -f >/dev/null
) 2>> "$error_log"; then
    printf "%s%sFonts instaladas%s\n" "${BLD}" "${CGR}" "${CNC}"
else
    printf "\n%s%sFallo la instalacion de Fonts. Necesita instalación manual%s\n" "${BLD}" "${CRE}" "${CNC}"
fi

# Installing Neovim (el de apt es viejo, se baja el release oficial)
if command -v nvim >/dev/null 2>&1; then
    printf "%s%sNeovim ya esta instalado%s\n" "${BLD}" "${CGR}" "${CNC}"
else
    printf "%s%sInstalando neovim%s\n" "${BLD}" "${CBL}" "${CNC}"
    case "$(uname -m)" in
        aarch64|arm64) nvim_pkg="nvim-linux-arm64" ;;
        *) nvim_pkg="nvim-linux-x86_64" ;;
    esac
    tmp_dir=$(mktemp -d)
    if curl -fsSL -o "$tmp_dir/$nvim_pkg.tar.gz" "https://github.com/neovim/neovim/releases/latest/download/$nvim_pkg.tar.gz" 2>> "$error_log" \
        && sudo rm -rf "/opt/$nvim_pkg" \
        && sudo tar -C /opt -xzf "$tmp_dir/$nvim_pkg.tar.gz" \
        && sudo ln -sf "/opt/$nvim_pkg/bin/nvim" /usr/local/bin/nvim; then
        printf "%s%sNeovim instalado%s\n" "${BLD}" "${CGR}" "${CNC}"
    else
        printf "\n%s%sFallo la instalacion de Neovim. Necesita instalación manual%s\n" "${BLD}" "${CRE}" "${CNC}"
    fi
    rm -rf "$tmp_dir"
fi

# Installing Cargo
if command -v cargo >/dev/null 2>&1 || [ -x "$HOME/.cargo/bin/cargo" ]; then
    printf "%s%sCargo ya esta instalado%s\n" "${BLD}" "${CGR}" "${CNC}"
else
    printf "%s%sInstalando Cargo%s\n" "${BLD}" "${CBL}" "${CNC}"
    if ! curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --default-toolchain stable -y 2>> "$error_log"; then
        printf "\n%s%sFallo la instalacion de Cargo. Necesita instalación manual%s\n" "${BLD}" "${CRE}" "${CNC}"
    fi
fi
# shellcheck source=/dev/null
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# Installing Eww
if command -v eww >/dev/null 2>&1; then
    printf "%s%sEww ya esta instalado%s\n" "${BLD}" "${CGR}" "${CNC}"
else
    printf "%s%sInstalando Eww%s\n" "${BLD}" "${CBL}" "${CNC}"
    if (
        set -e
        rm -rf "$HOME/eww"
        git clone https://github.com/elkowar/eww "$HOME/eww"
        cd "$HOME/eww"
        cargo build --release --no-default-features --features x11
        sudo install -Dm755 target/release/eww /usr/local/bin/eww
    ) 2>> "$error_log"; then
        rm -rf "$HOME/eww"
        printf "%s%sEww instalado%s\n" "${BLD}" "${CGR}" "${CNC}"
    else
        printf "\n%s%sFallo la instalacion de Eww. Necesita instalación manual%s\n" "${BLD}" "${CRE}" "${CNC}"
    fi
fi

# Installing Eza (si apt no lo tenia)
if command -v eza >/dev/null 2>&1; then
    printf "%s%sEza ya esta instalado%s\n" "${BLD}" "${CGR}" "${CNC}"
else
    printf "%s%sInstalando Eza%s\n" "${BLD}" "${CBL}" "${CNC}"
    if ! cargo install eza 2>> "$error_log"; then
        printf "\n%s%sFallo la instalacion de Eza. Necesita instalación manual%s\n" "${BLD}" "${CRE}" "${CNC}"
    fi
fi

# Installing Neovim config (repo Nvim-Config)
if [[ $try_nvim == "y" ]]; then
    printf "%s%sClonando configuracion de Neovim%s\n" "${BLD}" "${CBL}" "${CNC}"
    if git clone --depth 1 https://github.com/Jimmy4TK/Nvim-Config "$HOME/.config/nvim" 2>> "$error_log"; then
        printf "%s%sConfiguracion de Neovim instalada. Los plugins se instalan solos al abrir nvim%s\n" "${BLD}" "${CGR}" "${CNC}"
    else
        printf "\n%s%sFallo la instalacion de la configuracion de Neovim. Necesita instalación manual%s\n" "${BLD}" "${CRE}" "${CNC}"
    fi
fi

# Installing tmux config (repo Tmux-Config) + TPM
if [[ $try_tmux == "y" ]]; then
    printf "%s%sClonando configuracion de tmux%s\n" "${BLD}" "${CBL}" "${CNC}"
    if git clone --depth 1 https://github.com/Jimmy4TK/Tmux-Config "$HOME/.config/tmux" 2>> "$error_log" \
        && git clone --depth 1 https://github.com/tmux-plugins/tpm "$HOME/.config/tmux/plugins/tpm" 2>> "$error_log"; then
        "$HOME/.config/tmux/plugins/tpm/bin/install_plugins" >/dev/null 2>> "$error_log"
        printf "%s%sConfiguracion de tmux instalada%s\n" "${BLD}" "${CGR}" "${CNC}"
    else
        printf "\n%s%sFallo la instalacion de la configuracion de tmux. Necesita instalación manual%s\n" "${BLD}" "${CRE}" "${CNC}"
    fi
fi

# Installing Yazi (no esta en apt; se baja el release oficial)
if command -v yazi >/dev/null 2>&1; then
    printf "%s%sYazi ya esta instalado%s\n" "${BLD}" "${CGR}" "${CNC}"
else
    printf "%s%sInstalando Yazi%s\n" "${BLD}" "${CBL}" "${CNC}"
    yazi_pkg="yazi-$(uname -m)-unknown-linux-musl"
    tmp_dir=$(mktemp -d)
    if curl -fsSL -o "$tmp_dir/yazi.zip" "https://github.com/sxyazi/yazi/releases/latest/download/$yazi_pkg.zip" 2>> "$error_log" \
        && unzip -q "$tmp_dir/yazi.zip" -d "$tmp_dir" \
        && sudo install -Dm755 "$tmp_dir/$yazi_pkg/yazi" /usr/local/bin/yazi \
        && sudo install -Dm755 "$tmp_dir/$yazi_pkg/ya" /usr/local/bin/ya; then
        printf "%s%sYazi instalado%s\n" "${BLD}" "${CGR}" "${CNC}"
    else
        printf "\n%s%sFallo la instalacion de Yazi. Necesita instalación manual%s\n" "${BLD}" "${CRE}" "${CNC}"
    fi
    rm -rf "$tmp_dir"
fi

# Installing autoenv
if [ -d "$HOME/.autoenv" ]; then
    printf "%s%sautoenv ya esta instalado%s\n" "${BLD}" "${CGR}" "${CNC}"
else
    printf "%s%sInstalando autoenv%s\n" "${BLD}" "${CBL}" "${CNC}"
    if ! git clone --depth 1 'https://github.com/hyperupcall/autoenv' "$HOME/.autoenv" 2>> "$error_log"; then
        printf "\n%s%sFallo la instalacion de autoenv. Necesita instalación manual%s\n" "${BLD}" "${CRE}" "${CNC}"
    fi
fi

# Installing Greenclip
if command -v greenclip >/dev/null 2>&1; then
    printf "%s%sGreenclip ya esta instalado%s\n" "${BLD}" "${CGR}" "${CNC}"
else
    printf "%s%sInstalando Greenclip%s\n" "${BLD}" "${CBL}" "${CNC}"
    tmp_dir=$(mktemp -d)
    if wget -q -O "$tmp_dir/greenclip" https://github.com/erebe/greenclip/releases/download/v4.2/greenclip 2>> "$error_log" \
        && sudo install -Dm755 "$tmp_dir/greenclip" /usr/local/bin/greenclip; then
        printf "%s%sGreenclip instalado%s\n" "${BLD}" "${CGR}" "${CNC}"
    else
        printf "\n%s%sFallo la instalacion de Greenclip. Necesita instalación manual%s\n" "${BLD}" "${CRE}" "${CNC}"
    fi
    rm -rf "$tmp_dir"
fi

########## ---------- Enabling services ---------- ##########

sudo systemctl enable --now NetworkManager.service 2>> "$error_log"
sudo systemctl enable --now bluetooth.service 2>> "$error_log"

########## --------- Changing shell to zsh ---------- ##########

printf "Cambiando la shell default por zsh\n"

zsh_path=$(command -v zsh)
if [[ $SHELL != "$zsh_path" ]]; then
    printf "\n%s%sCambiando la shell por zsh. Tu contraseña root es requerida.%s\n\n" "${BLD}" "${CYE}" "${CNC}"
    # Cambia la shell a zsh
    if chsh -s "$zsh_path"; then
        printf "%s%sShell cambiada a zsh. Porfavor rebootea.%s\n\n" "${BLD}" "${CGR}" "${CNC}"
    else
        printf "%s%sNo se pudo cambiar la shell. Ejecuta 'chsh -s %s' a mano.%s\n\n" "${BLD}" "${CRE}" "$zsh_path" "${CNC}"
    fi
else
    printf "%s%sTu shell ya es zsh\nNos re vimos! instalación completada, ahora rebootea.%s\n" "${BLD}" "${CGR}" "${CNC}"
fi
