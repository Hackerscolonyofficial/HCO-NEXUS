#!/data/data/com.termux/files/usr/bin/bash
# © 2026 Hackers Colony Tech — All Rights Reserved

############ COLORS ############
RED='\033[1;91m'
GREEN='\033[1;92m'
YELLOW='\033[1;93m'
BLUE='\033[1;94m'
MAGENTA='\033[1;95m'
CYAN='\033[1;96m'
WHITE='\033[1;97m'
NC='\033[0m'

############ TOOL LOCK ############
clear
echo -e "${RED}🔒 TOOL LOCKED 🔒${NC}"
echo -e "${YELLOW}HCO-Nexus is locked by Hackers Colony Tech${NC}"
echo
echo -e "${CYAN}To unlock the tool:${NC}"
echo -e "${WHITE}• Subscribe to our YouTube channel${NC}"
echo -e "${WHITE}• Click the Bell 🔔${NC}"
echo
echo -e "${MAGENTA}Redirecting to YouTube app in:${NC}"

for i in 9 8 7 6 5 4 3 2 1; do
  echo -ne "${RED}$i...\r${NC}"
  sleep 1
done
echo

############ OPEN YOUTUBE APP (FIXED) ############
am start \
  -a android.intent.action.VIEW \
  -d "https://youtube.com/@hackers_colony_tech?si=0Ity7SxRo6aOO280" \
  com.google.android.youtube >/dev/null 2>&1

echo
echo -e "${GREEN}✔ Subscribe, then return to Termux${NC}"
read -p $'\e[96mPress ENTER to unlock HCO-Nexus...\e[0m'

############ UNLOCKED BANNER ############
clear
echo -e "${CYAN}"
cat << "EOF"
██╗  ██╗ ██████╗  ██████╗
██║  ██║██╔════╝ ██╔═══██╗
███████║██║      ██║   ██║
██╔══██║██║      ██║   ██║
██║  ██║╚██████╗ ╚██████╔╝
╚═╝  ╚═╝ ╚═════╝  ╚═════╝
EOF
echo -e "${RED}        H C O   N E X U S${NC}"
echo -e "${WHITE}Hackers Colony Tech${NC}"
echo -e "${CYAN}Hacking with Termux in 2026${NC}"
echo

############ MENU ############
echo -e "${YELLOW}=========== MENU ===========${NC}"
echo -e "${GREEN}[1] Full Recon Scan${NC}"
echo -e "${GREEN}[2] Subdomain Enumeration${NC}"
echo -e "${GREEN}[3] Port Scan${NC}"
echo -e "${GREEN}[4] Security Header Check${NC}"
echo -e "${GREEN}[5] Red Team Mode (Simulation)${NC}"
echo -e "${GREEN}[6] Blue Team Mode${NC}"
echo -e "${RED}[0] Exit${NC}"
echo
read -p $'\e[96mHCO-Nexus > \e[0m' OPTION

if [[ "$OPTION" == "0" ]]; then
  echo -e "${RED}Exiting HCO-Nexus${NC}"
  exit
fi

read -p $'\e[96mTarget domain (example.com): \e[0m' TARGET
REPORT="HCO-Nexus-Report-$TARGET.txt"
echo "HCO-Nexus Report — $TARGET" > "$REPORT"

loader() {
  echo -e "${CYAN}$1...${NC}"
  sleep 1
}

resolve_ip() {
  loader "Resolving IP"
  IP=$(getent hosts "$TARGET" | awk '{print $1}' | head -n1)
  echo -e "${GREEN}IP:${WHITE} $IP${NC}"
  echo "IP: $IP" >> "$REPORT"
}

subdomains() {
  loader "Enumerating subdomains"
  curl -s "https://crt.sh/?q=%25.$TARGET&output=json" |
    grep -oP '"name_value":"\K[^"]+' |
    sed 's/\\n/\n/g' |
    sort -u | head -n 15 | tee -a "$REPORT"
}

ports() {
  loader "Scanning ports"
  for p in 21 22 80 443 8080 3306; do
    timeout 1 bash -c "echo >/dev/tcp/$TARGET/$p" 2>/dev/null &&
      echo "Open port: $p" | tee -a "$REPORT"
  done
}

headers() {
  loader "Checking security headers"
  curl -s -I https://$TARGET |
    grep -Ei "Server|Content-Security-Policy|X-Frame-Options|Strict-Transport-Security|X-Content-Type-Options|Referrer-Policy" |
    tee -a "$REPORT"
}

case $OPTION in
  1) resolve_ip; subdomains; ports; headers ;;
  2) subdomains ;;
  3) ports ;;
  4) headers ;;
  5) echo -e "${RED}🔴 RED TEAM MODE (Simulation)${NC}"; resolve_ip; ports ;;
  6) echo -e "${BLUE}🔵 BLUE TEAM MODE${NC}"; headers ;;
  *) echo -e "${RED}Invalid option${NC}" ;;
esac

echo
echo -e "${GREEN}[✓] Report saved: $REPORT${NC}"
