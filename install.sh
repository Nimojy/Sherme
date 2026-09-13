#!/bin/bash

# ==============================================================================
#  Sherme - Cross-Platform Dependency Installer
#  Automatically installs all tools required by Sherme
#  Supports: Debian/Ubuntu/Kali/Parrot, Fedora/RHEL/CentOS, Arch, openSUSE,
#            Alpine, macOS (Homebrew), BSD, Windows (MSYS2 / WSL)
# ==============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BWHITE='\033[1;37m'
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
    echo -e "           Cross-Platform Dependency Installer v2.0"
    echo -e "   ════════════════════════════════════════════════════════════\033[0m"
    echo ""
}

# ----------------------------- OS DETECTION ----------------------------- #
OS_FAMILY="generic"
PKG_MANAGER=""
PKG_INSTALL=""
PKG_UPDATE="true"
SUDO_CMD=""

detect_os() {
    if [ "$(id -u)" -eq 0 ]; then
        SUDO_CMD=""
    elif command -v sudo &> /dev/null; then
        SUDO_CMD="sudo"
    else
        SUDO_CMD=""
    fi

    case "$(uname -s)" in
        Darwin)
            OS_FAMILY="macos"
            PKG_MANAGER="brew"
            PKG_INSTALL="brew install"
            PKG_UPDATE="true"
            ;;
        MINGW*|MSYS*|CYGWIN*)
            OS_FAMILY="windows"
            if command -v pacman &> /dev/null; then
                PKG_MANAGER="pacman"
                PKG_INSTALL="pacman -S --noconfirm"
            elif command -v choco &> /dev/null; then
                PKG_MANAGER="choco"
                PKG_INSTALL="choco install -y"
            else
                PKG_MANAGER="winget"
                PKG_INSTALL="winget install"
            fi
            ;;
        FreeBSD|OpenBSD|NetBSD)
            OS_FAMILY="bsd"
            PKG_MANAGER="pkg"
            PKG_INSTALL="pkg install -y"
            PKG_UPDATE="false"
            ;;
        Linux)
            if [ -f /etc/alpine-release ]; then
                OS_FAMILY="alpine"; PKG_MANAGER="apk"; PKG_INSTALL="apk add --no-cache"; PKG_UPDATE="false"
            elif [ -f /etc/arch-release ]; then
                OS_FAMILY="arch"; PKG_MANAGER="pacman"; PKG_INSTALL="pacman -S --noconfirm"; PKG_UPDATE="true"
            elif [ -f /etc/redhat-release ] || grep -qiE 'fedora|rhel|centos|rocky|almalinux|amazon' /etc/os-release 2>/dev/null; then
                OS_FAMILY="redhat"
                if command -v dnf &> /dev/null; then
                    PKG_MANAGER="dnf"; PKG_INSTALL="dnf install -y"; PKG_UPDATE="false"
                else
                    PKG_MANAGER="yum"; PKG_INSTALL="yum install -y"; PKG_UPDATE="false"
                fi
            elif grep -qi 'suse' /etc/os-release 2>/dev/null; then
                OS_FAMILY="suse"; PKG_MANAGER="zypper"; PKG_INSTALL="zypper install -y"; PKG_UPDATE="true"
            elif [ -f /etc/debian_version ] || grep -qiE 'debian|ubuntu|kali|parrot' /etc/os-release 2>/dev/null; then
                OS_FAMILY="debian"; PKG_MANAGER="apt"; PKG_INSTALL="apt-get install -y"; PKG_UPDATE="true"
            else
                # Fallback: try to detect any installed package manager
                if command -v apt-get &> /dev/null; then
                    OS_FAMILY="debian"; PKG_MANAGER="apt"; PKG_INSTALL="apt-get install -y"; PKG_UPDATE="true"
                elif command -v dnf &> /dev/null; then
                    OS_FAMILY="redhat"; PKG_MANAGER="dnf"; PKG_INSTALL="dnf install -y"; PKG_UPDATE="false"
                elif command -v pacman &> /dev/null; then
                    OS_FAMILY="arch"; PKG_MANAGER="pacman"; PKG_INSTALL="pacman -S --noconfirm"; PKG_UPDATE="true"
                else
                    OS_FAMILY="linux-other"; PKG_MANAGER=""; PKG_INSTALL=""; PKG_UPDATE="false"
                fi
            fi
            ;;
        *)
            OS_FAMILY="generic"; PKG_MANAGER=""; PKG_INSTALL=""; PKG_UPDATE="false"
            ;;
    esac
}

