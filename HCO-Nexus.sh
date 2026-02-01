#!/data/data/com.termux/files/usr/bin/bash

############################################
# HCO-Nexus v3.0
# Hackers Colony Tech
# Educational & Ethical Cyber Tool
############################################

# ========= COLORS (NEON MODE) =========
RED='\033[1;91m'
GREEN='\033[1;92m'
YELLOW='\033[1;93m'
BLUE='\033[1;94m'
MAGENTA='\033[1;95m'
CYAN='\033[1;96m'
WHITE='\033[1;97m'
NC='\033[0m'

# ========= DEPENDENCY CHECK =========
deps=(curl whois timeout git termux-open)
for d in "${deps[@]}"; do
  command -v $d >/dev/null || {
    echo -e "${RED}[!] Missing dependency: $d${NC}"
    echo "Run: pkg install $d"
    exit 1
  }
done

# ========= AUTO UPDATE =========
if [ -d ".git" ]; then
  git pull --quiet
fi

# ========= BANNER =========
clear
echo -e "${CYAN}"
cat << "EOF"
██╗  ██╗ ██████╗ ██████╗
██║  ██║██╔════╝██╔═══██╗
███████║██║     ██║   ██║
██╔══██║██║     ██║   ██║
██║  ██║╚██████╗╚██████╔╝
╚═╝  ╚═╝ ╚═════╝ ╚═════╝

H C O - N E X U S
Hackers Colony Tech
Hacking with Termux in 2026
EOF
echo -e "${NC}"

# ========= INPUT =========
read -p $'\e[96m[+] Target domain: \e[0m' TARGET
read -p $'\e[96m[+] Mode (red / blue): \e[0m' MODE

REPORT="HCO-Nexus-Report-$TARGET.txt"
echo "HCO-Nexus Scan Report - $TARGET" > $REPORT

loader() {
  echo -ne "${CYAN}$1"
  for i in {1..3}; do
    echo -ne "."
    sleep 0.4
  done
  echo -e "${NC}"
}

# ========= IP RESOLUTION =========
loader "Resolving IP"
IP=$(curl -s "https://dns.google/resolve?name=$TARGET&type=A" | grep -oP '"data":"\K[^"]+')
[ -z "$IP" ] && echo "Failed to resolve" && exit 1
echo -e "${GREEN}[✓] IP: $IP${NC}"
echo "IP: $IP" >> $REPORT

# ========= WHOIS =========
loader "Fetching WHOIS"
whois $TARGET | grep -Ei "Registrar|Creation Date" | head -n 5 | tee -a $REPORT

# ========= SUBDOMAIN ENUM =========
loader "Enumerating subdomains"
SUBS=$(curl -s "https://crt.sh/?q=%25.$TARGET&output=json" | grep -o "\"name_value\":\"[^\"]*" | cut -d\":\" -f2 | sort -u | head -n 10)
echo -e "${YELLOW}Subdomains Found:${NC}"
echo "$SUBS" | tee -a $REPORT

# ========= PORT SCAN =========
loader "Scanning ports"
PORTS=(21 22 80 443 8080 3306)
OPEN_PORTS=()
for p in "${PORTS[@]}"; do
  timeout 1 bash -c "echo >/dev/tcp/$TARGET/$p" 2>/dev/null && OPEN_PORTS+=($p)
done
echo "Open Ports: ${OPEN_PORTS[*]:-None}" | tee -a $REPORT

# ========= HEADER ANALYSIS =========
loader "Checking security headers"
HEADERS=$(curl -s -I https://$TARGET)
SEC_HEADERS=(CSP X-Frame-Options Strict-Transport-Security X-Content-Type-Options Referrer-Policy)
MISSING=()
for h in "${SEC_HEADERS[@]}"; do
  echo "$HEADERS" | grep -qi "$h" || MISSING+=("$h")
done
echo "Missing Headers: ${MISSING[*]:-None}" | tee -a $REPORT

# ========= TECH DETECTION =========
SERVER=$(echo "$HEADERS" | grep -i "Server:" | cut -d' ' -f2-)
echo "Server: ${SERVER:-Unknown}" | tee -a $REPORT

# ========= MITRE ATT&CK MAPPING =========
echo -e "${MAGENTA}MITRE ATT&CK Mapping:${NC}"
if [[ ${#OPEN_PORTS[@]} -gt 0 ]]; then
  echo "T1046 - Network Service Discovery" | tee -a $REPORT
fi
if [[ ${#MISSING[@]} -gt 2 ]]; then
  echo "T1190 - Exploit Public-Facing Application (Risk)" | tee -a $REPORT
fi

# ========= RISK SCORE =========
SCORE=$(( ${#OPEN_PORTS[@]} * 8 + ${#MISSING[@]} * 10 ))
if [ $SCORE -ge 60 ]; then RISK="HIGH 🔴"
elif [ $SCORE -ge 30 ]; then RISK="MEDIUM 🟡"
else RISK="LOW 🟢"
fi
echo "Risk Level: $RISK ($SCORE/100)" | tee -a $REPORT

# ========= BLUE TEAM =========
if [[ "$MODE" == "blue" ]]; then
  echo -e "${BLUE}🔵 BLUE TEAM ADVICE${NC}"
  for h in "${MISSING[@]}"; do echo "Add header: $h"; done
  for p in "${OPEN_PORTS[@]}"; do echo "Restrict port: $p"; done
fi

# ========= RED TEAM =========
if [[ "$MODE" == "red" ]]; then
  echo -e "${RED}🔴 RED TEAM VIEW (SIMULATION)${NC}"
  echo "Attack surface exposed via misconfiguration"
fi

# ========= TOOL LOCK =========
echo
echo -e "${RED}🔒 TOOL LOCK ACTIVATED${NC}"
echo -e "${CYAN}Powered by Hackers Colony Tech${NC}"

for i in {5..1}; do
  echo -ne "${MAGENTA}Redirecting to YouTube in $i...\r${NC}"
  sleep 1
done

termux-open "https://www.youtube.com/@hackerscolonytech"

echo -e "${GREEN}[✓] Report saved: $REPORT${NC}"
