#!/data/data/com.termux/files/usr/bin/bash
# © 2026 Hackers Colony Tech — All Rights Reserved

################ COLORS ################
RED='\033[1;91m'
GREEN='\033[1;92m'
YELLOW='\033[1;93m'
BLUE='\033[1;94m'
MAGENTA='\033[1;95m'
CYAN='\033[1;96m'
WHITE='\033[1;97m'
NC='\033[0m'

################ DAILY UNLOCK ################
LOCKFILE="$HOME/.hco_nexus_unlock"
TODAY=$(date +%F)

if [[ -f "$LOCKFILE" ]] && grep -q "$TODAY" "$LOCKFILE"; then
  UNLOCKED=true
else
  UNLOCKED=false
fi

################ TOOL LOCK ################
if [[ "$UNLOCKED" == false ]]; then
  clear
  echo -e "${RED}🔒 TOOL LOCKED 🔒${NC}"
  echo -e "${YELLOW}HCO-Nexus is locked by Hackers Colony Tech${NC}"
  echo
  echo -e "${CYAN}Subscribe & click Bell 🔔 to unlock${NC}"
  echo
  echo -e "${MAGENTA}Opening YouTube app in:${NC}"

  for i in 9 8 7 6 5 4 3 2 1; do
    echo -ne "${RED}$i...\r${NC}"
    sleep 1
  done
  echo

  am start -a android.intent.action.VIEW \
    -d "https://youtube.com/@hackers_colony_tech?si=0Ity7SxRo6aOO280" \
    com.google.android.youtube >/dev/null 2>&1

  echo
  read -p $'\e[96mPress ENTER after subscribing...\e[0m'
  echo "$TODAY" > "$LOCKFILE"
fi

################ BANNER ################
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

################ MENU ################
echo -e "${YELLOW}=========== MENU ===========${NC}"
echo -e "${GREEN}[1] Full Recon Scan${NC}"
echo -e "${GREEN}[2] Subdomain Enumeration${NC}"
echo -e "${GREEN}[3] Port Scan${NC}"
echo -e "${GREEN}[4] Security Header Check${NC}"
echo -e "${GREEN}[5] Red Team Mode${NC}"
echo -e "${GREEN}[6] Blue Team Mode${NC}"
echo -e "${RED}[0] Exit${NC}"
echo
read -p $'\e[96mHCO-Nexus > \e[0m' OPTION

[[ "$OPTION" == "0" ]] && exit

read -p $'\e[96mTarget domain: \e[0m' TARGET
REPORT="HCO-Nexus-Report-$TARGET.txt"
echo "HCO-Nexus Report — $TARGET" > "$REPORT"

loader() { echo -e "${CYAN}$1...${NC}"; sleep 1; }

################ FUNCTIONS ################
resolve_ip() {
  loader "Resolving IP"
  IP=$(curl -s "https://dns.google/resolve?name=$TARGET&type=A" \
      | grep -oP '"data":"\K[0-9.]+' | head -n1)
  echo -e "${GREEN}IP:${WHITE} $IP${NC}"
  echo "IP: $IP" >> "$REPORT"
}

subdomains() {
  loader "Enumerating subdomains"
  curl -s "https://crt.sh/?q=%25.$TARGET&output=json" |
    grep -oP '"name_value":"\K[^"]+' |
    sed 's/\\n/\n/g' | sort -u | head -n 10 |
    tee -a "$REPORT"
}

ports() {
  loader "Scanning ports"
  OPEN=0
  for p in 21 22 80 443 8080 3306; do
    timeout 1 bash -c "echo >/dev/tcp/$TARGET/$p" 2>/dev/null && {
      echo -e "${GREEN}Open port:${NC} $p"
      echo "Open port: $p" >> "$REPORT"
      ((OPEN++))
    }
  done
}

headers() {
  loader "Checking security headers"
  MISSING=0
  for h in Content-Security-Policy X-Frame-Options Strict-Transport-Security X-Content-Type-Options Referrer-Policy; do
    curl -s -I https://$TARGET | grep -qi "$h" || {
      echo -e "${RED}Missing:${NC} $h"
      ((MISSING++))
    }
  done
}

risk_score() {
  SCORE=$((OPEN*10 + MISSING*15))
  [[ $SCORE -gt 100 ]] && SCORE=100

  if (( SCORE < 30 )); then LEVEL="LOW 🟢"
  elif (( SCORE < 60 )); then LEVEL="MEDIUM 🟡"
  else LEVEL="HIGH 🔴"; fi

  echo -e "${YELLOW}Risk Level:${NC} $LEVEL ($SCORE/100)"
  echo "Risk: $LEVEL ($SCORE/100)" >> "$REPORT"
}

mitre() {
  echo -e "${MAGENTA}MITRE ATT&CK Mapping:${NC}"
  echo "T1046 - Network Service Discovery"
  echo "T1190 - Exploit Public-Facing Application (Risk)"
  echo "MITRE: T1046, T1190" >> "$REPORT"
}

################ EXECUTION ################
case $OPTION in
  1) resolve_ip; subdomains; ports; headers; risk_score; mitre ;;
  2) subdomains ;;
  3) ports ;;
  4) headers ;;
  5)
     echo -e "${RED}🔴 RED TEAM VIEW (SIMULATION)${NC}"
     resolve_ip; ports; risk_score; mitre ;;
  6)
     echo -e "${BLUE}🔵 BLUE TEAM VIEW${NC}"
     headers; risk_score ;;
esac

echo
echo -e "${GREEN}[✓] Report saved:${NC} $REPORT"