detect_os

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

# ----------------------------- PACKAGE MANAGER HELPERS ----------------------------- #
pkg_update() {
    if [ "$PKG_UPDATE" != "true" ] || [ -z "$PKG_MANAGER" ]; then
        return 0
    fi
    case $PKG_MANAGER in
        apt)    $SUDO_CMD apt-get update -y 2>/dev/null ;;
        pacman) $SUDO_CMD pacman -Sy --noconfirm 2>/dev/null ;;
        zypper) $SUDO_CMD zypper refresh 2>/dev/null ;;
        brew)   brew update 2>/dev/null ;;
        *)      return 0 ;;
    esac
}

pkg_install() {
    # pkg_install <pkg1> <pkg2> ...  (installs each through the native manager)
    if [ -z "$PKG_MANAGER" ]; then
        return 1
    fi
    $SUDO_CMD $PKG_INSTALL "$@" 2>/dev/null
}

install_pip() {
    log_info "Installing via pip: $1"
    if command -v pip3 &> /dev/null; then
        pip3 install --break-system-packages -q "$1" 2>/dev/null || pip3 install -q "$1" 2>/dev/null
    elif command -v pip &> /dev/null; then
        pip install -q "$1" 2>/dev/null
    else
        log_error "pip not found - cannot install $1"
        return 1
    fi
}

install_go() {
    local pkg=$1
    local name=$2
    [ -z "$name" ] && name=$(basename "$pkg")
    log_info "Installing via go: $name"
    GOBIN="$(go env GOPATH 2>/dev/null)/bin"
    mkdir -p "$GOBIN"
    go install -v "$pkg@latest" 2>/dev/null
    if [ -x "$GOBIN/$name" ] || command -v "$name" &> /dev/null; then
        log_success "$name installed"
        export PATH="$PATH:$GOBIN"
        return 0
    else
        log_error "Failed to install $name"
        return 1
    fi
}

link_gopath() {
    # Make sure Go binaries are on PATH (works for all OSes)
    local gobin
    if command -v go &> /dev/null; then
        gobin="$(go env GOPATH 2>/dev/null)/bin"
        mkdir -p "$gobin" 2>/dev/null
        case ":$PATH:" in
            *":$gobin:"*) ;;
            *) export PATH="$PATH:$gobin" ;;
        esac
        if ! grep -q "go env GOPATH" ~/.bashrc 2>/dev/null; then
            echo "export PATH=\$PATH:\$(go env GOPATH 2>/dev/null)/bin" >> ~/.bashrc 2>/dev/null
        fi
        if [ -f ~/.zshrc ] && ! grep -q "go env GOPATH" ~/.zshrc 2>/dev/null; then
            echo "export PATH=\$PATH:\$(go env GOPATH 2>/dev/null)/bin" >> ~/.zshrc 2>/dev/null
        fi
    fi
}

