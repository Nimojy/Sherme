#!/bin/bash

# ============================================sherme============================================
#  ███████╗██████╗ ███████╗██████╗ ██╗   ██╗███╗   ███╗
#  ██╔════╝██╔══██╗██╔════╝██╔══██╗██║   ██║████╗ ████║
#  ███████╗██████╔╝█████╗  ██████╔╝██║   ██║██╔████╔██║
#  ╚════██║██╔═══╝ ██╔══╝  ██╔══██╗██║   ██║██║╚██╔╝██║
#  ███████║██║     ███████╗██║  ██║╚██████╔╝██║ ╚═╝ ██║
#  ╚══════╝╚═╝     ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚═╝
#
#  Sherme - Fully Automated Reconnaissance Framework
#  Author: dwoz
#  Version: 1.0
#  Description: All-in-one automated recon tool for penetration testing
# =============================================================================

# ----------------------------- COLORS & FORMATTING ---------------------------- #
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BLACK='\033[0;30m'
BRED='\033[1;31m'
BGREEN='\033[1;32m'
BYELLOW='\033[1;33m'
BBLUE='\033[1;34m'
BMAGENTA='\033[1;35m'
BCYAN='\033[1;36m'
BWHITE='\033[1;37m'
BG_BLACK='\033[40m'
RESET='\033[0m'
BOLD='\033[1m'
ITALIC='\033[3m'
UNDERLINE='\033[4m'
BLINK='\033[5m'

# ----------------------------- GLOBAL VARIABLES ----------------------------- #
VERSION="1.0"
TARGET=""
OUTPUT_DIR=""
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
TOOLS_FOUND=()
TOOLS_MISSING=()
THREADS=50
TIMEOUT=10
USER_AGENT="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
VERBOSE=0
SILENT=0

# ----------------------------- BANNER ----------------------------- #
print_banner() {
    echo -e "${BMAGENTA}"
    cat << 'EOF'

  ███████╗██████╗ ███████╗██████╗ ██╗   ██╗███╗   ███╗
  ██╔════╝██╔══██╗██╔════╝██╔══██╗██║   ██║████╗ ████║
  ███████╗██████╔╝█████╗  ██████╔╝██║   ██║██╔████╔██║
  ╚════██║██╔═══╝ ██╔══╝  ██╔══██╗██║   ██║██║╚██╔╝██║
  ███████║██║     ███████╗██║  ██║╚██████╔╝██║ ╚═╝ ██║
  ╚══════╝╚═╝     ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚═╝

EOF
    echo -e "  ${BCYAN}╔══════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "  ${BCYAN}║${RESET}  ${BWHITE}Fully Automated Reconnaissance Framework${RESET}                    ${BCYAN}║${RESET}"
    echo -e "  ${BCYAN}║${RESET}  ${YELLOW}Version:${RESET} ${BWHITE}${VERSION}${RESET}  ${YELLOW}Author:${RESET} ${BWHITE}dwoz${RESET}                         ${BCYAN}║${RESET}"
    echo -e "  ${BCYAN}║${RESET}  ${BMAGENTA}https://github.com/dwoz/sherme${RESET}                           ${BCYAN}║${RESET}"
    echo -e "  ${BCYAN}╚══════════════════════════════════════════════════════════════╝${RESET}"
    echo ""
}

# ----------------------------- UTILITY FUNCTIONS ----------------------------- #

log_info() {
    echo -e "${BLUE}[i]${RESET} ${WHITE}$1${RESET}"
}

log_success() {
    echo -e "${GREEN}[✓]${RESET} ${BGREEN}$1${RESET}"
}

log_warning() {
    echo -e "${YELLOW}[!]${RESET} ${BYELLOW}$1${RESET}"
}

log_error() {
    echo -e "${RED}[✗]${RESET} ${BRED}$1${RESET}"
}

log_step() {
    echo ""
    echo -e "${BMAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${BWHITE}  ▶ $1${RESET}"
    echo -e "${BMAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
}

log_substep() {
    echo -e "    ${CYAN}▸${RESET} ${WHITE}$1${RESET}"
}

print_divider() {
    echo -e "${CYAN}────────────────────────────────────────────────────────────────${RESET}"
}

spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    while [ "$(ps -p $pid -o pid=)" ]; do
        for (( i=0; i<${#spinstr}; i++ )); do
            printf "\r    ${BMAGENTA}%s${RESET} ${WHITE}%s${RESET}" "${spinstr:$i:1}" "$2"
            sleep $delay
        done
    done
    printf "\r"
}

check_tool() {
    if command -v "$1" &> /dev/null; then
        TOOLS_FOUND+=("$1")
        return 0
    else
        TOOLS_MISSING+=("$1")
        return 1
    fi
}

print_tool_status() {
    echo ""
    echo -e "  ${BWHITE}Tool Status:${RESET}"
    echo -e "  ${BCYAN}─────────────${RESET}"
    for tool in "${TOOLS_FOUND[@]}"; do
        echo -e "  ${GREEN}  ✓${RESET} ${WHITE}${tool}${RESET}"
    done
    for tool in "${TOOLS_MISSING[@]}"; do
        echo -e "  ${RED}  ✗${RESET} ${WHITE}${tool}${RESET} ${YELLOW}(not installed)${RESET}"
    done
    echo ""
}

cleanup() {
    local running_jobs
    running_jobs=$(jobs -p 2>/dev/null)
    if [ -n "$running_jobs" ]; then
        echo ""
        echo -e "${YELLOW}[*] Cleaning up background processes...${RESET}"
        echo "$running_jobs" | xargs -r kill 2>/dev/null
        wait 2>/dev/null
        echo -e "${GREEN}[✓] Cleanup complete.${RESET}"
    fi
}

# ----------------------------- TOOL INSTALLATION ----------------------------- #

install_tool() {
    local tool=$1
    local method=$2
    
    log_warning "Installing ${tool}..."
    
    case $method in
        go)
            if command -v go &> /dev/null; then
                go install -v "$tool@latest" 2>/dev/null
                log_success "${tool} installed via go"
            else
                log_error "Go not found. Please install Go first."
                return 1
            fi
            ;;
        apt)
            sudo apt-get install -y "$tool" 2>/dev/null
            log_success "${tool} installed via apt"
            ;;
        pip)
            pip install "$tool" 2>/dev/null
            log_success "${tool} installed via pip"
            ;;
        git)
            local repo=$3
            local dir=$(basename "$repo" .git)
            git clone --depth 1 "$repo" /tmp/sherme_tools/"$dir" 2>/dev/null
            cd /tmp/sherme_tools/"$dir" && make 2>/dev/null || go build 2>/dev/null
            sudo cp "$dir" /usr/local/bin/ 2>/dev/null
            log_success "${tool} installed from source"
            ;;
    esac
}

auto_install_missing() {
    if [ ${#TOOLS_MISSING[@]} -eq 0 ]; then
        return 0
    fi
    
    echo ""
    log_warning "Some tools are missing. Would you like to auto-install them?"
    echo -e "  ${YELLOW}Missing tools: ${TOOLS_MISSING[*]}${RESET}"
    echo ""
    read -p "$(echo -e ${BBLUE}'Install missing tools? [y/N]: '${RESET})" install_choice
    
    if [[ "$install_choice" =~ ^[Yy]$ ]]; then
        for tool in "${TOOLS_MISSING[@]}"; do
            case $tool in
                subfinder)
                    install_tool "github.com/projectdiscovery/subfinder/v2/cmd/subfinder" "go"
                    ;;
                gobuster)
                    install_tool "gobuster" "apt"
                    ;;
                feroxbuster)
                    install_tool "feroxbuster" "apt"
                    ;;
                amass)
                    install_tool "github.com/owasp-amass/amass/v4/..." "go"
                    ;;
                assetfinder)
                    install_tool "github.com/tomnomnom/assetfinder" "go"
                    ;;
                waybackurls)
                    install_tool "github.com/tomnomnom/waybackurls" "go"
                    ;;
                gau)
                    install_tool "github.com/lc/gau/v2/cmd/gau" "go"
                    ;;
                ffuf)
                    install_tool "github.com/ffuf/ffuf/v2" "go"
                    ;;
                nikto)
                    install_tool "nikto" "apt"
                    ;;
                whatweb)
                    install_tool "whatweb" "apt"
                    ;;
                dnsrecon)
                    install_tool "dnsrecon" "apt"
                    ;;
                theharvester)
                    install_tool "theharvester" "apt"
                    ;;
                wpscan)
                    install_tool "wpscan" "apt"
                    ;;
                curl)
                    install_tool "curl" "apt"
                    ;;
                dnsenum)
                    install_tool "dnsenum" "apt"
                    ;;
                sublist3r)
                    install_tool "sublist3r" "pip"
                    ;;
                httpx)
                    ;;
                nmap)
                    ;;
            esac
        done
        
        # Recheck tools
        TOOLS_FOUND=()
        TOOLS_MISSING=()
        for tool in subfinder gobuster feroxbuster amass assetfinder waybackurls gau ffuf nikto whatweb dnsrecon theharvester curl dnsenum sublist3r; do
            check_tool "$tool"
        done
        print_tool_status
    fi
}

