# calavia-org Development Harness

> **MANDATORY READ**: This file governs ALL repositories under `~/Development/Github`. Every agent session MUST read this file before starting work in any repository under this directory. Per-repo `AGENTS.md` files provide project-specific details but cannot override these organization-wide constraints.
>
> **Source of Truth**: This file is maintained in [`calavia-org/org-standards`](https://github.com/calavia-org/org-standards). For updates, sync scripts, and the full manifest of organizational AGENTS.md files, see that repository.

## 1. Governance Principles

### 1.1 Pull Request-Only Workflow

**NEVER commit directly to `main`, `master`, or `release/*` branches.**

All changes — including hotfixes, documentation updates, and AGENTS.md changes — MUST go through a Pull Request (PR) with proper review.

| Action | Allowed? |
|--------|----------|
| Direct commit to `main` | ❌ FORBIDDEN |
| Direct commit to `master` | ❌ FORBIDDEN |
| Direct commit to `release/*` | ❌ FORBIDDEN |
| Merge commit (non-squash) | ❌ FORBIDDEN |
| PR with squash merge | ✅ REQUIRED |
| PR with rebase merge | ❌ NOT ALLOWED |
| PR with merge commit | ❌ NOT ALLOWED |

### 1.2 Repository Branch Protection (Mandatory)

Every repository in `calavia-org` MUST have these protection rules on `main` and `master`:

```
✓ Require a pull request before merging
  ✓ Require approvals: minimum 1
  ✓ Dismiss stale PR approvals when new commits are pushed
  ✓ Require review from CODEOWNERS (if configured)

✓ Require status checks to pass before merging
  ✓ Require branches to be up to date before merging

✓ Require linear history (no merge commits)

✓ Require squash merging (ONLY merge method allowed)
  ✗ Allow merge commits: DISABLED
  ✗ Allow rebase merging: DISABLED

✓ Include administrators (rules apply to admins too)

✓ Restrict pushes that create files (optional but recommended)
```

**Action**: If you encounter a repository without these protections, flag it immediately. Do not proceed with work until protections are verified.

## 2. Branch Naming Conventions

Use conventional prefixes to enable automation and clarity:

| Prefix | Purpose | Version Bump |
|--------|---------|--------------|
| `feat/` | New features | Minor (`v1.0.0` → `v1.1.0`) |
| `fix/` | Bug fixes | Patch (`v1.0.0` → `v1.0.1`) |
| `chore/` | Maintenance, CI, docs | None (skip release) |
| `docs/` | Documentation only | None (skip release) |
| `refactor/` | Code restructuring | None (skip release) |
| `test/` | Test additions/changes | None (skip release) |
| `style/` | Formatting changes | None (skip release) |
| `perf/` | Performance improvements | None (skip release) |
| `ci/` | CI/CD changes | None (skip release) |
| `major/` | Breaking changes | Major (`v1.0.0` → `v2.0.0`) |

**Examples**:
- `feat/auth-oauth2`
- `fix/api-null-response`
- `chore/update-dependencies`
- `docs/readme-installation`

## 3. Conventional Commits

All commits MUST follow [Conventional Commits](https://www.conventionalcommits.org/) specification.

### Format

```
type(scope): description

[optional body]

[optional footer(s)]
```

### Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `style`: Formatting, missing semicolons, etc.
- `refactor`: Code change that neither fixes a bug nor adds a feature
- `perf`: Performance improvement
- `test`: Adding or correcting tests
- `chore`: Build process, dependencies, CI/CD
- `ci`: CI/CD changes
- `build`: Build system changes

### Breaking Changes

Mark breaking changes with `!` after type or `BREAKING CHANGE:` in footer:

```
feat(api)!: remove deprecated endpoints

BREAKING CHANGE: v1 endpoints removed. Use v2.
```

## 4. Pull Request Requirements

### 4.1 PR Title Format

PR titles MUST use conventional commit format (they become the squash commit message):

```
type(scope): description
```

**Examples**:
- `feat(auth): add OAuth2 login support`
- `fix(api): handle null response from endpoint`
- `docs(readme): update installation instructions`
- `chore(deps): bump dependencies`

### 4.2 PR Description Template

```markdown
## Summary
Brief description of changes

## Type
- [ ] feat (new feature)
- [ ] fix (bug fix)
- [ ] docs (documentation)
- [ ] chore (maintenance)
- [ ] refactor (code restructuring)
- [ ] test (tests)
- [ ] perf (performance)

## Breaking Changes
- [ ] Yes (explain below)
- [ ] No

## Testing
How was this tested?

## Checklist
- [ ] Branch follows naming convention
- [ ] Commits follow conventional commits
- [ ] PR title follows conventional commit format
- [ ] No direct commits to main/master
```

### 4.3 PR Merge Requirements

Before merging a PR:

1. ✅ All status checks MUST pass
2. ✅ At least 1 approval (from CODEOWNERS if configured)
3. ✅ Branch is up to date with `main`
4. ✅ No merge conflicts
5. ✅ Squash merge is used (ONLY option)

## 5. Reusable Workflows

### 5.1 Central Repository: `workflows-lib`

All CI/CD workflows MUST be sourced from `calavia-org/workflows-lib` when a reusable workflow exists.

**Repository**: `~/Development/Github/workflows-lib` (or `calavia-org/workflows-lib` on GitHub)

**Available Workflows**:

| Workflow | File | Purpose |
|----------|------|---------|
| PR Check & Test | `pr-check-and-test.yml` | Unified PR validation with auto-detection |
| PR Check & Bump | `pr-check-and-bump.yml` | Conventional commit validation + version bump |
| Release Artifacts | `release-artifacts.yml` | Multi-target release (binary, docker, helm) |
| Release GitHub Action | `release-github-action.yml` | Release for composite actions |
| PR Check GitHub Action | `pr-check-github-action.yml` | PR checks for composite actions |

### 5.2 Workflow Usage Rules

1. **Always check `workflows-lib` first** before creating a new workflow
2. **If a reusable workflow exists**, use it via `workflow_call`. Start from
   [`templates/pr-check-and-test.yml.template`](templates/pr-check-and-test.yml.template)
   for `pr-check-and-test.yml`:
   ```yaml
   permissions:
     # Required: the called workflow's pre-release job requests contents: write,
     # and GitHub validates callee job permissions against the caller's grant at
     # startup (before any `if:` is evaluated). `contents: read` => startup_failure.
     contents: write
     checks: write
     pull-requests: write
   jobs:
     pr-check:
       uses: calavia-org/workflows-lib/.github/workflows/pr-check-and-test.yml@v0
       with:
         # `run-tox` defaults to true and fails when there is no tox.ini.
         run-tox: false
       secrets:
         github-token: ${{ secrets.GITHUB_TOKEN }}
   ```
   Two failure modes that do not announce themselves:
   - Omit `contents: write` and every run dies with `startup_failure` (0 jobs,
     instant) even though the workflow file is valid.
   - Leave `run-tox` at its default in a repo without a `tox.ini` and the Tox
     Matrix job fails; `fail-on-missing: false` does not disable it.
3. **If no reusable workflow exists** for your use case:
   - Create it in `workflows-lib` FIRST
   - Use `workflow_call` trigger for reusability
   - Document it in `workflows-lib/README.md`
   - Reference it from your repository
4. **Never duplicate workflow logic** across repositories

### 5.3 Version Pinning

- **Development**: Use floating major version (`@v0`)
- **Production**: Pin to explicit version (`@v0.0.2`)

## 6. Pre-Commit Requirements

All repositories MUST use pre-commit hooks. The canonical configuration lives in [`templates/.pre-commit-config.yaml.template`](templates/.pre-commit-config.yaml.template); copy it verbatim to `.pre-commit-config.yaml` in the repository root.

### 6.1 Required hook set

```yaml
repos:
  # Universal — required in every repository
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.6.0
    hooks:
      - id: check-yaml
      - id: check-merge-conflict
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-added-large-files
      - id: no-commit-to-branch
        args: ['--branch', 'main', '--branch', 'master', '--branch', '/^release\/.+/']

  - repo: https://github.com/compilerla/conventional-pre-commit
    rev: v4.0.0
    hooks:
      - id: conventional-pre-commit
        stages: [commit-msg]
        args: [feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert]

  # Documentation — when the repository contains Markdown
  - repo: https://github.com/igorshubovych/markdownlint-cli
    rev: v0.41.0
    hooks:
      - id: markdownlint
        args: ['--disable', 'MD013', 'MD033', 'MD041']

  # GitHub Actions — when .github/workflows exists
  - repo: https://github.com/rhysd/actionlint
    rev: v1.7.12
    hooks:
      - id: actionlint

  # Python — when the repository contains .py files
  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.11.0
    hooks:
      - id: ruff
        args: [--fix]
      - id: ruff-format
```

**Critical hooks**:
- `no-commit-to-branch`: Prevents direct commits to protected branches
- `conventional-pre-commit`: Enforces conventional commit messages

### 6.2 Coverage rule

Pre-commit MUST actually lint every language present in the repository — it is **not** sufficient to only run the test suite. In particular:

- Markdown (`markdownlint`) whenever the repository contains `.md` files
- Python (`ruff` + `ruff-format`) whenever the repository contains `.py` files
- GitHub Actions (`actionlint`) whenever `.github/workflows` exists

Hooks whose file selectors match nothing are skipped automatically, so the canonical template can be copied verbatim without removing language-specific hooks.

### 6.3 Language-specific extras

Add and configure when applicable (examples in the template, commented out):

- `yamllint` (`adrienverge/yamllint`) for Ansible / YAML-heavy repositories
- `ansible-lint` (`ansible/ansible-lint`) for Ansible roles and collections

## 7. Release Workflow

### 7.1 Version Bumping

- **Automated**: PR merge triggers version bump based on conventional commit type
- **Manual**: Only in exceptional cases, with justification

### 7.2 Release Process

1. PR merged to `main` (squash)
2. CI detects conventional commit type
3. Version bump action calculates new version
4. Release workflow creates tag and release
5. Artifacts published (if configured)

### 7.3 Skip Release

Commits with these types skip automatic release:
- `docs`
- `chore`
- `style`
- `refactor`
- `perf`
- `test`
- `ci`
- `build`

## 8. Per-Repository AGENTS.md

Each repository has its own `AGENTS.md` with project-specific details:

- Technology stack and commands
- Project structure
- Testing procedures
- Linting and formatting
- Environment setup
- Gotchas and special cases

**Hierarchy**:
1. This file (`~/Development/Github/AGENTS.md`) — organization-wide rules
2. Per-repo `AGENTS.md` — project-specific details
3. Per-repo rules CANNOT override organization rules

## 9. Agent Behavior Rules

When working in any `calavia-org` repository:

### 9.1 Before Starting Work

1. Read this file (you are reading it now ✅)
2. Read the per-repo `AGENTS.md`
3. Check current branch (`git branch --show-current`)
4. If on `main`/`master`, create a feature branch immediately

### 9.2 During Work

1. **Never commit to main/master** — create feature branches
2. **Use conventional commits** for all commits
3. **Keep commits atomic** — one logical change per commit
4. **Pair tests with implementation** in same commit
5. **Run pre-commit hooks** before committing

### 9.3 Before Finishing

1. Ensure all commits follow conventional commits
2. Run full test suite
3. Run linting and formatting
4. Push branch and create PR
5. Ensure PR title follows conventional commit format
6. Verify CI passes

### 9.4 Emergency/Hotfix Procedure

Even hotfixes MUST follow PR workflow:

1. Create branch: `fix/critical-hotfix-description`
2. Make minimal fix
3. Create PR with `[HOTFIX]` prefix in title
4. Request expedited review
5. Merge via squash

**NEVER** bypass PR process, even for "urgent" fixes.

## 10. Verification Checklist

Before considering work complete, verify:

- [ ] All changes in a feature branch (not main/master)
- [ ] Branch follows naming convention (`feat/`, `fix/`, `chore/`, etc.)
- [ ] All commits use conventional commit format
- [ ] Pre-commit hooks pass
- [ ] PR created with conventional commit title
- [ ] PR description filled out
- [ ] CI checks pass
- [ ] Squash merge configured as only merge option
- [ ] Branch protection rules verified

## 11. Violations and Escalation

If you encounter any of these situations, STOP and escalate:

1. Repository without branch protection on `main`/`master`
2. Direct commits to protected branches
3. Merge commits in history (non-linear)
4. Missing pre-commit hooks
5. Workflows not using `workflows-lib`
6. PRs without conventional commit titles

**Escalation path**: Document the violation → Notify repository owner → Do not proceed until resolved.

---

**Last Updated**: 2026-10-11
**Applies To**: All repositories under `~/Development/Github`
**Enforced By**: Pre-commit hooks, branch protection, CI checks