# ----------------------------- OS-SPECIFIC PACKAGE LISTS ----------------------------- #
install_base_deps() {
    echo ""
    echo "════════════════════════════════════════════════════"
    echo "  [1/5] Installing platform base dependencies"
    echo "════════════════════════════════════════════════════"

    local pkgs=()
    case $OS_FAMILY in
        debian) pkgs=(git curl wget openssl jq python3 python3-pip golang-go) ;;
        redhat) pkgs=(git curl wget openssl jq python3 python3-pip golang) ;;
        arch)   pkgs=(git curl wget openssl jq python python-pip go) ;;
        suse)   pkgs=(git curl wget openssl jq python3 python3-pip go) ;;
        alpine) pkgs=(git curl wget openssl jq python3 py3-pip go) ;;
        macos)  pkgs=(git curl wget openssl jq python3 go) ;;
        bsd)    pkgs=(git curl wget ca_root_nss jq python3 py-pip go) ;;
        windows)
            if [ "$PKG_MANAGER" = "pacman" ]; then
                pkgs=(mingw-w64-x86_64-git mingw-w64-x86_64-curl mingw-w64-x86_64-openssl mingw-w64-x86_64-jq mingw-w64-x86_64-python mingw-w64-x86_64-go)
            elif [ "$PKG_MANAGER" = "choco" ]; then
                pkgs=(git curl wget openssl jq python3 golang)
            fi
            ;;
        *)
            log_warning "Unsupported package manager - base deps must be installed manually"
            ;;
    esac

    if [ ${#pkgs[@]} -gt 0 ] && [ -n "$PKG_MANAGER" ]; then
        pkg_update
        pkg_install "${pkgs[@]}"
    fi

    # macOS: ensure pip is available via python3 if not present
    if [ "$OS_FAMILY" = "macos" ] && ! command -v pip3 &> /dev/null; then
        log_info "Bootstrapping pip on macOS..."
        python3 -m ensurepip --upgrade 2>/dev/null
    fi
}

ensure_go() {
    if ! command -v go &> /dev/null; then
        log_error "Go is not installed. It is required for most Sherme tools."
        log_info "Install Go manually from https://go.dev/dl/ (all OSes supported)"
        return 1
    fi
    log_success "Go $(go version 2>/dev/null | awk '{print $3}') detected"
    link_gopath
    return 0
}

ensure_python() {
    if ! command -v python3 &> /dev/null; then
        log_warning "python3 not found - Python-based tools will be skipped"
        return 1
    fi
    log_success "python3 detected"
    return 0
}

# ----------------------------- TOOL INSTALLATION ----------------------------- #
# Go-based tools (install identically on every OS that has Go)
install_go_tools() {
    echo ""
    echo "════════════════════════════════════════════════════"
    echo "  [2/5] Installing Go-based tools"
    echo "════════════════════════════════════════════════════"

    ensure_go || return 1

    local go_tools=(
        "github.com/projectdiscovery/subfinder/v2/cmd/subfinder|subfinder"
        "github.com/projectdiscovery/httpx/cmd/httpx|httpx"
        "github.com/projectdiscovery/naabu/v2/cmd/naabu|naabu"
        "github.com/projectdiscovery/nuclei/v3/cmd/nuclei|nuclei"
        "github.com/projectdiscovery/katana/cmd/katana|katana"
        "github.com/projectdiscovery/dnsx/cmd/dnsx|dnsx"
        "github.com/owasp-amass/amass/v4/...|amass"
        "github.com/tomnomnom/assetfinder|assetfinder"
        "github.com/tomnomnom/waybackurls|waybackurls"
        "github.com/lc/gau/v2/cmd/gau|gau"
        "github.com/ffuf/ffuf/v2|ffuf"
        "github.com/OJ/gobuster/v3|gobuster"
        "github.com/epi052/feroxbuster/v2|feroxbuster"
        "github.com/hahwul/dalfox/v2|dalfox"
        "github.com/dwisiswant0/crlfuzz/cmd/crlfuzz|crlfuzz"
    )

    for entry in "${go_tools[@]}"; do
        local mod="${entry%%|*}"
        local name="${entry##*|}"
        check_install "$name" || install_go "$mod" "$name"
    done
}

# Python-based tools
install_python_tools() {
    echo ""
    echo "════════════════════════════════════════════════════"
    echo "  [3/5] Installing Python-based tools"
    echo "════════════════════════════════════════════════════"

    ensure_python || return 1

    check_install sqlmap || install_pip "sqlmap"
    check_install sublist3r || install_pip "sublist3r"
    check_install theHarvester || install_pip "theHarvester"
    check_install dnsrecon || install_pip "dnsrecon"
}

# OS repo-based web scanners (package names vary by distribution)
install_repo_tools() {
    echo ""
    echo "════════════════════════════════════════════════════"
    echo "  [4/5] Installing web scanner tools from OS repos"
    echo "════════════════════════════════════════════════════"

    local nikto_pkg whatweb_pkg dnsenum_pkg wpscan_pkg gobuster_pkg feroxbuster_pkg

    case $OS_FAMILY in
        debian) nikto_pkg=nikto; whatweb_pkg=whatweb; dnsenum_pkg=dnsenum; wpscan_pkg=wpscan; gobuster_pkg=gobuster; feroxbuster_pkg=feroxbuster ;;
        redhat) nikto_pkg=nikto; whatweb_pkg=whatweb; dnsenum_pkg=""; wpscan_pkg=""; gobuster_pkg=""; feroxbuster_pkg="" ;;
        arch)   nikto_pkg=nikto; whatweb_pkg=whatweb; dnsenum_pkg=dnsenum; wpscan_pkg=""; gobuster_pkg=gobuster; feroxbuster_pkg="" ;;
        suse)   nikto_pkg=nikto; whatweb_pkg=whatweb; dnsenum_pkg=dnsenum; wpscan_pkg=""; gobuster_pkg=""; feroxbuster_pkg="" ;;
        alpine) nikto_pkg=nikto; whatweb_pkg=whatweb; dnsenum_pkg=""; wpscan_pkg=""; gobuster_pkg=""; feroxbuster_pkg="" ;;
        macos)  nikto_pkg=nikto; whatweb_pkg=whatweb; dnsenum_pkg=dnsenum; wpscan_pkg=""; gobuster_pkg=gobuster; feroxbuster_pkg=feroxbuster ;;
        bsd)    nikto_pkg=nikto; whatweb_pkg=whatweb; dnsenum_pkg=""; wpscan_pkg=""; gobuster_pkg=""; feroxbuster_pkg="" ;;
        *)      nikto_pkg=""; whatweb_pkg=""; dnsenum_pkg=""; wpscan_pkg=""; gobuster_pkg=""; feroxbuster_pkg="" ;;
    esac

    for pair in "nikto|$nikto_pkg" "whatweb|$whatweb_pkg" "dnsenum|$dnsenum_pkg" "wpscan|$wpscan_pkg" "gobuster|$gobuster_pkg" "feroxbuster|$feroxbuster_pkg"; do
        local cmd="${pair%%|*}"
        local pkg="${pair##*|}"
        if check_install "$cmd" > /dev/null 2>&1; then
            continue
        fi
        if [ -n "$pkg" ] && [ -n "$PKG_MANAGER" ]; then
            log_info "Installing ${cmd} via ${PKG_MANAGER}..."
            if pkg_install "$pkg"; then
                log_success "$cmd installed"
            else
                log_warning "$cmd could not be installed from OS repos (try manually)"
            fi
        else
            log_warning "$cmd not available in ${PKG_MANAGER:-this OS} repos - skipping (install manually)"
        fi
    done
}

