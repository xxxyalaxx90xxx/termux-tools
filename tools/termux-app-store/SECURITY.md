# Security Policy

Security is a core principle of **Termux App Store**.
This project provides tooling and infrastructure used to build and
validate Termux packages, therefore **supply-chain integrity** and
**trust** are critical.

---

## 🔐 Supported Versions

Security fixes apply to:
- The `master` branch
- The latest stable release (if applicable)

Older versions may not receive security updates.

---

## 🚨 Reporting a Vulnerability

**Do NOT report security issues via public GitHub issues.**

If you discover a vulnerability, please report it responsibly.

### 📬 How to Report
Choose one of the following:
- GitHub Security Advisories (preferred)
- Private contact with the project maintainer

Provide as much detail as possible:
- Description of the issue
- Affected components
- Steps to reproduce
- Potential impact
- Suggested mitigation (if any)

---

## ⏱ Response Timeline

We aim to:
- Acknowledge reports within **72 hours**
- Provide an initial assessment within **7 days**
- Release a fix as soon as reasonably possible

Timelines may vary depending on severity.

---

## 🧪 Automated Security Controls

This repository uses:
- Automated CI validation
- Script & build file linting
- Coverage checks for core tooling
- Controlled GitHub Actions workflows

These measures reduce the risk of:
- Malicious packages
- Hidden build behavior
- Supply-chain attacks

---

## 🔍 Scope of Security Issues

### In Scope
- Malicious code submissions
- Build script abuse
- CI pipeline manipulation
- Unauthorized data exfiltration
- Dependency or toolchain vulnerabilities

### Out of Scope
- Vulnerabilities in third-party software packaged by users
- User misconfiguration
- Unsupported forks or modified environments

---

## 🔒 Confidentiality & Disclosure

- All security reports are handled privately
- Public disclosure occurs **only after mitigation**
- Credit will be given to reporters unless anonymity is requested

---

## 🚫 Zero Tolerance Policy

The following will result in immediate action:
- Intentional backdoors
- Crypto miners
- Obfuscated malicious logic
- Supply-chain compromise attempts

Offending contributions will be removed and access revoked.

---

## 🧠 Trust Model

Trust is earned through:
- Transparent contributions
- Reviewable changes
- Automated validation
- Consistent community behavior

Security is everyone's responsibility.

---

## 📜 Policy Changes

This security policy may be updated as the project evolves.

Significant changes will be documented and communicated publicly.

---

## 📌 Final Note

Security policies exist to protect:
- Contributors
- Users
- The broader Termux ecosystem

Responsible disclosure helps everyone.
