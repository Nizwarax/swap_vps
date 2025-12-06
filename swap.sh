#!/bin/bash

# ┌──────────────────────────────────────────────┐
# │  ULTIMATE SWAP MANAGER - CELEBRATION EDIT.   │
# │  Fitur: Powerfull Logic + Auto ASCII Success │
# │  Design by: Deki Niswara                     │
# └──────────────────────────────────────────────┘

# Pastikan dijalankan sebagai root
if [[ $EUID -ne 0 ]]; then
   echo "Script harus dijalankan sebagai root!" 
   exit 1
fi

# === KONFIGURASI WARNA ===
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[0;33m'
export BLUE='\033[0;34m'
export PURPLE='\033[0;35m'
export CYAN='\033[0;36m'
export LIGHT='\033[0;37m'
export NC='\033[0m'

SWAP_FILE="/swapfile"

# === FUNGSI TAMPILAN (ART) ===

# Fungsi ini akan dipanggil SETIAP KALI SUKSES (Pasang/Hapus)
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
    echo -e "${PURPLE}"
    echo -e " ██╗███╗░░██╗░██████╗████████╗░█████╗░██╗░░░░░██╗░░░░░"
    echo -e " ██║████╗░██║██╔════╝╚══██╔══╝██╔══██╗██║░░░░░██║░░░░░"
    echo -e " ██║██╔██╗██║╚█████╗░░░░██║░░░███████║██║░░░░░██║░░░░░"
    echo -e " ██║██║╚████║░╚═══██╗░░░██║░░░██╔══██║██║░░░░░██║░░░░░"
    echo -e " ██║██║░╚███║██████╔╝░░░██║░░░██║░░██║███████╗███████╗"
    echo -e " ╚═╝╚═╝░░╚══╝╚═════╝░░░░╚═╝░░░╚═╝░░╚═╝╚══════╝╚══════╝${NC}"
    echo -e ""
    echo -e "${YELLOW}"
    echo -e " ░██████╗██╗░░░██║░█████╗░░█████╗░███████╗███████╗██████╗░"
    echo -e " ██╔════╝██║░░░██║██╔══██╗██╔══██╗██╔════╝██╔════╝██╔══██╗"
    echo -e " ╚█████╗░██║░░░██║██║░░╚═╝██║░░╚═╝█████╗░░█████╗░░██║░░██║"
    echo -e " ░╚═══██╗██║░░░██║██║░░██╗██║░░██╗██╔══╝░░██╔══╝░░██║░░██║"
    echo -e " ██████╔╝╚██████╔╝╚█████╔╝╚█████╔╝███████╗███████╗██████╔╝"
    echo -e " ╚═════╝░░╚═════╝░░╚════╝░░╚════╝░╚══════╝╚══════╝╚═════╝░${NC}"
    echo -e ""
    echo -e "${PURPLE}\n[ $message ]\n${NC}"
    echo "ulimit -SHn 1000000" >> /etc/profile
}

