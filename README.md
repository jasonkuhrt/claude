# Claude Configuration

Personal Claude AI configuration, conventions, and scripts.

## Structure

- `CLAUDE.md` - Global instructions and conventions for Claude
- `commands/` - Custom slash commands
- `scripts/` - Automation and validation scripts
- `templates/` - Project templates

## Setup

This directory is a git repository that syncs configurations across machines.

```bash
# Clone to new machine
git clone https://github.com/jasonkuhrt/claude.git ~/.claude

# Update from remote
cd ~/.claude && git pull
```

## Custom Commands

- `/fix-conventions` - Check and fix library layout conventions
- `/lint` - Run linting
- `/check` - Run type checks, linting, and tests
- `/ship` - Format, check types, lint, and test
- `/clean-build` - Clean and rebuild project
- `/refresh` - Reinstall dependencies and build

## Library Conventions

Libraries follow a specific structure pattern:

```
src/lib/
  └── <lib-name>/
      ├── $.ts          # Namespace export
      ├── $$.ts         # Barrel export
      ├── *.test.ts     # Tests
      └── *.ts          # Implementation
```

See `CLAUDE.md` for full conventions documentation.