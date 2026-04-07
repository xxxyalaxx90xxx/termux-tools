# Security Policy

## 🔐 Supported Versions

| Version | Supported |
| ------- | --------- |
| 4.0.x   | ✅ Yes     |

## 🐛 Reporting a Vulnerability

If you discover a security vulnerability:

1. **DO NOT** open a public issue
2. Email the maintainer directly
3. Include detailed description and steps to reproduce
4. Allow 48 hours for a response

## 🛡️ Security Best Practices

- Never commit sensitive data
- Keep tokens/keys in `.env` files
- Use environment variables for secrets
- Review scripts before running
- Keep Termux and packages updated

## 📝 Security Notes

- Writer Tool stores passwords in `~/.writer_secrets/` with 600 permissions
- Encryption uses AES-256-CBC via OpenSSL
- GitHub tokens are stored securely in `~/.config/gh/hosts.yml`
- SSH keys use ed25519 algorithm