# ----------------------------- VERIFICATION ----------------------------- #
verify_tools() {
    echo ""
    echo "════════════════════════════════════════════════════"
    echo "  [5/5] Final verification"
    echo "════════════════════════════════════════════════════"

    link_gopath

    echo ""
    local tools_list="subfinder amass assetfinder waybackurls gau ffuf httpx nuclei naabu katana dnsx dalfox crlfuzz gobuster feroxbuster sqlmap sublist3r theHarvester dnsrecon nikto whatweb dnsenum wpscan curl openssl jq"
    local total=0 found=0

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

    if [ "$found" -ge 10 ]; then
        log_success "Installation complete! You're ready to use Sherme."
        echo ""
        echo -e "  ${CYAN}Usage:${RESET} ./sherme.sh -d example.com"
        echo ""
    else
        log_warning "Some tools could not be installed automatically."
        log_info "See the Sherme README for manual install instructions."
    fi
}

make_symlink() {
    if [ "$OS_FAMILY" = "windows" ]; then
        log_info "Windows detected - add sherme to PATH manually or use WSL for the 'sherme' command."
        return 0
    fi
    if [ ! -L /usr/local/bin/sherme ] && [ -n "$SUDO_CMD" ]; then
        log_info "Creating global symlink..."
        $SUDO_CMD ln -sf "$(pwd)/sherme.sh" /usr/local/bin/sherme 2>/dev/null && \
            log_success "Type 'sherme' from anywhere now!" || \
            log_info "Run: sudo ln -sf $(pwd)/sherme.sh /usr/local/bin/sherme"
    fi
}

main() {
    print_banner

    echo ""
    log_info "Detected OS: ${BWHITE}${OS_FAMILY}${RESET} (${PKG_MANAGER:-no package manager found})"
    log_info "If this is wrong, install the base tools manually (see README)."
    echo ""

    install_base_deps
    install_go_tools
    install_python_tools
    install_repo_tools
    verify_tools
    make_symlink
}

main "$@"