get_os_info() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS_NAME="$PRETTY_NAME"
    elif command -v lsb_release >/dev/null 2>&1; then
        OS_NAME=$(lsb_release -ds)
    else
        OS_NAME=$(cat /etc/*release | grep -m1 PRETTY_NAME | cut -d'"' -f2)
    fi
    [ -z "$OS_NAME" ] && OS_NAME="Unknown"
    echo "$OS_NAME"
}

display_menu() {
    opsy=$(get_os_info)
    RAM_TOTAL=$(free -h | grep Mem | awk '{print $2}')
    SWAP_USED=$(free -h | grep Swap | awk '{print $2 " / " $3}')
    
    clear
    echo -e "${YELLOW}┌────────────${NC} ${LIGHT}◈ Informasi Sistem ◈ ${NC}${YELLOW}────────────┐${NC}"
    echo -e "${YELLOW} ➽ OS         : $opsy ${NC}"
    echo -e "${YELLOW} ➽ Status RAM : $RAM_TOTAL ${NC}"
    echo -e "${YELLOW} ➽ Status Swap: $SWAP_USED (Used/Total) ${NC}"
    echo -e "${YELLOW}└─────────────────────────────────────────────────┘${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo " ➽ Dibuat Oleh: https://t.me/Deki_niswara"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${YELLOW} [1] ${NC} Buat Swap File (HDD/SSD Standard)"
    echo -e "${YELLOW} [2] ${NC} 🚀 Pasang ZRAM (Booster VPS)"
    echo -e "${YELLOW} [3] ${NC} Hapus Semua Swap"
    echo -e "${YELLOW} [4] ${NC} Keluar"
    echo ""
    echo -e -n "${CYAN} Pilih Menu [1-4]: ${NC}"
}

print_info() { echo -e "${BLUE}➽ $1${NC}"; }
print_error() { echo -e "${RED}✘ ✘ $1${NC}"; }

# === LOGIC SYSTEM ===

optimize_kernel() {
    MODE=$1
    SYSCTL="/etc/sysctl.conf"
    
    # Hapus setting lama
    sed -i '/vm.swappiness/d' $SYSCTL
    sed -i '/vm.vfs_cache_pressure/d' $SYSCTL
    
    if [[ "$MODE" == "zram" ]]; then
        echo "vm.swappiness=100" >> $SYSCTL
        echo "vm.vfs_cache_pressure=50" >> $SYSCTL
    else
        echo "vm.swappiness=10" >> $SYSCTL
        echo "vm.vfs_cache_pressure=50" >> $SYSCTL
    fi
    sysctl -p > /dev/null
}

install_zram() {
    print_info "Menginstall ZRAM..."
    if [ -f /etc/debian_version ]; then
        apt update -qq && apt install zram-tools -y -qq
    elif [ -f /etc/redhat-release ]; then
        yum install zram -y
    fi
    echo -e "ALGO=zstd\nPERCENT=60" > /etc/default/zramswap
    service zramswap reload 2>/dev/null || systemctl restart zramswap 2>/dev/null
    optimize_kernel "zram"
    
    # SUKSES -> TAMPILKAN ART
    show_success_art "ZRAM BERHASIL DIINSTAL & DIAKTIFKAN"
}

install_swapfile() {
    print_info "Masukkan ukuran swap (GB). Contoh: 1, 2"
    echo -e -n "${YELLOW}Ukuran (GB): ${NC}"
    read SWAP_SIZE_GB

    if ! [[ "$SWAP_SIZE_GB" =~ ^[0-9]+$ ]]; then
        print_error "Input harus angka!"
        return
    fi

    fallocate -l "${SWAP_SIZE_GB}G" $SWAP_FILE || dd if=/dev/zero of=$SWAP_FILE bs=1M count=$((SWAP_SIZE_GB*1024))
    chmod 600 $SWAP_FILE
    mkswap $SWAP_FILE
    swapon $SWAP_FILE
    
    if ! grep -q "$SWAP_FILE" /etc/fstab; then
        echo "$SWAP_FILE none swap sw 0 0" >> /etc/fstab
    fi
    optimize_kernel "hdd"
    
    # SUKSES -> TAMPILKAN ART
    show_success_art "SWAP FILE $SWAP_SIZE_GB GB BERHASIL DIBUAT"
}

remove_swap() {
    print_info "Menghapus Swap..."
    swapoff $SWAP_FILE 2>/dev/null
    sed -i "\#$SWAP_FILE#d" /etc/fstab
    rm -f $SWAP_FILE
    
    # Coba hapus ZRAM juga jika ada
    if command -v zramctl >/dev/null; then
        apt remove zram-tools -y -qq 2>/dev/null
    fi
    
    # SUKSES -> TAMPILKAN ART
    show_success_art "SEMUA SWAP BERHASIL DIHAPUS"
}

# === MAIN LOOP ===
while true; do
    display_menu
    read choice
    case $choice in
        1) install_swapfile; read -p "Tekan Enter..." ;;
        2) install_zram; read -p "Tekan Enter..." ;;
        3) remove_swap; read -p "Tekan Enter..." ;;
        4) exit 0 ;;
        *) print_error "Pilihan salah!"; sleep 1 ;;
    esac
done
