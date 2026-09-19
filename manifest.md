# Organizational AGENTS.md Manifest

> **Purpose**: Registry of all organizational-level AGENTS.md files that govern multiple repositories or directories.
> 
> **Rule**: Every organizational AGENTS.md MUST be listed here. Every per-repo AGENTS.md MUST reference its governing organizational file.

## Organizational Hierarchy

```
~/Development/Github/AGENTS.md (organization-wide) ← BASE
├── 3d-design/AGENTS.md (team: 3D design)
│   ├── keychains-3d/AGENTS.md
│   ├── spool-holder/AGENTS.md
│   └── gardening-tools/AGENTS.md
├── ansible-collection-setup/AGENTS.md
├── board-games-infra/AGENTS.md
├── detect-technologies/AGENTS.md
├── portainer-homelab-catalog/AGENTS.md
├── release-github/AGENTS.md
└── [future repos...]
```

## Registry

### Level 1: Organization-Wide

| Path | Scope | Repository | Governs |
|------|-------|------------|---------|
| `~/Development/Github/AGENTS.md` | calavia-org | `calavia-org/org-standards` | All repositories under `~/Development/Github/` |
| `org-standards/github-harness/AGENTS.md` | calavia-org | `calavia-org/org-standards` | Source of truth for organization-wide rules |

### Level 2: Team/Domain

| Path | Scope | Team | Governs |
|------|-------|------|---------|
| `~/Development/Github/3d-design/AGENTS.md` | 3D Design | 3D-printing | All repos under `3d-design/` |

### Level 3: Repository-Specific

| Path | Domain | Repository | References |
|------|--------|------------|------------|
| `~/Development/Github/ansible-collection-setup/AGENTS.md` | Ansible | `calavia-org/ansible-collection-setup` | `../AGENTS.md` |
| `~/Development/Github/board-games-infra/AGENTS.md` | Terraform | `calavia-org/board-games-infra` | `../AGENTS.md` |
| `~/Development/Github/detect-technologies/AGENTS.md` | GitHub Action | `calavia-org/detect-technologies` | `../AGENTS.md` |
| `~/Development/Github/portainer-homelab-catalog/AGENTS.md` | Docker/Portainer | `calavia-org/portainer-homelab-catalog` | `../AGENTS.md` |
| `~/Development/Github/release-github/AGENTS.md` | GitHub Action | `calavia-org/release-github` | `../AGENTS.md` |
| `~/Development/Github/3d-design/keychains-3d/AGENTS.md` | OpenSCAD | `calavia-org/keychains-3d` | `../AGENTS.md` |
| `~/Development/Github/3d-design/spool-holder/AGENTS.md` | OpenSCAD | `calavia-org/spool-holder` | `../AGENTS.md` |
| `~/Development/Github/3d-design/gardening-tools/AGENTS.md` | OpenSCAD | `calavia-org/gardening-tools` | `../AGENTS.md` |

## Validation Rules

Every per-repo AGENTS.md MUST:

1. ✅ Include the mandatory read notice referencing its parent AGENTS.md
2. ✅ Not override organization-wide rules (only add project-specific details)
3. ✅ Be listed in this manifest

## Adding New Entries

When creating a new organizational AGENTS.md:

1. Add it to the appropriate table above
2. Update the hierarchy diagram
3. Run `./scripts/verify-agents.sh` to validate
4. Commit with `docs(manifest): add <name> to AGENTS.md registry`

## Checking Consistency

```bash
# Validate all AGENTS.md files are in sync
./scripts/verify-agents.sh ~/Development/Github

# Sync latest standards to local directories
./scripts/sync-to-local.sh ~/Development/Github
```
