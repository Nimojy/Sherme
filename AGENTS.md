# Sherme — Agent Instructions

This is the **Sherme** repo: a fully automated, cross-platform reconnaissance
and web vulnerability scanner written as a single portable Bash script.

## What it is

One command turns a domain into a full security report:

```bash
bash sherme.sh -d <domain> -y --json
```

Pipeline (all automatic):
1. Subdomain enumeration — subfinder, amass, assetfinder, sublist3r
2. Live host detection — httpx (curl fallback)
3. Port scanning — naabu
4. Directory / file brute force — feroxbuster, gobuster, ffuf
5. Historical URL harvesting — waybackurls, gau
6. Technology detection — whatweb, nikto, WPScan
7. Vulnerability scanning — nuclei (+ auto template update), dalfox (XSS), crlfuzz (CRLF)
8. Reporting — `REPORT.md` + `SUMMARY.json` + severity breakdown

## Key files

| File | Purpose |
|------|---------|
| `sherme.sh` | The scanner (single executable, bash) |
| `install.sh` | Cross-platform dependency installer (apt/dnf/yum/pacman/zypper/apk/brew/pkg) |
| `opencode.json` | opencode project config (auto-allows sherme.sh execution) |

## Agent conventions

- Canonical invocation: `bash /home/dwoz/sherme/sherme.sh` (or `./sherme.sh` from the repo root).
- Always use `-y` (no prompt) and `--json` when automating; `-p <phase>` to limit scope.
- Phases: `all` (default), `recon`, `vuln`, `subdomains`, `live`, `dirs|directories`, `urls|wayback`, `tech|technology`, `ports`, `info`.
- After a scan, read `SUMMARY.json` first, then `REPORT.md`.

## Findings artifacts

- `<out>/vulnerabilities/vulnerabilities.txt` — parsed findings (`[severity] name @ url (template: id)`)
- `<out>/vulnerabilities/nuclei.jsonl` — raw nuclei JSONL
- `<out>/vulnerabilities/vuln_summary.txt` — severity counts
- `<out>/SUMMARY.json` — machine-readable overall summary

## Rules

- Only scan with authorization. Sherme is for permitted security testing.
- Do not add new tool phases without updating `TOOLS_LIST`, the `--phase`
  parser, the auto-install map, and the report/JSON generators together.
- Keep the script dependency-light and portable (no GNU-only flags).