# Contributing to Termux Tools

Thank you for your interest in contributing!

## 🐛 Bug Reports

Please include:
- Termux version (`pkg --version`)
- Android version
- Steps to reproduce
- Expected vs actual behavior

## ✨ Feature Requests

- Describe the feature clearly
- Explain why it would be useful
- Consider if it fits the project scope

## 🔧 Pull Requests

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Test your changes
4. Commit with clear messages (`git commit -m 'Add amazing feature'`)
5. Push to your fork (`git push origin feature/amazing-feature`)
6. Open a Pull Request

## 📝 Code Style

- Shell scripts: Use `shellcheck` for linting
- Python: Follow PEP 8
- Comments: Explain WHY, not WHAT
- Functions: Keep them small and focused

## 🧪 Testing

Before submitting:
```bash
# Test shell scripts
shellcheck *.sh

# Test Python
python3 -m py_compile *.py
```

## 📖 Documentation

- Update README.md if adding features
- Add inline documentation for complex logic
- Keep the help text up to date

## 🚀 Release Process

1. Update version in relevant files
2. Update CHANGELOG.md
3. Tag the release
4. Push tags

---

Thank you for contributing! 🎉
