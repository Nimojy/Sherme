#!/bin/bash

# ==============================================================================
#  Sherme - Dependency Installer
#  Automatically installs all tools required by Sherme
# ==============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
RESET='\033[0m'

log_info() { echo -e "${BLUE}[i]${RESET} ${WHITE}$1${RESET}"; }
log_success() { echo -e "${GREEN}[✓]${RESET} ${GREEN}$1${RESET}"; }
log_warning() { echo -e "${YELLOW}[!]${RESET} ${YELLOW}$1${RESET}"; }
log_error() { echo -e "${RED}[✗]${RESET} ${RED}$1${RESET}"; }

print_banner() {
    clear
    echo -e "\033[1;35m"
    cat << 'EOF'

  ███████╗  ██╗  ██╗  ███████╗  ██████╗   ███╗   ███╗  ███████╗
  ██╔════╝  ██║  ██║  ██╔════╝  ██╔══██╗  ████╗ ████║  ██╔════╝
  ███████╗  ███████║  █████╗    ██████╔╝  ██╔████╔██║  █████╗
  ╚════██║  ██╔══██║  ██╔══╝    ██╔══██╗  ██║╚██╔╝██║  ██╔══╝
  ███████║  ██║  ██║  ███████╗  ██║  ██║  ██║ ╚═╝ ██║  ███████╗
  ╚══════╝  ╚═╝  ╚═╝  ╚══════╝  ╚═╝  ╚═╝  ╚═╝     ╚═╝  ╚══════╝

EOF
    echo -e "\033[1;36m   ════════════════════════════════════════════════════════════"
    echo -e "           Dependency Installer v2.0"
    echo -e "   ════════════════════════════════════════════════════════════\033[0m"
    echo ""
}

check_install() {
    local cmd=$1
    if command -v "$cmd" &> /dev/null; then
        log_success "$cmd is already installed"
        return 0
    else
        log_warning "$cmd is missing"
        return 1
    fi
}

install_apt() {
    log_info "Installing via apt: $@"
    sudo apt-get install -y "$@" 2>/dev/null
}

install_go() {
    local pkg=$1
    local name=$(basename "$pkg")
    log_info "Installing via go: $name"
    go install -v "$pkg@latest" 2>/dev/null
    if [ $? -eq 0 ]; then
        log_success "$name installed"
        export PATH=$PATH:$(go env GOPATH)/bin
        echo "export PATH=\$PATH:\$(go env GOPATH)/bin" >> ~/.bashrc
        source ~/.bashrc
    else
        log_error "Failed to install $name"
    fi
}

install_pip() {
    log_info "Installing via pip: $1"
    pip3 install "$1" 2>/dev/null
}

main() {
    print_banner
    
    # Detect OS
    if [ -f /etc/debian_version ]; then
        log_info "Detected Debian-based system"
        sudo apt-get update -y 2>/dev/null
    elif [ -f /etc/redhat-release ]; then
        log_info "Detected RedHat-based system"
        sudo yum install -y epel-release 2>/dev/null
    else
        log_warning "Unknown OS - attempting generic installs"
    fi
    
    echo ""
    echo "════════════════════════════════════════════════════"
    echo "  [1/4] Installing system packages"
    echo "════════════════════════════════════════════════════"
    
    # System packages
    if [ -f /etc/debian_version ]; then
        install_apt golang-go git curl wget openssl jq
        install_apt gobuster feroxbuster sqlmap
        install_apt dnsrecon dnsenum nikto whatweb
        install_apt python3 python3-pip
    fi
    
    # Check go
    if ! command -v go &> /dev/null; then
        log_error "Go not installed. Please install Go manually: https://go.dev/dl/"
        exit 1
    fi
    log_success "Go $(go version | awk '{print $3}') detected"
    
    echo ""
    echo "════════════════════════════════════════════════════"
    echo "  [2/4] Installing Go-based tools"
    echo "════════════════════════════════════════════════════"
    
    # Go tools
    check_install subfinder || install_go "github.com/projectdiscovery/subfinder/v2/cmd/subfinder"
    check_install amass || install_go "github.com/owasp-amass/amass/v4/..."
    check_install assetfinder || install_go "github.com/tomnomnom/assetfinder"
    check_install waybackurls || install_go "github.com/tomnomnom/waybackurls"
    check_install gau || install_go "github.com/lc/gau/v2/cmd/gau"
    check_install ffuf || install_go "github.com/ffuf/ffuf/v2"
    check_install httpx || install_go "github.com/projectdiscovery/httpx/cmd/httpx"
    check_install nuclei || install_go "github.com/projectdiscovery/nuclei/v3/cmd/nuclei"
    check_install naabu || install_go "github.com/projectdiscovery/naabu/v2/cmd/naabu"
    check_install katana || install_go "github.com/projectdiscovery/katana/cmd/katana"
    check_install dnsx || install_go "github.com/projectdiscovery/dnsx/cmd/dnsx"
    check_install dalfox || install_go "github.com/hahwul/dalfox/v2"
    check_install crlfuzz || install_go "github.com/dwisiswant0/crlfuzz/cmd/crlfuzz"
    
    echo ""
    echo "════════════════════════════════════════════════════"
    echo "  [3/4] Installing Python tools"
    echo "════════════════════════════════════════════════════"
    
    # Python tools
    check_install sublist3r || install_pip "sublist3r"
    check_install theHarvester || install_pip "theHarvester"
    
    echo ""
    echo "════════════════════════════════════════════════════"
    echo "  [4/4] Final verification"
    echo "════════════════════════════════════════════════════"
    
    # Verify all tools
    echo ""
    tools_list="subfinder amass assetfinder waybackurls gau ffuf httpx nuclei naabu katana dnsx dalfox crlfuzz gobuster feroxbuster sqlmap nikto whatweb dnsrecon theharvester dnsenum curl openssl jq"
    total=0
    found=0
    
    for tool in $tools_list; do
        total=$((total + 1))
        if command -v "$tool" &> /dev/null; then
            found=$((found + 1))
            echo -e "  ${GREEN}✓${RESET} ${WHITE}$tool${RESET}"
        else
            echo -e "  ${RED}✗${RESET} ${WHITE}$tool${RESET} ${YELLOW}(not installed)${RESET}"
        fi
    done
    
    echo ""
    echo -e "  ${BWHITE}${found}/${total}${RESET} tools installed"
    echo ""
    
    if [ "$found" -ge 5 ]; then
        log_success "Installation complete! You're ready to use Sherme."
        echo ""
        echo -e "  ${CYAN}Usage:${RESET} ./sherme.sh -d example.com"
        echo ""
    else
        log_warning "Some tools could not be installed automatically."
        log_info "Please install them manually and re-run this script."
    fi
    
    # Create symlink for easy access
    if [ ! -L /usr/local/bin/sherme ]; then
        log_info "Creating global symlink..."
        sudo ln -sf "$(pwd)/sherme.sh" /usr/local/bin/sherme 2>/dev/null && \
            log_success "Type 'sherme' from anywhere now!"
    fi
}

main