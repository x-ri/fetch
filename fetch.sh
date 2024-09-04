#!/bin/bash

# Function to get OS information
get_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo -e "🤖 OS: $NAME $VERSION"
    else
        echo -e "🤖 OS: Unknown"
    fi
}

# Function to get Kernel information in short format
get_kernel() {
    kernel_version=$(uname -r | cut -d '-' -f 1)
    echo -e "📟 Kernel: $kernel_version"
}

# Function to get Uptime information in short format
get_uptime() {
    uptime_info=$(uptime -p | awk '{print $2, $3}' | sed 's/,//g')
    hours=$(echo $uptime_info | grep -oP '\d+(?= hour)')
    minutes=$(echo $uptime_info | grep -oP '\d+(?= minute)')
    
    if [ -z "$hours" ]; then
        hours="0h"
    else
        hours="${hours}h"
    fi
    
    if [ -z "$minutes" ]; then
        minutes="0m"
    else
        minutes="${minutes}m"
    fi
    
    echo -e "⌚ Uptime: $hours $minutes"
}

# Function to get number of installed packages
get_packages() {
    if command -v pacman &> /dev/null; then
        echo -e "🎁 Packages: $(pacman -Q | wc -l)"
    elif command -v dpkg &> /dev/null; then
        echo -e "🎁 Packages: $(dpkg --list | wc -l)"
    elif command -v rpm &> /dev/null; then
        echo -e "🎁 Packages: $(rpm -qa | wc -l)"
    elif command -v apk &> /dev/null; then
        echo -e "🎁 Packages: $(apk info | wc -l)"
    elif command -v emerge &> /dev/null; then
        echo -e "🎁 Packages: $(qlist -I | wc -l)"
    elif command -v apt &> /dev/null; then
        echo -e "🎁 Packages: $(apt list --installed 2>/dev/null | wc -l)"
    elif command -v dnf &> /dev/null; then
        echo -e "🎁 Packages: $(dnf list installed | wc -l)"
    elif command -v equo &> /dev/null; then
        echo -e "🎁 Packages: $(equo query list installed | wc -l)"
    elif command -v flatpak &> /dev/null; then
        echo -e "🎁 Packages: $(flatpak list | wc -l)"
    else
        echo -e "🎁 Packages: Unknown"
    fi
}

# Function to get Window Manager information
  # A check for WAYLAND_DISPLAY to identify Wayland sessions.
  # A check for DISPLAY to identify X11 sessions.
  # The use of wmctrl to get the window manager name in X11 sessions.

get_wm() {
    if [ "$XDG_CURRENT_DESKTOP" ]; then
        echo -e "🪟 WM: $XDG_CURRENT_DESKTOP"
    elif [ "$DESKTOP_SESSION" ]; then
        echo -e "🪟 WM: $DESKTOP_SESSION"
    elif [ "$GDMSESSION" ]; then
        echo -e "🪟 WM: $GDMSESSION"
    elif [ "$WAYLAND_DISPLAY" ]; then
        echo -e "🪟 WM: Wayland"
    elif [ "$DISPLAY" ]; then
        if command -v wmctrl &> /dev/null; then
            wm=$(wmctrl -m | grep Name | cut -d: -f2)
            echo -e "🪟 WM: $wm (X11)"
        else
            echo -e "🪟 WM: X11"
        fi
    else
        echo -e "🪟 WM: Unknown"
    fi
}


# Function to display ASCII art
display_ascii_art() {
    cat << "EOF"
   ✰   ^
  *  /   \  .
  ＊/- ― -\  ⋆
 . ﾉｲ从バ从\.
＋ﾉﾘ *ﾟヮﾟﾙハ＊
EOF
}

# Main function to display ascii and fetch information
main() {
    ascii_art=$(display_ascii_art)
    info=$(echo -e "$(get_os)\n$(get_kernel)\n$(get_uptime)\n$(get_packages)\n$(get_wm)")

    # Combine ASCII art and info side by side
    paste <(echo "$ascii_art") <(echo "$info")
}

# Run the main function
main
