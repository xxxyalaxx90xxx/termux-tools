# Governance

This document describes the governance model for **Termux App Store**.
The goal is to ensure transparent decision-making, sustainable
maintenance, and a healthy open-source community.

---

## Project Scope

**Termux App Store** is a community-driven infrastructure project
focused on:
- Building and validating Termux packages
- Providing tooling and CI workflows
- Enabling safe, reproducible, and standardized contributions

This project is **not** a general-purpose application store,
but a **foundation layer** for the Termux ecosystem.

---

## Roles & Responsibilities

### Project Lead
- Defines project vision and direction
- Has final decision authority when consensus cannot be reached
- Oversees releases and major changes

> Current Project Lead: **Djunekz**
> _https://github.com/djunekz_

---

### Maintainers
Maintainers are responsible for:
- Reviewing pull requests
- Enforcing project standards
- Managing CI workflows
- Triaging issues and discussions

Maintainers **do not act unilaterally** on breaking changes.

---

### Contributors
Contributors may:
- Submit pull requests
- Report issues
- Propose features
- Improve documentation

Contributors are expected to follow:
- [CONTRIBUTING](CONTRIBUTING.md)
- [Code of Conduct](CODE_OF_CONDUCT.md)
- Project standards and workflows

---

## Decision-Making Process

### Normal Changes
- Bug fixes
- Package updates
- Documentation changes
- Non-breaking improvements

Reviewed and merged by maintainers.

---

### Significant Changes
- CI architecture changes
- Tooling behavior changes
- Policy updates
- Structural refactors

Require:
1. Issue or discussion
2. Maintainer review
3. Project Lead approval (if needed)

---

### Breaking Changes
Breaking changes **must**:
1. Be proposed via an issue
2. Include a clear rationale
3. Provide migration guidance

Final approval rests with the **Project Lead**.

---

## Package Governance

- Each package must follow Termux packaging standards
- Automated validation is mandatory
- Packages failing CI may be rejected or reverted
- Maintainers may request changes or improvements

Malicious or low-quality packages will be removed immediately.

---

## Security Governance

- Security issues are handled privately
- Public disclosure only after mitigation
- Security policy is defined in [SECURITY](SECURITY.md)

Any contributor violating security trust will be removed.

---

## Community Conduct

All participants must adhere to the [Code of Conduct](CODE_OF_CONDUCT.md).

Harassment, abuse, or hostile behavior will not be tolerated.

Maintainers may take action including:
- Warning
- Temporary restriction
- Permanent ban (for severe cases)

---

## Maintainer Changes

### Adding Maintainers
- Based on consistent, high-quality contributions
- Requires approval from Project Lead

### Removing Maintainers
- Inactivity
- Violation of community rules
- Loss of trust

---

## Governance Changes

This governance model may evolve over time.

Changes to this document require:
- Public discussion
- Maintainer consensus
- Project Lead approval

---

## Community First

This project prioritizes:
- Transparency
- Sustainability
- Collaboration
- Long-term ecosystem health

No single contributor owns the community —
but someone must be responsible for its direction.

---

## Final Note

Governance exists to protect both:
- The **project**
- The **community**

Clear rules enable healthy collaboration.
