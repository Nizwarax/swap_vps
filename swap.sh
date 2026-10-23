#!/bin/bash

# ┌──────────────────────────────────────────────┐
# │  ULTIMATE SWAP MANAGER - CLEAN ULTRA EDITION │
# │  Features: ZRAM zstd + Swap File Hybrid      │
# │  Design by: Deki Niswara                     │
# └──────────────────────────────────────────────┘

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root!"
   exit 1
fi

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHT='\033[0;37m'
NC='\033[0m'

SWAP_FILE="/swapfile"

show_success_art() {
    local message="$1"
    clear
    echo -e "${GREEN}⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣀⣀⣴⠷⣶⣄⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
    echo -e "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣼⣿⣷⣾⠟⠛⠋⠁⠀⠈⠉⠛⣿⣦⡀⠀⠀⠀⠀⠀⠀⠀"
    echo -e "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⠈⠉⣡⡴⠶⣤⠶⠷⣦⠀⣀⣈⠻⣿⡀⠀⠀⠀⠀⠀⠀"
    echo -e "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣳⣾⣯⠀⠀⠀⠀⣤⡈⠉⠉⢹⡇⢹⣷⠀⠀⠀⠀⠀⠀"
    echo -e "⠀⠀⠀⠀⠀⣀⣀⠀⠀⠀⠀⠀⠀⠀⠀⢘⣿⠋⣤⡄⠀⣤⠀⢀⡈⠓⠀⣼⣿⣄⢸⣿⠀⠀⠀⠀⠀⠀"
    echo -e "⠀⠀⠀⣴⡿⠛⠛⣿⡧⠀⠀⠀⠀⠀⠀⣼⡟⠀⠛⢡⡾⠋⠀⠸⠇⠀⠀⣾⣿⣿⣾⠟⠀⠀⠀⠀⠀⠀"
    echo -e "⠀⠀⢸⣿⠀⠀⢰⣿⠇⠀⠀⠀⠀⠀⠀⣿⡇⢀⡀⠘⠗⠀⠀⣤⡀⠀⠀⠈⠛⢿⣿⠀⠀⠀⠀⠀⠀⠀"
    echo -e "⢀⣠⣨⣿⣆⠀⠹⣿⡄⠀⠀⠀⠀⠀⠀⢸⣿⠹⠯⣿⣒⣚⣭⠿⡟⠀⠀⢀⣠⣾⡿⠀⠀⠀⠀⠀⠀⠀"
    echo -e "⣿⠛⠉⠉⠛⠳⢦⡈⢿⣦⣀⠀⠀⠀⠀⠀⢻⣷⡀⠘⠛⠃⠀⠀⠀⢀⣴⣿⣟⠁⠀⠀⠀⠀⠀⠀⠀⠀"
    echo -e "⣿⠶⠶⠶⠦⣤⣨⡇⠀⣿⡿⢷⣶⣶⣦⣴⣾⣿⡟⠶⣤⣀⣀⡀⢘⣿⠏⢹⡟⠿⣷⣦⣀⠀⠀⠀⠀⠀"
    echo -e "⣿⣤⣤⣤⣀⣀⢙⡆⣰⢏⡇⠀⠀⠈⠉⠉⠀⠀⠳⣄⡈⠛⠛⠛⠋⠁⣀⣼⠃⠀⠀⠙⠻⣿⣦⡀⠀⠀"
    echo -e "⣿⡅⢰⣄⠈⠉⣻⢁⡽⣸⠃⠀⠀⠀⠀⠀⠀⠀⠀⠈⠙⠛⣦⠀⠀⢹⡋⠁⠀⠀⠀⠀⠀⠈⠻⣿⣆⠀"
    echo -e "⠘⠻⣶⣭⣿⣿⣿⣟⣱⠟⠀⠀⠀⠀⢀⣠⣾⠇⠀⠀⠀⠀⢹⠀⠀⠈⡇⠀⠀⢿⠀⠀⠀⠀⠀⠈⢻⡇"
    echo -e "⠀⠀⠀⠉⠉⠉⠛⠛⠿⣷⡖⠒⣶⡿⠛⣿⠀⠀⠀⠀⠀⠀⠸⡇⠀⠀⢹⠀⠀⢸⡆⣴⡖⠀⠀⠀⠀⣿"
    echo -e "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣿⡆⠀⠀⠀⠀⠀⠀⡇⠀⠀⢸⡆⠀⠈⣿⠏⠀⠀⠀⠀⣰⠇"
    echo -e "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣿⣧⡀⠀⠀⠀⠀⠀⡇⠀⠀⠀⡇⣀⣴⢿⣀⡀⠀⠀⣰⡏⠀"
    echo -e "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣿⡏⠙⠳⠶⠦⣤⣤⡇⠀⠀⠀⠛⠉⠀⢸⠉⠙⢷⣾⡟⠁⠀"
    echo -e "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⣾⡆⣀⣼⡿⠀⠀⠀"
    echo -e "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣿⠙⠷⢦⣤⣄⣀⣀⣠⣤⣤⡶⠾⠛⠉⢸⣇⣹⣿⠇⠀⠀⠀"
    echo -e "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣾⡟⠀⠀⠀⠀⠈⠉⠉⠉⣄⠀⠀⠀⠀⠀⠀⣿⣿⠁⠀⠀⠀⠀"
    echo -e "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⡇⠀⠀⠀⠀⠀⠀⠀⣾⠃⠀⠀⠀⠀⠀⠀⣿⡿⠀⠀⠀⠀⠀"
    echo -e "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⣿⠀⠀⠀⠀⠀⠀⠀⣼⡇⠀⠀⠀⠀⠀⠀⢠⣿⡇⠀⠀⠀⠀⠀"
    echo -e "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣾⡏⠀⠀⠀⠀⠀⠀⣸⣿⣇⠀⠀⠀⠀⠀⠀⢸⣿⠀⠀⠀⠀⠀⠀"
    echo -e "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⣿⠁⠀⠀⠀⠀⠀⢠⣿⣿⣿⠀⠀⠀⠀⠀⠀⣾⡿⠀⠀⠀⠀⠀⠀"
    echo -e "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣿⡇⠀⠀⠀⠀⠀⠀⣾⡿⢸⡟⠀⠀⠀⠀⠀⢰⣿⡇⠀⠀⠀⠀⠀⠀"
    echo -e "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⠀⠀⠀⠀⠀⠀⣸⣿⠃⢸⡇⠀⠀⠀⠀⠀⣼⣿⠀⠀⠀⠀⠀⠀⠀"
    echo -e "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣀⠀⠀⠀⢀⣴⣿⠃⠀⢸⣷⣦⣤⣤⣤⣴⣿⣷⣤⡀⠀⠀⠀⠀⠀"
    echo -e "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⠏⠁⠀⠀⠈⠻⡿⣿⣿⣿⣿⣿⣿⣿⣿⡆⠀⠀⠀⠀"
    echo -e "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠻⢿⡿⣿⣿⠟⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠉⠉⠉⠉⠉⠀⠀⠀⠀⠀${NC}"
    echo -e ""
    echo -e "${PURPLE} ██╗███╗░░██╗░██████╗████████╗░█████╗░██╗░░░░░██╗░░░░░"
    echo -e " ██║████╗░██║██╔════╝╚══██╔══╝██╔══██╗██║░░░░░██║░░░░░"
    echo -e " ██║██╔██╗██║╚█████╗░░░░██║░░░███████║██║░░░░░██║░░░░░"
    echo -e " ██║██║╚████║░╚═══██╗░░░██║░░░██╔══██║██║░░░░░██║░░░░░"
    echo -e " ██║██║░╚███║██████╔╝░░░██║░░░██║░░██║███████╗███████╗"
    echo -e " ╚═╝╚═╝░░╚══╝╚═════╝░░░░╚═╝░░░╚═╝░░╚═╝╚══════╝╚══════╝${NC}"
    echo -e ""
    echo -e "${YELLOW} ░██████╗██╗░░░██║░█████╗░░█████╗░███████╗███████╗██████╗░"
    echo -e " ██╔════╝██║░░░██║██╔══██╗██╔══██╗██╔════╝██╔════╝██╔══██╗"
    echo -e " ╚█████╗░██║░░░██║██║░░╚═╝██║░░╚═╝█████╗░░█████╗░░██║░░██║"
    echo -e " ░╚═══██╗██║░░░██║██║░░██╗██║░░██╗██╔══╝░░██╔══╝░░██║░░██║"
    echo -e " ██████╔╝╚██████╔╝╚█████╔╝╚█████╔╝███████╗███████╗██████╔╝"
    echo -e " ╚═════╝░░╚═════╝░░╚════╝░░╚════╝░╚══════╝╚══════╝╚═════╝░${NC}"
    echo -e ""
    echo -e "${GREEN}[ $message ]${NC}\n"
}

