# calavia-org Organization Standards

Central repository for organization-wide development standards, harnesses, and governance rules.

## Structure

```
.
├── github-harness/
│   └── AGENTS.md              # Organization-wide GitHub workflow rules
├── scripts/
│   ├── verify-agents.sh       # Validate local AGENTS.md files are in sync
│   └── sync-to-local.sh       # Sync standards to local development directories
├── templates/
│   └── AGENTS.md.template     # Template for new per-repo AGENTS.md files
├── manifest.md                # Registry of all organizational AGENTS.md locations
└── README.md                  # This file
```

## Usage

### For Development Machines

Run the sync script to install the latest standards:

```bash
./scripts/sync-to-local.sh ~/Development/Github
```

This will:
1. Copy the base `AGENTS.md` to your development directory
2. Verify all per-repo AGENTS.md files reference the base

### For CI/CD

Reference reusable workflows from `calavia-org/workflows-lib`:

```yaml
jobs:
  pr-check:
    uses: calavia-org/workflows-lib/.github/workflows/pr-check-and-test.yml@v0
    secrets:
      github-token: ${{ secrets.GITHUB_TOKEN }}
```

### For New Repositories

1. Copy `templates/AGENTS.md.template` to your new repo
2. Add project-specific details
3. Ensure branch protection rules are configured (see `github-harness/AGENTS.md` Section 1.2)

## Maintenance

When updating organization-wide rules:

1. Edit `github-harness/AGENTS.md` in this repo
2. Open a PR with conventional commit format
3. After merge, run `./scripts/sync-to-local.sh` on development machines
4. Update `manifest.md` if new organizational AGENTS.md locations are added

## Related Repositories

| Repository | Purpose |
|------------|---------|
| `calavia-org/workflows-lib` | Reusable GitHub Actions workflows |
| `calavia-org/release-github` | Semantic versioning and release action |
| `<user>/dotfiles` | Personal development environment configuration |

---

**Last Updated**: 2026-09-19
**Maintained By**: calavia-org
**Enforced By**: Pre-commit hooks, branch protection, CI checks
