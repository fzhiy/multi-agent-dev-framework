# Contributing

Thanks for your interest in contributing to multi-agent-dev-framework!

## How to Contribute

### Reporting Issues

- Use [GitHub Issues](https://github.com/fzhiy/multi-agent-dev-framework/issues) to report bugs or suggest features.
- Include your environment details: OS, Claude Code version, Codex CLI version.
- For bugs, describe the expected vs actual behavior.

### Pull Requests

1. Fork the repository.
2. Create a feature branch: `git checkout -b feature/your-feature`.
3. Make your changes and commit with a clear message.
4. Push to your fork and open a Pull Request.

### What to Contribute

This is a configuration-based framework, so contributions typically involve:

- **Agent configs** (`.codex/agents/*.toml`) -- new specialized subagent roles
- **Skills** (`.codex/skills/`) -- new Codex skills for common workflows
- **Documentation** -- improvements, translations, usage examples
- **Workflow patterns** -- real-world usage patterns and best practices

### Guidelines

- Keep changes minimal and focused.
- Test your agent configs in a real project before submitting.
- Follow existing naming conventions and file structure.
- New external skills must pass the review policy in `docs/skills/external-skill-review.md`.

## Code of Conduct

Be respectful and constructive. We're all here to build better tools.

## License

By contributing, you agree that your contributions will be licensed under the [MIT License](LICENSE).