get_os_info() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$PRETTY_NAME"
    else
        echo "Unknown"
    fi
}

display_menu() {
    OPSY=$(get_os_info)
    RAM_TOTAL=$(free -h | grep Mem | awk '{print $2}')
    SWAP_INFO=$(free -h | grep Swap | awk '{print $2 " / " $3}')

    clear
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${LIGHT}       ULTIMATE SWAP MANAGER - CLEAN ULTRA${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e " OS   : $OPSY"
    echo -e " RAM  : $RAM_TOTAL"
    echo -e " Swap : $SWAP_INFO"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e " ${YELLOW}[1]${NC} Create Swap File (Standard)"
    echo -e " ${YELLOW}[2]${NC} Enable ZRAM (Compressed RAM)"
    echo -e " ${YELLOW}[3]${NC} Enable ULTRA HYBRID ${GREEN}(Recommended)${NC}"
    echo -e " ${YELLOW}[4]${NC} Remove All Swap"
    echo -e " ${YELLOW}[5]${NC} Exit"
    echo ""
    echo -e -n "${CYAN} Select [1-5]: ${NC}"
}

print_info() { echo -e "${BLUE}➽ $1${NC}"; }
print_error() { echo -e "${RED}✘ $1${NC}"; }

optimize_kernel() {
    MODE=$1
    CONF="/etc/sysctl.d/99-ultra-swap.conf"
    sed -i '/vm.swappiness/d' /etc/sysctl.conf 2>/dev/null
    sed -i '/vm.vfs_cache_pressure/d' /etc/sysctl.conf 2>/dev/null

    mkdir -p /etc/sysctl.d
    if [[ "$MODE" == "zram" ]]; then
        cat > $CONF <<EOF
vm.swappiness=100
vm.vfs_cache_pressure=50
vm.page-cluster=0
EOF
    else
        cat > $CONF <<EOF
vm.swappiness=10
vm.vfs_cache_pressure=50
vm.dirty_ratio=15
vm.dirty_background_ratio=5
vm.overcommit_memory=1
vm.page-cluster=0
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
EOF
    fi
    sysctl --system >/dev/null 2>&1
}

install_swapfile() {
    echo -e -n "${YELLOW}Enter swap size in GB (e.g. 4): ${NC}"
    read SIZE
    [[ ! "$SIZE" =~ ^[0-9]+$ ]] && { print_error "Invalid number!"; return; }

    print_info "Creating ${SIZE}GB swap file..."
    swapoff $SWAP_FILE 2>/dev/null
    rm -f $SWAP_FILE
    sed -i "\#$SWAP_FILE#d" /etc/fstab

    fallocate -l "${SIZE}G" $SWAP_FILE 2>/dev/null || dd if=/dev/zero of=$SWAP_FILE bs=1M count=$((SIZE*1024)) status=progress
    chmod 600 $SWAP_FILE
    mkswap $SWAP_FILE
    swapon $SWAP_FILE
    echo "$SWAP_FILE none swap sw 0 0" >> /etc/fstab

    optimize_kernel "hdd"
    show_success_art "SWAP FILE ${SIZE}GB CREATED"
}

install_zram() {
    print_info "Enabling ZRAM..."
    RAM_MB=$(free -m | awk '/^Mem:/{print $2}')
    ZRAM_MB=$((RAM_MB * 60 / 100))

    modprobe zram num_devices=1 2>/dev/null || true
    if [ -f /sys/block/zram0/comp_algorithm ]; then
        grep -q zstd /sys/block/zram0/comp_algorithm 2>/dev/null && ALGO="zstd" || ALGO="lz4"
        echo $ALGO > /sys/block/zram0/comp_algorithm 2>/dev/null || true
    fi

    if [ -f /etc/debian_version ]; then
        apt update -qq && apt install zram-tools -y -qq 2>/dev/null
        echo -e "ALGO=zstd\nPERCENT=60" > /etc/default/zramswap
        systemctl restart zramswap 2>/dev/null || service zramswap restart 2>/dev/null || true
    fi

    if ! swapon --show | grep -q zram; then
        echo "${ZRAM_MB}M" > /sys/block/zram0/disksize 2>/dev/null || echo $((ZRAM_MB*1024*1024)) > /sys/block/zram0/disksize
        mkswap /dev/zram0
        swapon -p 100 /dev/zram0
    fi

    optimize_kernel "zram"
    show_success_art "ZRAM ENABLED - 60% RAM"
}

install_hybrid_ultra() {
    print_info "Enabling ULTRA HYBRID..."
    RAM_GB=$(free -g | awk '/^Mem:/{print $2}')
    [ "$RAM_GB" -eq 0 ] && RAM_GB=7
    DISK="4G"

    swapoff -a 2>/dev/null || true
    rm -f $SWAP_FILE
    sed -i "\#$SWAP_FILE#d" /etc/fstab
    systemctl stop zramswap 2>/dev/null || true
    systemctl disable zram-setup.service 2>/dev/null || true
    rm -f /etc/systemd/system/zram-setup.service
    modprobe -r zram 2>/dev/null; sleep 1
    modprobe zram num_devices=1

    COMP="zstd"
    [ -f /sys/block/zram0/comp_algorithm ] && { grep -q zstd /sys/block/zram0/comp_algorithm && COMP="zstd" || COMP="lz4"; echo $COMP > /sys/block/zram0/comp_algorithm 2>/dev/null || true; }

    echo "${RAM_GB}G" > /sys/block/zram0/disksize 2>/dev/null || echo $((RAM_GB*1024*1024*1024)) > /sys/block/zram0/disksize
    mkswap /dev/zram0
    swapon -p 100 /dev/zram0

    fallocate -l $DISK $SWAP_FILE 2>/dev/null || dd if=/dev/zero of=$SWAP_FILE bs=1M count=4096 status=progress
    chmod 600 $SWAP_FILE
    mkswap $SWAP_FILE
    swapon -p 10 $SWAP_FILE
    grep -q "$SWAP_FILE" /etc/fstab || echo "$SWAP_FILE none swap sw,pri=10 0 0" >> /etc/fstab

    optimize_kernel "hybrid"

    cat > /etc/systemd/system/zram-setup.service <<SERV
[Unit]
Description=ZRAM Ultra Hybrid
After=multi-user.target
[Service]
Type=oneshot
ExecStart=/bin/bash -c 'modprobe zram num_devices=1 && echo $COMP > /sys/block/zram0/comp_algorithm 2>/dev/null; echo ${RAM_GB}G > /sys/block/zram0/disksize 2>/dev/null; mkswap /dev/zram0 && swapon -p 100 /dev/zram0 && swapon -p 10 $SWAP_FILE || true'
ExecStop=/bin/bash -c 'swapoff /dev/zram0; swapoff $SWAP_FILE; echo 1 > /sys/block/zram0/reset || true'
RemainAfterExit=yes
[Install]
WantedBy=multi-user.target
SERV
    systemctl daemon-reload
    systemctl enable zram-setup.service >/dev/null 2>&1

    show_success_art "ULTRA HYBRID ENABLED - ZRAM ${RAM_GB}G + DISK ${DISK}"
}

remove_swap() {
    print_info "Removing all swap..."
    swapoff -a 2>/dev/null || true
    rm -f $SWAP_FILE
    sed -i "\#$SWAP_FILE#d" /etc/fstab
    sed -i "/swap/d" /etc/fstab
    systemctl stop zram-setup.service 2>/dev/null || true
    systemctl disable zram-setup.service 2>/dev/null || true
    rm -f /etc/systemd/system/zram-setup.service
    systemctl daemon-reload
    modprobe -r zram 2>/dev/null || true
    echo 1 > /sys/block/zram0/reset 2>/dev/null || true
    [ -f /etc/debian_version ] && apt remove zram-tools -y -qq 2>/dev/null || true
    rm -f /etc/default/zramswap
    rm -f /etc/sysctl.d/99-ultra-swap.conf
    show_success_art "ALL SWAP REMOVED"
}

while true; do
    display_menu
    read choice
    case $choice in
        1) install_swapfile; read -p "Press Enter..." ;;
        2) install_zram; read -p "Press Enter..." ;;
        3) install_hybrid_ultra; read -p "Press Enter..." ;;
        4) remove_swap; read -p "Press Enter..." ;;
        5) clear; echo -e "${GREEN}Done. - Deki Niswara${NC}"; exit 0 ;;
        *) print_error "Invalid option!"; sleep 1 ;;
    esac
done
