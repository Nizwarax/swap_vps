#!/bin/bash

# ┌──────────────────────────────────────────────────────────┐
# │  UNIVERSAL CLEAN FINAL - ALL VPS COMPATIBLE             │
# │  Logic: Universal (KVM/OpenVZ/LXC/NAT/Potato)           │
# │  Menu : Clean Edition (5 items)                         │
# │  Design by: Deki Niswara                               │
# └──────────────────────────────────────────────────────────┘

if [[ $EUID -ne 0 ]]; then echo "Run as root!"; exit 1; fi

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[0;33m'
BLUE='\033[0;34m'; PURPLE='\033[0;35m'; CYAN='\033[0;36m'
LIGHT='\033[0;37m'; NC='\033[0m'
SWAP_FILE="/swapfile"

detect_virt() {
    if [ -f /proc/user_beancounters ]; then echo "openvz"; return; fi
    if [ -f /proc/vz/veinfo ]; then echo "openvz"; return; fi
    if command -v systemd-detect-virt >/dev/null 2>&1; then
        V=$(systemd-detect-virt 2>/dev/null); [ -n "$V" ] && echo "$V" && return
    fi
    grep -q "lxc" /proc/1/cgroup 2>/dev/null && echo "lxc" && return
    echo "kvm"
}

check_swap_support() {
    local f="/tmp/.swaptest_$$"
    fallocate -l 64M $f 2>/dev/null || dd if=/dev/zero of=$f bs=1M count=64 >/dev/null 2>&1
    chmod 600 $f 2>/dev/null; mkswap $f >/dev/null 2>&1
    if swapon $f >/dev/null 2>&1; then swapoff $f >/dev/null 2>&1; rm -f $f; return 0
    else rm -f $f; return 1; fi
}

check_zram_support() {
    modprobe zram num_devices=1 >/dev/null 2>&1
    [ -d /sys/block/zram0 ] && return 0 || return 1
}

get_ram_mb() { free -m | awk '/^Mem:/{print $2}'; }
get_ram_gb() { local g=$(free -g | awk '/^Mem:/{print $2}'); [ "$g" -eq 0 ] && echo 1 || echo $g; }

show_success_art() {
    local msg="$1"
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
    echo -e "${PURPLE} ██╗███╗░░██╗░██████╗████████╗░█████╗░██╗░░░░░██╗░░░░░"
    echo -e " ██║████╗░██║██╔════╝╚══██╔══╝██╔══██╗██║░░░░░██║░░░░░"
    echo -e " ██║██╔██╗██║╚█████╗░░░░██║░░░███████║██║░░░░░██║░░░░░"
    echo -e " ██║██║╚████║░╚═══██╗░░░██║░░░██╔══██║██║░░░░░██║░░░░░"
    echo -e " ██║██║░╚███║██████╔╝░░░██║░░░██║░░██║███████╗███████╗"
    echo -e " ╚═╝╚═╝░░╚══╝╚═════╝░░░░╚═╝░░░╚═╝░░╚═╝╚══════╝╚══════╝${NC}"
    echo -e "${YELLOW} ░██████╗██╗░░░██║░█████╗░░█████╗░███████╗███████╗██████╗░"
    echo -e " ██╔════╝██║░░░██║██╔══██╗██╔══██╗██╔════╝██╔════╝██╔══██╗"
    echo -e " ╚█████╗░██║░░░██║██║░░╚═╝██║░░╚═╝█████╗░░█████╗░░██║░░██║"
    echo -e " ░╚═══██╗██║░░░██║██║░░██╗██║░░██╗██╔══╝░░██╔══╝░░██║░░██║"
    echo -e " ██████╔╝╚██████╔╝╚█████╔╝╚█████╔╝███████╗███████╗██████╔╝"
    echo -e " ╚═════╝░░╚═════╝░░╚════╝░░╚════╝░╚══════╝╚══════╝╚═════╝░${NC}"
    echo -e "${GREEN}[ $msg ]${NC}\n"; free -h; echo ""; swapon --show 2>/dev/null || true
}

display_menu() {
    VIRT=$(detect_virt); RAM=$(free -h | awk '/^Mem:/{print $2}'); SWAP=$(free -h | awk '/^Swap:/{print $2 " / " $3}')
    clear
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${LIGHT}     UNIVERSAL CLEAN FINAL - ALL VPS READY${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e " Virt : $VIRT | RAM : $RAM | Swap : $SWAP"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
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
    local mode=$1; local ram=$(get_ram_mb); mkdir -p /etc/sysctl.d
    local conf="/etc/sysctl.d/99-universal-swap.conf"
    cat > $conf <<EOF
vm.vfs_cache_pressure=50
vm.dirty_ratio=15
vm.dirty_background_ratio=5
vm.page-cluster=0
vm.overcommit_memory=1
EOF
    if [ "$ram" -lt 1024 ]; then
        echo "vm.swappiness=5" >> $conf
        echo "vm.oom_kill_allocating_task=1" >> $conf
    else
        [[ "$mode" == "zram" ]] && echo "vm.swappiness=100" >> $conf || echo "vm.swappiness=10" >> $conf
    fi
    modprobe tcp_bbr >/dev/null 2>&1 && { echo "net.core.default_qdisc=fq" >> $conf; echo "net.ipv4.tcp_congestion_control=bbr" >> $conf; }
    sysctl --system >/dev/null 2>&1 || sysctl -p $conf >/dev/null 2>&1
}

install_swapfile() {
    local size_gb=$1
    if [ -z "$size_gb" ]; then echo -e -n "${YELLOW}Enter swap size in GB (e.g. 2): ${NC}"; read size_gb; fi
    [[ ! "$size_gb" =~ ^[0-9]+$ ]] && { print_error "Invalid number"; return 1; }
    local free_mb=$(df -m / | awk 'NR==2{print $4}'); [ "$free_mb" -lt $((size_gb*1024+512)) ] && { print_error "Disk full! Free ${free_mb}MB"; return 1; }

    print_info "Creating ${size_gb}GB swap file..."
    swapoff $SWAP_FILE 2>/dev/null; rm -f $SWAP_FILE; sed -i "\#$SWAP_FILE#d" /etc/fstab
    fallocate -l "${size_gb}G" $SWAP_FILE 2>/dev/null || dd if=/dev/zero of=$SWAP_FILE bs=1M count=$((size_gb*1024)) status=progress
    chmod 600 $SWAP_FILE; mkswap $SWAP_FILE
    if ! swapon $SWAP_FILE 2>/dev/null; then
        print_error "Swap blocked on this VPS (OpenVZ/LXC). Trying ZRAM fallback..."
        rm -f $SWAP_FILE
        if check_zram_support; then install_zram; else install_potato_fallback; fi
        return
    fi
    echo "$SWAP_FILE none swap sw 0 0" >> /etc/fstab
    optimize_kernel "hdd"
    show_success_art "SWAP FILE ${size_gb}GB CREATED"
}

install_zram() {
    print_info "Enabling ZRAM..."
    if ! check_zram_support; then print_error "ZRAM not supported on this kernel"; install_potato_fallback; return; fi
    local ram_mb=$(get_ram_mb); local zram_mb
    if [ "$ram_mb" -lt 1024 ]; then zram_mb=$ram_mb; else zram_mb=$((ram_mb*60/100)); fi
    local algo="zstd"; grep -q zstd /sys/block/zram0/comp_algorithm 2>/dev/null && algo="zstd" || algo="lz4"
    [ "$ram_mb" -lt 1024 ] && algo="lz4"
    echo $algo > /sys/block/zram0/comp_algorithm 2>/dev/null || true
    echo "${zram_mb}M" > /sys/block/zram0/disksize 2>/dev/null || echo $((zram_mb*1024*1024)) > /sys/block/zram0/disksize
    mkswap /dev/zram0; swapon -p 100 /dev/zram0

    if command -v systemctl >/dev/null 2>&1; then
        cat > /etc/systemd/system/zram-setup.service <<SERV
[Unit]
Description=ZRAM Universal Clean
After=multi-user.target
[Service]
Type=oneshot
ExecStart=/bin/bash -c 'modprobe zram num_devices=1 && echo $algo > /sys/block/zram0/comp_algorithm 2>/dev/null; echo ${zram_mb}M > /sys/block/zram0/disksize; mkswap /dev/zram0 && swapon -p 100 /dev/zram0'
ExecStop=/bin/bash -c 'swapoff /dev/zram0; echo 1 > /sys/block/zram0/reset || true'
RemainAfterExit=yes
[Install]
WantedBy=multi-user.target
SERV
        systemctl daemon-reload; systemctl enable zram-setup.service >/dev/null 2>&1
    fi
    optimize_kernel "zram"
    show_success_art "ZRAM ${zram_mb}MB (${algo}) ENABLED"
}

install_hybrid() {
    print_info "Enabling ULTRA HYBRID (Recommended)..."
    local virt=$(detect_virt); local ram_mb=$(get_ram_mb); local ram_gb=$(get_ram_gb)
    local swap_ok=0; check_swap_support && swap_ok=1
    local zram_ok=0; check_zram_support && zram_ok=1

    # Tentukan ukuran dinamis - bukan hardcode
    local zram_mb; local disk_gb
    if [ "$ram_mb" -lt 1024 ]; then
        zram_mb=$ram_mb; disk_gb=1
    elif [ "$ram_mb" -lt 4096 ]; then
        zram_mb=$((ram_mb*60/100)); disk_gb=2
    else
        zram_mb=$((ram_mb*80/100)); disk_gb=4
    fi

    # Fallback untuk VPS kentang
    if [ $swap_ok -eq 0 ] && [ $zram_ok -eq 0 ]; then
        print_info "Both swap and zram blocked ($virt) -> Using Potato Optimizer..."
        install_potato_fallback; return
    fi
    if [ $swap_ok -eq 0 ]; then install_zram; return; fi
    if [ $zram_ok -eq 0 ]; then install_swapfile $disk_gb; return; fi

    # KVM / Full support - Hybrid beneran
    print_info "Virt: $virt | RAM: ${ram_mb}MB -> ZRAM ${zram_mb}MB + Disk ${disk_gb}GB"
    swapoff -a 2>/dev/null || true; rm -f $SWAP_FILE; sed -i "\#$SWAP_FILE#d" /etc/fstab
    systemctl stop zram-setup.service 2>/dev/null || true; modprobe -r zram 2>/dev/null; modprobe zram num_devices=1

    local algo="zstd"; grep -q zstd /sys/block/zram0/comp_algorithm 2>/dev/null && algo="zstd" || algo="lz4"
    [ "$ram_mb" -lt 1024 ] && algo="lz4"
    echo $algo > /sys/block/zram0/comp_algorithm 2>/dev/null || true
    echo "${zram_mb}M" > /sys/block/zram0/disksize; mkswap /dev/zram0; swapon -p 100 /dev/zram0

    fallocate -l "${disk_gb}G" $SWAP_FILE 2>/dev/null || dd if=/dev/zero of=$SWAP_FILE bs=1M count=$((disk_gb*1024)) status=progress
    chmod 600 $SWAP_FILE; mkswap $SWAP_FILE; swapon -p 10 $SWAP_FILE
    echo "$SWAP_FILE none swap sw,pri=10 0 0" >> /etc/fstab

    cat > /etc/systemd/system/zram-setup.service <<SERV
[Unit]
Description=ZRAM Hybrid Clean Final
After=multi-user.target
[Service]
Type=oneshot
ExecStart=/bin/bash -c 'modprobe zram num_devices=1 && echo $algo > /sys/block/zram0/comp_algorithm 2>/dev/null; echo ${zram_mb}M > /sys/block/zram0/disksize; mkswap /dev/zram0 && swapon -p 100 /dev/zram0 && swapon -p 10 $SWAP_FILE || true'
RemainAfterExit=yes
[Install]
WantedBy=multi-user.target
SERV
    systemctl daemon-reload 2>/dev/null; systemctl enable zram-setup.service >/dev/null 2>&1

    optimize_kernel "hybrid"
    show_success_art "ULTRA HYBRID ENABLED - ZRAM ${zram_mb}MB + DISK ${disk_gb}GB"
}

install_potato_fallback() {
    print_info "Potato Mode - Low RAM / OpenVZ Optimizer..."
    if [ -f /etc/debian_version ]; then
        apt update -qq && apt install earlyoom -y -qq 2>/dev/null && systemctl enable earlyoom 2>/dev/null && systemctl start earlyoom 2>/dev/null
    elif [ -f /etc/redhat-release ]; then
        yum install earlyoom -y 2>/dev/null; systemctl enable earlyoom 2>/dev/null; systemctl start earlyoom 2>/dev/null
    fi
    optimize_kernel "potato"
    show_success_art "POTATO MODE ACTIVE - Kernel Tuned + EarlyOOM"
}

remove_all() {
    print_info "Removing all swap..."
    swapoff -a 2>/dev/null || true; rm -f $SWAP_FILE; sed -i "\#$SWAP_FILE#d" /etc/fstab; sed -i "/swap/d" /etc/fstab
    systemctl stop zram-setup.service 2>/dev/null || true; systemctl disable zram-setup.service 2>/dev/null || true
    rm -f /etc/systemd/system/zram-setup.service; systemctl daemon-reload 2>/dev/null
    modprobe -r zram 2>/dev/null || true; echo 1 > /sys/block/zram0/reset 2>/dev/null || true
    rm -f /etc/sysctl.d/99-universal-swap.conf; [ -f /etc/debian_version ] && apt remove zram-tools -y -qq 2>/dev/null || true
    show_success_art "ALL SWAP REMOVED"
}

while true; do
    display_menu
    read choice
    case $choice in
        1) install_swapfile; read -p "Press Enter..." ;;
        2) install_zram; read -p "Press Enter..." ;;
        3) install_hybrid; read -p "Press Enter..." ;;
        4) remove_all; read -p "Press Enter..." ;;
        5) clear; echo -e "${GREEN}Done. - Deki Niswara${NC}"; exit 0 ;;
        *) print_error "Invalid!"; sleep 1 ;;
    esac
done