# ----------------------------- RECON FUNCTIONS ----------------------------- #

# Phase 1: Subdomain Enumeration
phase_subdomains() {
    log_step "PHASE 1: Subdomain Enumeration"
    
    local subdomains_file="${OUTPUT_DIR}/subdomains/subdomains.txt"
    mkdir -p "${OUTPUT_DIR}/subdomains"
    
    # Subfinder
    if check_tool subfinder; then
        log_substep "Running subfinder..."
        subfinder -d "$TARGET" -all -silent -o "${OUTPUT_DIR}/subdomains/subfinder.txt" 2>/dev/null &
        local pid1=$!
        spinner $pid1 "subfinder enumerating subdomains..."
        wait $pid1 2>/dev/null
        local count=$(wc -l < "${OUTPUT_DIR}/subdomains/subfinder.txt" 2>/dev/null || echo 0)
        log_success "subfinder found ${count} subdomains"
    fi
    
    # Amass (passive)
    if check_tool amass; then
        log_substep "Running amass (passive mode)..."
        timeout 300 amass enum -passive -d "$TARGET" -o "${OUTPUT_DIR}/subdomains/amass.txt" 2>/dev/null &
        local pid2=$!
        spinner $pid2 "amass passive enumeration..."
        wait $pid2 2>/dev/null
        local count=$(wc -l < "${OUTPUT_DIR}/subdomains/amass.txt" 2>/dev/null || echo 0)
        log_success "amass found ${count} subdomains"
    fi
    
    # Assetfinder
    if check_tool assetfinder; then
        log_substep "Running assetfinder..."
        assetfinder --subs-only "$TARGET" > "${OUTPUT_DIR}/subdomains/assetfinder.txt" 2>/dev/null &
        local pid3=$!
        spinner $pid3 "assetfinder scanning..."
        wait $pid3 2>/dev/null
        local count=$(wc -l < "${OUTPUT_DIR}/subdomains/assetfinder.txt" 2>/dev/null || echo 0)
        log_success "assetfinder found ${count} subdomains"
    fi
    
    # Sublist3r
    if check_tool sublist3r; then
        log_substep "Running sublist3r..."
        sublist3r -d "$TARGET" -o "${OUTPUT_DIR}/subdomains/sublist3r.txt" 2>/dev/null &
        local pid4=$!
        spinner $pid4 "sublist3r enumerating..."
        wait $pid4 2>/dev/null
        local count=$(wc -l < "${OUTPUT_DIR}/subdomains/sublist3r.txt" 2>/dev/null || echo 0)
        log_success "sublist3r found ${count} subdomains"
    fi
    
    # Merge and deduplicate all subdomains
    log_substep "Merging and deduplicating subdomains..."
    cat ${OUTPUT_DIR}/subdomains/*.txt 2>/dev/null | sort -u | grep -E "^[a-zA-Z0-9]" > "$subdomains_file"
    local total=$(wc -l < "$subdomains_file" 2>/dev/null || echo 0)
    
    echo ""
    log_success "Total unique subdomains found: ${BWHITE}${total}${RESET}"
    
    # Save to CSV for easy parsing
    cat "$subdomains_file" | head -20
    if [ "$total" -gt 20 ]; then
        echo -e "    ${YELLOW}... and $((total - 20)) more${RESET}"
    fi
}

# Phase 2: DNS Resolution & Live Host Detection
phase_dns_resolve() {
    log_step "PHASE 2: DNS Resolution & Live Host Detection"
    
    local subdomains_file="${OUTPUT_DIR}/subdomains/subdomains.txt"
    local live_file="${OUTPUT_DIR}/live_hosts.txt"
    mkdir -p "${OUTPUT_DIR}"
    
    if [ ! -s "$subdomains_file" ]; then
        log_warning "No subdomains found, using target domain only"
        echo "$TARGET" > "$subdomains_file"
    fi
    
    log_substep "Checking for live hosts..."
    
    # Use curl for quick live check
    while IFS= read -r subdomain; do
        (
            if curl -s --connect-timeout 5 --max-time 10 -o /dev/null -w "%{http_code}" "http://${subdomain}" 2>/dev/null | grep -qE '^[2-3]'; then
                echo "http://${subdomain}" >> "${OUTPUT_DIR}/live_http.txt"
            fi
            if curl -s --connect-timeout 5 --max-time 10 -o /dev/null -w "%{http_code}" "https://${subdomain}" 2>/dev/null | grep -qE '^[2-3]'; then
                echo "https://${subdomain}" >> "${OUTPUT_DIR}/live_https.txt"
            fi
        ) &
    done < "$subdomains_file"
    wait
    
    # Merge live hosts
    cat "${OUTPUT_DIR}/live_http.txt" "${OUTPUT_DIR}/live_https.txt" 2>/dev/null | sort -u > "$live_file"
    rm -f "${OUTPUT_DIR}/live_http.txt" "${OUTPUT_DIR}/live_https.txt"
    
    local count=$(wc -l < "$live_file" 2>/dev/null || echo 0)
    log_success "Found ${BWHITE}${count}${RESET} live hosts"
    
    cat "$live_file" 2>/dev/null | head -20
}

# Phase 3: Directory Brute Force
phase_directories() {
    log_step "PHASE 3: Directory & File Brute Force"
    
    local live_file="${OUTPUT_DIR}/live_hosts.txt"
    local dir_results="${OUTPUT_DIR}/directories"
    mkdir -p "$dir_results"
    
    local wordlist="/usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt"
    if [ ! -f "$wordlist" ]; then
        wordlist="/usr/share/wordlists/dirb/common.txt"
    fi
    if [ ! -f "$wordlist" ]; then
        wordlist="/usr/share/seclists/Discovery/Web-Content/common.txt"
    fi
    if [ ! -f "$wordlist" ]; then
        log_warning "No wordlist found. Creating a small default one..."
        wordlist="/tmp/sherme_wordlist.txt"
        printf "admin\nlogin\nwp-admin\nbackup\nconfig\ndatabase\ndb\ndebug\ndev\ndocs\n.git\n.env\n.htaccess\nimages\nimg\ninc\ninclude\njs\nlib\nlog\nlogs\nlogin\nmedia\nnew\nold\nportal\nprivate\npublic\nrobots.txt\ns3\nsecret\nserver-status\nsitemap.xml\nsql\nsrc\nstaging\ntest\ntmp\nupload\nuploads\nuser\nusers\nvendor\napi\ndashboard\nwp-content\nwp-includes\n.svn\n.cvs\nWEB-INF\n\n" > "$wordlist"
    fi
    
    # Feroxbuster (fastest)
    if check_tool feroxbuster; then
        log_substep "Running feroxbuster on live hosts..."
        while IFS= read -r host; do
            local hostname=$(echo "$host" | sed 's|https\?://||' | sed 's|/.*||')
            (
                feroxbuster -u "$host" -w "$wordlist" -t $THREADS -q --silent \
                    -o "${dir_results}/ferox_${hostname}.txt" \
                    --user-agent "$USER_AGENT" 2>/dev/null
            ) &
        done < "$live_file"
        wait
        log_success "feroxbuster scan complete"
    fi
    
    # Gobuster (reliable)
    if check_tool gobuster; then
        log_substep "Running gobuster on live hosts..."
        while IFS= read -r host; do
            local hostname=$(echo "$host" | sed 's|https\?://||' | sed 's|/.*||')
            (
                gobuster dir -u "$host" -w "$wordlist" -t $THREADS -q \
                    -o "${dir_results}/gobuster_${hostname}.txt" \
                    --no-error 2>/dev/null
            ) &
        done < "$live_file"
        wait
        log_success "gobuster scan complete"
    fi
    
    # FFUF (web fuzzer)
    if check_tool ffuf; then
        log_substep "Running ffuf on live hosts..."
        while IFS= read -r host; do
            local hostname=$(echo "$host" | sed 's|https\?://||' | sed 's|/.*||')
            (
                ffuf -u "${host}/FUZZ" -w "$wordlist" -t $THREADS -s \
                    -o "${dir_results}/ffuf_${hostname}.json" -of json 2>/dev/null
            ) &
        done < "$live_file"
        wait
        log_success "ffuf scan complete"
    fi
    
    # Merge directory results
    log_substep "Merging directory results..."
    cat ${dir_results}/*.txt 2>/dev/null | sort -u > "${OUTPUT_DIR}/directories/all_directories.txt"
    local count=$(wc -l < "${OUTPUT_DIR}/directories/all_directories.txt" 2>/dev/null || echo 0)
    log_success "Found ${BWHITE}${count}${RESET} unique paths"
}

# Phase 4: Wayback & Historical URLs
phase_wayback() {
    log_step "PHASE 4: Wayback Machine & Historical URLs"
    
    local subdomains_file="${OUTPUT_DIR}/subdomains/subdomains.txt"
    mkdir -p "${OUTPUT_DIR}/wayback"
    
    # Waybackurls
    if check_tool waybackurls; then
        log_substep "Fetching wayback URLs..."
        cat "$subdomains_file" | waybackurls > "${OUTPUT_DIR}/wayback/waybackurls.txt" 2>/dev/null &
        local pid1=$!
        spinner $pid1 "waybackurls fetching historical URLs..."
        wait $pid1 2>/dev/null
        local count=$(wc -l < "${OUTPUT_DIR}/wayback/waybackurls.txt" 2>/dev/null || echo 0)
        log_success "waybackurls found ${count} URLs"
    fi
    
    # GAU (GetAllUrls)
    if check_tool gau; then
        log_substep "Running gau for URL collection..."
        cat "$subdomains_file" | gau --threads 10 -o "${OUTPUT_DIR}/wayback/gau.txt" 2>/dev/null &
        local pid2=$!
        spinner $pid2 "gau collecting URLs..."
        wait $pid2 2>/dev/null
        local count=$(wc -l < "${OUTPUT_DIR}/wayback/gau.txt" 2>/dev/null || echo 0)
        log_success "gau found ${count} URLs"
    fi
    
    # Merge wayback results
    cat ${OUTPUT_DIR}/wayback/*.txt 2>/dev/null | sort -u > "${OUTPUT_DIR}/wayback/all_urls.txt"
    local total=$(wc -l < "${OUTPUT_DIR}/wayback/all_urls.txt" 2>/dev/null || echo 0)
    
    # Extract interesting patterns
    log_substep "Extracting interesting URLs..."
    grep -iE '\.(php|asp|aspx|jsp|cgi|pl|py|rb|json|xml|sql|bak|old|orig|save|swp|tmp|temp|config|conf|ini|env)' \
        "${OUTPUT_DIR}/wayback/all_urls.txt" 2>/dev/null > "${OUTPUT_DIR}/wayback/interesting_urls.txt"
    
    grep -iE '(admin|login|upload|backup|config|debug|test|dev|api|secret|token|key|password)' \
        "${OUTPUT_DIR}/wayback/all_urls.txt" 2>/dev/null > "${OUTPUT_DIR}/wayback/sensitive_urls.txt"
    
    log_success "Total historical URLs: ${BWHITE}${total}${RESET}"
    log_success "Interesting URLs: $(wc -l < "${OUTPUT_DIR}/wayback/interesting_urls.txt" 2>/dev/null || echo 0)"
    log_success "Sensitive URLs: $(wc -l < "${OUTPUT_DIR}/wayback/sensitive_urls.txt" 2>/dev/null || echo 0)"
}

# Phase 5: Technology Detection
phase_technology() {
    log_step "PHASE 5: Technology Detection & Fingerprinting"
    
    local live_file="${OUTPUT_DIR}/live_hosts.txt"
    mkdir -p "${OUTPUT_DIR}/technology"
    
    # WhatWeb
    if check_tool whatweb; then
        log_substep "Running WhatWeb for technology detection..."
        while IFS= read -r host; do
            whatweb -a 3 --color=never "$host" >> "${OUTPUT_DIR}/technology/whatweb.txt" 2>/dev/null &
        done < "$live_file"
        wait
        log_success "WhatWeb scan complete"
    fi
    
    # Nikto
    if check_tool nikto; then
        log_substep "Running Nikto vulnerability scanner..."
        while IFS= read -r host; do
            local hostname=$(echo "$host" | sed 's|https\?://||' | sed 's|/.*||')
            nikto -h "$host" -o "${OUTPUT_DIR}/technology/nikto_${hostname}.txt" -Format txt -Tuning x6 2>/dev/null &
        done < "$live_file"
        wait
        log_success "Nikto scan complete"
    fi
    
    # Check for WordPress
    log_substep "Checking for WordPress installations..."
    while IFS= read -r host; do
        if curl -s --connect-timeout 5 "$host/wp-login.php" 2>/dev/null | grep -q "WordPress"; then
            echo "$host" >> "${OUTPUT_DIR}/technology/wordpress_sites.txt"
            log_success "WordPress detected: $host"
        fi
        if curl -s --connect-timeout 5 "$host/xmlrpc.php" 2>/dev/null | grep -q "XML-RPC"; then
            echo "$host (xmlrpc enabled)" >> "${OUTPUT_DIR}/technology/wordpress_sites.txt"
        fi
    done < "$live_file"
    
    # WPScan
    if check_tool wpscan && [ -f "${OUTPUT_DIR}/technology/wordpress_sites.txt" ]; then
        log_substep "Running WPScan on WordPress sites..."
        while IFS= read -r wp_site; do
            local wp_url=$(echo "$wp_site" | cut -d' ' -f1)
            wpscan --url "$wp_url" --no-banner -o "${OUTPUT_DIR}/technology/wpscan_${wp_url##*/}.txt" 2>/dev/null &
        done < "${OUTPUT_DIR}/technology/wordpress_sites.txt"
        wait
        log_success "WPScan complete"
    fi
}

