<div align="center">

# 🕵️ Sherme

### Fully Automated Reconnaissance Framework

[![made-with-bash](https://img.shields.io/badge/Made%20with-Bash-1f425f.svg)](https://www.gnu.org/software/bash/)
[![Version](https://img.shields.io/badge/version-1.0-purple.svg)](https://github.com/sherme)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](http://makeapullrequest.com)

</div>

<div align="center">

```
  ███████╗██████╗ ███████╗██████╗ ██╗   ██╗███╗   ███╗
  ██╔════╝██╔══██╗██╔════╝██╔══██╗██║   ██║████╗ ████║
  ███████╗██████╔╝█████╗  ██████╔╝██║   ██║██╔████╔██║
  ╚════██║██╔═══╝ ██╔══╝  ██╔══██╗██║   ██║██║╚██╔╝██║
  ███████║██║     ███████╗██║  ██║╚██████╔╝██║ ╚═╝ ██║
  ╚══════╝╚═╝     ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚═╝
```

**Just give it a website, and it does ALL the work.**

</div>

---

## ⚡ Features

| Feature | Description |
|---------|-------------|
| 🌐 **Subdomain Enumeration** | Discovers subdomains using multiple tools |
| 🔍 **Live Host Detection** | Identifies which targets are actually alive |
| 📁 **Directory Brute Force** | Scans for hidden directories and files |
| 🕰️ **Historical URLs** | Fetches old URLs from wayback machine & archives |
| 🖥️ **Tech Fingerprinting** | Detects technologies, CMS, and frameworks |
| 🕸️ **Vulnerability Scanning** | Checks for known web vulnerabilities |
| 📊 **Auto Report** | Generates a complete Markdown report |
| 🎨 **Beautiful Output** | Colorful, animated, and easy to read |

## 🛠️ Tools Integrated

| Tool | Purpose |
|------|---------|
| **Subfinder** | Passive subdomain enumeration |
| **Amass** | Network mapping and subdomain discovery |
| **Assetfinder** | Subdomain discovery from variety of sources |
| **Gobuster** | Directory & DNS brute forcing |
| **Feroxbuster** | Fast recursive directory scan |
| **Ffuf** | Flexible web fuzzing |
| **Waybackurls** | Historical URL discovery |
| **GAU** | Collect all known URLs |
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

### Install Dependencies

**Kali Linux / Parrot OS:**
```bash
sudo apt update && sudo apt install -y gobuster feroxbuster dnsrecon dnsenum nikto whatweb theharvester
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
├── REPORT.md                      # Complete summary report
├── live_hosts.txt                 # Live host URLs
├── subdomains/
│   ├── subdomains.txt             # All unique subdomains
│   ├── subfinder.txt              # Subfinder results
│   ├── amass.txt                  # Amass results
│   └── assetfinder.txt            # Assetfinder results
├── directories/
│   ├── all_directories.txt        # All discovered paths
│   ├── ferox_*.txt                # Feroxbuster results
│   └── gobuster_*.txt             # Gobuster results
├── wayback/
│   ├── all_urls.txt               # All historical URLs
│   ├── interesting_urls.txt       # Potentially interesting URLs
│   └── sensitive_urls.txt         # Sensitive files & directories
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
  │ URL Harvest │                             │  Dir BruteForce │
  └─────────────┘                             └─────────────────┘
         │                                              │
         ▼                                              ▼
  ┌─────────────┐                             ┌─────────────────┐
  │  Tech Recon │ ◀────────────────────────── │  Vuln Scanning  │
  └─────────────┘                             └─────────────────┘
         │
         ▼
  ┌─────────────┐
  │   REPORT    │
  └─────────────┘
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