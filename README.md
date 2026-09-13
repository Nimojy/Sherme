<div align="center">

# 🕵️ Sherme

### Fully Automated Reconnaissance & Vulnerability Scanner

[![made-with-bash](https://img.shields.io/badge/Made%20with-Bash-1f425f.svg)](https://www.gnu.org/software/bash/)
[![Version](https://img.shields.io/badge/version-2.0-purple.svg)](https://github.com/sherme)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](http://makeapullrequest.com)

</div>

<div align="center">

```
  ███████╗  ██╗  ██╗  ███████╗  ██████╗   ███╗   ███╗  ███████╗
  ██╔════╝  ██║  ██║  ██╔════╝  ██╔══██╗  ████╗ ████║  ██╔════╝
  ███████╗  ███████║  █████╗    ██████╔╝  ██╔████╔██║  █████╗
  ╚════██║  ██╔══██║  ██╔══╝    ██╔══██╗  ██║╚██╔╝██║  ██╔══╝
  ███████║  ██║  ██║  ███████╗  ██║  ██║  ██║ ╚═╝ ██║  ███████╗
  ╚══════╝  ╚═╝  ╚═╝  ╚══════╝  ╚═╝  ╚═╝  ╚═╝     ╚═╝  ╚══════╝
```

**Just give it a website, and it does ALL the work.**
**Recon ⟶ Port scan ⟶ Vulnerability scan ⟶ Auto report.**

</div>

---

## ⚡ Features

| Feature | Description |
|---------|-------------|
| 🌐 **Subdomain Enumeration** | Discovers subdomains using multiple tools |
| 🔍 **Live Host Detection** | Probes hosts with httpx (fast & automated) |
| 🚪 **Port Scanning** | Finds open ports with naabu |
| 📁 **Directory Brute Force** | Scans for hidden directories and files |
| 🕰️ **Historical URLs** | Fetches old URLs from wayback machine & archives |
| 🖥️ **Tech Fingerprinting** | Detects technologies, CMS, and frameworks |
| 🕸️ **Vulnerability Scanning** | nuclei + dalfox (XSS) + crlfuzz (CRLF) |
| 📊 **Auto Report** | Generates a Markdown report that **flags found vulns by severity** |
| 🤖 **Fully Automated** | One command runs everything and reports findings |
| 🎨 **Beautiful Output** | Colorful, animated, and easy to read |

## 🛠️ Tools Integrated

| Tool | Purpose |
|------|---------|
| **Subfinder** | Passive subdomain enumeration |
| **Amass** | Network mapping and subdomain discovery |
| **Assetfinder** | Subdomain discovery from variety of sources |
| **httpx** | Fast live-host probing + tech detection |
| **naabu** | Fast port scanning |
| **Gobuster** | Directory & DNS brute forcing |
| **Feroxbuster** | Fast recursive directory scan |
| **Ffuf** | Flexible web fuzzing |
| **Waybackurls** | Historical URL discovery |
| **GAU** | Collect all known URLs |
| **Katana** | Automated web crawling |
| **Nuclei** | Template-based vulnerability scanner |
| **dalfox** | XSS vulnerability scanner |
| **crlfuzz** | CRLF injection scanner |
| **sqlmap** | SQL injection automation |
| **dnsx** | Fast DNS toolkit & resolution |
| **WhatWeb** | Technology fingerprinting |
| **Nikto** | Web server vulnerability scanner |
| **DNSRecon** | DNS enumeration and zone transfer |
| **theHarvester** | Email and subdomain harvesting |
| **WPScan** | WordPress vulnerability scanner |
| **DNSenum** | DNS-based reconnaissance |

## 📦 Installation

### Quick Install (One-Liner)

```bash
git clone https://github.com/sherme/sherme.git && cd sherme && chmod +x install.sh && ./install.sh
```

> The installer **automatically detects your OS** and uses the right package manager.

## 🖥️ Cross-Platform Compatibility

| OS | Package Manager | Auto-Detected |
|----|-----------------|---------------|
| Debian / Ubuntu / Kali / Parrot | `apt` | ✅ |
| Fedora / RHEL / CentOS / Rocky / Alma | `dnf` / `yum` | ✅ |
| Arch / Manjaro / EndeavourOS | `pacman` | ✅ |
| openSUSE | `zypper` | ✅ |
| Alpine Linux | `apk` | ✅ |
| macOS | `brew` (Homebrew) | ✅ |
| FreeBSD / OpenBSD / NetBSD | `pkg` | ✅ |
| Windows (MSYS2 / Git Bash) | `pacman` / `choco` / `winget` | ✅ |
| Windows (WSL) | matches chosen distro | ✅ |

Sherme is a single portable Bash script with **no OS-specific binaries**:
- `timeout` is wrapped with a portable fallback (macOS/BSD don't ship GNU `timeout`)
- All Go-based tools compile identically on every platform
- `install.sh` maps each tool to the correct package name per OS and falls back to `go install` / `pip` when a distro lacks a package

### Install Dependencies

**Kali Linux / Parrot OS:**
```bash
sudo apt update && sudo apt install -y gobuster feroxbuster dnsrecon dnsenum nikto whatweb theharvester sqlmap jq
```

**Build Go tools:**
```bash
sudo apt install -y golang-go
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install -v github.com/owasp-amass/amass/v4/...@master
go install -v github.com/tomnomnom/assetfinder@latest
go install -v github.com/tomnomnom/waybackurls@latest
go install -v github.com/lc/gau/v2/cmd/gau@latest
go install -v github.com/ffuf/ffuf/v2@latest
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
go install -v github.com/projectdiscovery/naabu/v2/cmd/naabu@latest
go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
go install -v github.com/projectdiscovery/katana/cmd/katana@latest
go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@latest
go install -v github.com/hahwul/dalfox/v2@latest
go install -v github.com/dwisiswant0/crlfuzz/cmd/crlfuzz@latest
export PATH=$PATH:$(go env GOPATH)/bin
```

## 🚀 Usage

```bash
chmod +x sherme.sh
./sherme.sh -d example.com
```

### Options

| Option | Description |
|--------|-------------|
| `-d, --domain` | Target domain (required) |
| `-o, --output` | Custom output directory |
| `-t, --threads` | Number of threads (default: 50) |
| `-q, --quiet` | Quiet mode |
| `-v, --verbose` | Verbose output |
| `-h, --help` | Show help |

### Examples

```bash
# Basic scan
./sherme.sh -d example.com

# High-speed scan with custom output
./sherme.sh -d example.com -t 200 -o my_scan

# Quiet mode
./sherme.sh -d example.com --quiet
```

## 📁 Output Structure

```
sherme_example.com_20260912_123456/
├── REPORT.md                      # Complete summary report (flags vulns by severity)
├── live_hosts.txt                 # Live host URLs
├── subdomains/
│   ├── subdomains.txt             # All unique subdomains
│   ├── subfinder.txt              # Subfinder results
│   ├── amass.txt                  # Amass results
│   └── assetfinder.txt            # Assetfinder results
├── ports/
│   └── open_ports.txt             # Open ports from naabu
├── directories/
│   ├── all_directories.txt        # All discovered paths
│   ├── ferox_*.txt                # Feroxbuster results
│   └── gobuster_*.txt             # Gobuster results
├── wayback/
│   ├── all_urls.txt               # All historical URLs
│   ├── interesting_urls.txt       # Potentially interesting URLs
│   └── sensitive_urls.txt         # Sensitive files & directories
├── vulnerabilities/
│   ├── nuclei.jsonl               # Raw nuclei results (JSON)
│   ├── vulnerabilities.txt        # Parsed findings (severity + name + URL)
│   ├── vuln_summary.txt           # Severity breakdown
│   ├── dalfox_xss.txt             # XSS findings
│   └── crlfuzz_findings.txt       # CRLF injection findings
├── technology/
│   ├── whatweb.txt                # Technology fingerprints
│   └── nikto_*.txt                # Nikto scan results
└── info/
    ├── emails.txt                 # Discovered email addresses
    ├── ip_addresses.txt           # Discovered IP addresses
    └── ssl_cert.txt               # SSL/TLS certificate details
```

## 🎯 Workflow

```
┌─────────────┐     ┌──────────────────┐     ┌─────────────────┐
│  Input URL  │ ──▶ │  Subdomain Enum  │ ──▶ │  Live Detection │
└─────────────┘     └──────────────────┘     └─────────────────┘
                                                        │
         ┌──────────────────────────────────────────────┤
         ▼                                              ▼
  ┌─────────────┐                             ┌─────────────────┐
  │ URL Harvest │                             │  Port Scan      │
  └─────────────┘                             └─────────────────┘
         │                                              │
         ▼                                              ▼
  ┌─────────────┐                             ┌─────────────────┐
  │  Tech Recon │ ──────────────────────────▶ │  Vuln Scanning  │
  └─────────────┘    (nuclei/dalfox/crlfuzz) └─────────────────┘
         │                                              │
         ▼                                              ▼
  ┌─────────────┐                             ┌─────────────────┐
  │  REPORT     │ ◀────────────────────────── │  Fix Report     │
  └─────────────┘      (severity flags)       └─────────────────┘
```

## ⚠️ Disclaimer

> **IMPORTANT:** Sherme is intended for **authorized security testing only**.
> You must have explicit written permission to scan any target.
> Unauthorized scanning is illegal in most jurisdictions.
> The authors are **not responsible** for any misuse of this tool.

## 📝 Legal

- Only use Sherme on systems you own or have **written permission** to test.
- Respect all applicable laws and regulations in your region.
- Use responsibly and ethically.

## 🤝 Contributing

Pull requests are welcome! If you'd like to contribute:

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push & submit a pull request

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

<div align="center">
Made with ❤️ by dwoz
</div>