# Phase 6: Information Gathering
phase_info_gathering() {
    log_step "PHASE 6: Additional Information Gathering"
    
    mkdir -p "${OUTPUT_DIR}/info"
    
    # DNS Recon
    if check_tool dnsrecon; then
        log_substep "Running DNSRecon..."
        dnsrecon -d "$TARGET" -z -j "${OUTPUT_DIR}/info/dnsrecon.json" 2>/dev/null
        log_success "DNSRecon scan complete"
    fi
    
    # TheHarvester
    if check_tool theharvester; then
        log_substep "Running theHarvester..."
        theHarvester -d "$TARGET" -b all -f "${OUTPUT_DIR}/info/harvester.html" 2>/dev/null
        log_success "theHarvester complete"
    fi
    
    # DNSEnum
    if check_tool dnsenum; then
        log_substep "Running DNSenum..."
        dnsenum --enum "$TARGET" > "${OUTPUT_DIR}/info/dnsenum.txt" 2>/dev/null
        log_success "DNSenum complete"
    fi
    
    # SSL/TLS checks
    log_substep "Checking SSL/TLS certificates..."
    echo | openssl s_client -connect "${TARGET}:443" -servername "$TARGET" 2>/dev/null | \
        openssl x509 -noout -text 2>/dev/null > "${OUTPUT_DIR}/info/ssl_cert.txt"
    
    # Extract emails and IPs from all results
    log_substep "Extracting emails and IP addresses..."
    cat ${OUTPUT_DIR}/**/*.txt ${OUTPUT_DIR}/*.txt 2>/dev/null | \
        grep -oE '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' | sort -u > "${OUTPUT_DIR}/info/emails.txt"
    
    cat ${OUTPUT_DIR}/**/*.txt ${OUTPUT_DIR}/*.txt 2>/dev/null | \
        grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' | sort -u > "${OUTPUT_DIR}/info/ip_addresses.txt"
    
    local emails=$(wc -l < "${OUTPUT_DIR}/info/emails.txt" 2>/dev/null || echo 0)
    local ips=$(wc -l < "${OUTPUT_DIR}/info/ip_addresses.txt" 2>/dev/null || echo 0)
    log_success "Emails found: ${BWHITE}${emails}${RESET}"
    log_success "IP addresses found: ${BWHITE}${ips}${RESET}"
}

# ----------------------------- REPORT GENERATION ----------------------------- #

generate_report() {
    log_step "GENERATING FINAL REPORT"
    
    local report="${OUTPUT_DIR}/REPORT.md"
    
    cat > "$report" << HEADER
# Sherme Recon Report
## Target: ${TARGET}
## Date: $(date)
## Generated by: Sherme v${VERSION}

---

## Summary
HEADER
    
    # Count results
    local subdomain_count=$(wc -l < "${OUTPUT_DIR}/subdomains/subdomains.txt" 2>/dev/null || echo 0)
    local live_count=$(wc -l < "${OUTPUT_DIR}/live_hosts.txt" 2>/dev/null || echo 0)
    local dir_count=$(wc -l < "${OUTPUT_DIR}/directories/all_directories.txt" 2>/dev/null || echo 0)
    local url_count=$(wc -l < "${OUTPUT_DIR}/wayback/all_urls.txt" 2>/dev/null || echo 0)
    local interesting_count=$(wc -l < "${OUTPUT_DIR}/wayback/interesting_urls.txt" 2>/dev/null || echo 0)
    local sensitive_count=$(wc -l < "${OUTPUT_DIR}/wayback/sensitive_urls.txt" 2>/dev/null || echo 0)
    local email_count=$(wc -l < "${OUTPUT_DIR}/info/emails.txt" 2>/dev/null || echo 0)
    local ip_count=$(wc -l < "${OUTPUT_DIR}/info/ip_addresses.txt" 2>/dev/null || echo 0)
    
    cat >> "$report" << STATS
| Category | Count |
|----------|-------|
| Subdomains | ${subdomain_count} |
| Live Hosts | ${live_count} |
| Directory Paths | ${dir_count} |
| Historical URLs | ${url_count} |
| Interesting URLs | ${interesting_count} |
| Sensitive URLs | ${sensitive_count} |
| Emails | ${email_count} |
| IP Addresses | ${ip_count} |

---

## Subdomains
\`\`\`
$(cat "${OUTPUT_DIR}/subdomains/subdomains.txt" 2>/dev/null | head -100)
\`\`\`

## Live Hosts
\`\`\`
$(cat "${OUTPUT_DIR}/live_hosts.txt" 2>/dev/null)
\`\`\`

## Directory Findings
\`\`\`
$(cat "${OUTPUT_DIR}/directories/all_directories.txt" 2>/dev/null | head -100)
\`\`\`

## Interesting URLs
\`\`\`
$(cat "${OUTPUT_DIR}/wayback/interesting_urls.txt" 2>/dev/null | head -50)
\`\`\`

## Sensitive URLs
\`\`\`
$(cat "${OUTPUT_DIR}/wayback/sensitive_urls.txt" 2>/dev/null | head -50)
\`\`\`

## Technology Stack
\`\`\`
$(cat "${OUTPUT_DIR}/technology/whatweb.txt" 2>/dev/null | head -50)
\`\`\`

## Emails Found
\`\`\`
$(cat "${OUTPUT_DIR}/info/emails.txt" 2>/dev/null)
\`\`\`

## IP Addresses
\`\`\`
$(cat "${OUTPUT_DIR}/info/ip_addresses.txt" 2>/dev/null)
\`\`\`

---

## File Structure
\`\`\`
$(find "$OUTPUT_DIR" -type f | sed "s|${OUTPUT_DIR}|.|" | sort)
\`\`\`

---
*Report generated by Sherme v${VERSION}*
STATS
    
    log_success "Report saved to: ${BWHITE}${report}${RESET}"
}

# ----------------------------- MAIN EXECUTION ----------------------------- #

usage() {
    echo ""
    echo -e "${BWHITE}Usage:${RESET} $0 [options] -d <domain>"
    echo ""
    echo -e "${BWHITE}Options:${RESET}"
    echo -e "  ${CYAN}-d, --domain${RESET}       Target domain (required)"
    echo -e "  ${CYAN}-o, --output${RESET}       Output directory (default: sherme_<domain>_<timestamp>)"
    echo -e "  ${CYAN}-t, --threads${RESET}      Number of threads (default: 50)"
    echo -e "  ${CYAN}-T, --timeout${RESET}      Connection timeout (default: 10s)"
    echo -e "  ${CYAN}-q, --quiet${RESET}        Quiet mode - minimal output"
    echo -e "  ${CYAN}-v, --verbose${RESET}      Verbose output"
    echo -e "  ${CYAN}-h, --help${RESET}         Show this help message"
    echo ""
    echo -e "${BWHITE}Examples:${RESET}"
    echo -e "  ${GREEN}$0 -d example.com${RESET}"
    echo -e "  ${GREEN}$0 -d example.com -t 100 -o my_scan${RESET}"
    echo -e "  ${GREEN}$0 --domain example.com --quiet${RESET}"
    echo ""
    echo -e "${BYELLOW}Recommended Tools:${RESET}"
    echo -e "  ${WHITE}subfinder, feroxbuster, gobuster, ffuf, amass, gau,${RESET}"
    echo -e "  ${WHITE}waybackurls, assetfinder, nikto, whatweb, dnsrecon,${RESET}"
    echo -e "  ${WHITE}theharvester, wpscan, curl, dnsenum, sublist3r${RESET}"
    echo ""
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -d|--domain)
                TARGET="$2"
                shift 2
                ;;
            -o|--output)
                OUTPUT_DIR="$2"
                shift 2
                ;;
            -t|--threads)
                THREADS="$2"
                shift 2
                ;;
            -T|--timeout)
                TIMEOUT="$2"
                shift 2
                ;;
            -q|--quiet)
                SILENT=1
                shift
                ;;
            -v|--verbose)
                VERBOSE=1
                shift
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done
    
    # Validate required arguments
    if [ -z "$TARGET" ]; then
        log_error "Domain is required!"
        usage
        exit 1
    fi
    
    # Set default output directory
    if [ -z "$OUTPUT_DIR" ]; then
        OUTPUT_DIR="sherme_${TARGET}_${TIMESTAMP}"
    fi
    
    # Create output directory
    mkdir -p "$OUTPUT_DIR"
}

main() {
    # Set trap for cleanup
    trap cleanup EXIT INT TERM
    
    print_banner
    
    # Parse arguments
    parse_args "$@"
    
    echo -e "  ${BBLUE}Target:${RESET}     ${BWHITE}${TARGET}${RESET}"
    echo -e "  ${BBLUE}Output:${RESET}     ${BWHITE}${OUTPUT_DIR}${RESET}"
    echo -e "  ${BBLUE}Threads:${RESET}    ${BWHITE}${THREADS}${RESET}"
    echo -e "  ${BBLUE}Started:${RESET}    ${BWHITE}$(date)${RESET}"
    echo ""
    
    # Check for required tools
    log_info "Checking for required tools..."
    
    # Core tools (required)
    local core_missing=0
    for tool in curl; do
        if ! command -v "$tool" &> /dev/null; then
            log_error "Required tool '${tool}' is not installed!"
            core_missing=1
        fi
    done
    
    if [ $core_missing -eq 1 ]; then
        log_error "Please install required tools before running Sherme."
        exit 1
    fi
    
    # Check optional tools
    for tool in subfinder gobuster feroxbuster amass assetfinder waybackurls gau ffuf nikto whatweb dnsrecon theharvester curl wpscan dnsenum sublist3r; do
        check_tool "$tool"
    done
    
    print_tool_status
    
    # Auto-install missing tools
    auto_install_missing
    
    # Start timing
    local start_time=$(date +%s)
    
    # Execute recon phases
    phase_subdomains
    phase_dns_resolve
    phase_directories
    phase_wayback
    phase_technology
    phase_info_gathering
    
    # Generate report
    generate_report
    
    # Calculate duration
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    local minutes=$((duration / 60))
    local seconds=$((duration % 60))
    
    # Final summary
    echo ""
    echo -e "${BMAGENTA}╔══════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${BMAGENTA}║${RESET}  ${BWHITE}RECONNAISSANCE COMPLETE!${RESET}                                     ${BMAGENTA}║${RESET}"
    echo -e "${BMAGENTA}╠══════════════════════════════════════════════════════════════╣${RESET}"
    echo -e "${BMAGENTA}║${RESET}  ${BBLUE}Target:${RESET}    ${BWHITE}${TARGET}${RESET}                                   ${BMAGENTA}║${RESET}"
    echo -e "${BMAGENTA}║${RESET}  ${BBLUE}Duration:${RESET}  ${BWHITE}${minutes}m ${seconds}s${RESET}                                   ${BMAGENTA}║${RESET}"
    echo -e "${BMAGENTA}║${RESET}  ${BBLUE}Output:${RESET}    ${BWHITE}${OUTPUT_DIR}${RESET}                          ${BMAGENTA}║${RESET}"
    echo -e "${BMAGENTA}║${RESET}  ${BBLUE}Report:${RESET}    ${BWHITE}${OUTPUT_DIR}/REPORT.md${RESET}                   ${BMAGENTA}║${RESET}"
    echo -e "${BMAGENTA}╚══════════════════════════════════════════════════════════════╝${RESET}"
    echo ""
    echo -e "  ${YELLOW}Tip:${RESET} Check ${BWHITE}${OUTPUT_DIR}/REPORT.md${RESET} for the full report"
    echo -e "  ${YELLOW}Tip:${RESET} Sensitive URLs are in ${BWHITE}${OUTPUT_DIR}/wayback/sensitive_urls.txt${RESET}"
    echo ""
}

# Run main function
main "$@"
