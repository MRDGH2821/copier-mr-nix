# Mise ↔ Nix Personal Template Config Sync Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Surgically align shared lint/format/CI policy files between personal Copier templates `copier-mr-mise` and `copier-mr-nix` so MegaLinter is v10.0.0 everywhere, mega-linter config is the union of mise richness and the nix DISABLE list, prettier/yamlfix/ls-lint match, and CLAUDE.md is excluded when `use_agents` is false — without pushing.

**Architecture:** Work repo-by-repo on branch `mihir/chore/config-sync`. Within each repo, keep root and `template/` byte-identical for every shared policy file touched. Prefer copy/overwrite of full target contents over piecemeal diffs. Cross-check siblings with relative paths (`../copier-mr-mise`, `../copier-mr-nix`). Log each commit in `.agents/logs/2026-09-05.md`. Do not push.

**Tech Stack:** Copier templates, MegaLinter v10.0.0 (GH SHA `15e5b45552097e318c93de385779ce3b1084052c`), Prettier, yamlfix (`.yamlfix.toml`), ls-lint, GitHub Actions, GitLab CI, apm, git.

## Global Constraints

- Scope: **only** `copier-mr-mise` and `copier-mr-nix` (personal templates).
- Surgical align only — do not refactor unrelated tooling (mise vs nix runtimes stay distinct).
- MegaLinter **v10.0.0** everywhere it appears (GH `uses:` pin, GL image tags, docs, apm `ref`).
- GH pin SHA for v10.0.0: `15e5b45552097e318c93de385779ce3b1084052c`.
- Merged `.mega-linter.yml` = mise PRE_COMMANDS + kingfisher + `node_modules` excludes + nix full DISABLE keep-sorted list + zizmor `GITHUB_TOKEN`.
- ls-lint: `.ts` / `.d.ts` → **kebab-case** (and fix header comment to match).
- prettier: mise options (`singleQuote: false`) into nix.
- yamlfix: mise options (`preserve_quotes`, `quote_representation`) into nix. Filename is **`.yamlfix.toml`** (not yamlfmt).
- `CLAUDE.md` exclude when `not use_agents` in **both** `copier.yml` files; **lic-cli** stays on both.
- Update **root and `template/` together** for every shared policy file.
- Branch: `mihir/chore/config-sync` in each repo.
- Every AI commit trailer: `Co-authored-by: Grok via Grok Bot <noreply@x.ai>`.
- Session log: `.agents/logs/2026-09-05.md` (create if missing).
- Sibling diffs: relative paths only (e.g. `diff -u ../copier-mr-mise/.prettierrc.json .prettierrc.json`).
- **Do not push.**

---

### File map (what changes where)

| File                                                   |              copier-mr-mise               |           copier-mr-nix            |
| ------------------------------------------------------ | :---------------------------------------: | :--------------------------------: |
| `.mega-linter.yml` (root + template/)                  | merge DISABLE list into existing richness |      adopt full merged target      |
| `.ls-lint.yml` (root + template/)                      |  comment fix only (rules already kebab)   |  `.ts`/`.d.ts` → kebab + comment   |
| `.prettierrc.json` (root + template/)                  |        no change (already correct)        |      add `singleQuote: false`      |
| `.yamlfix.toml` (root + template/)                     |        no change (already correct)        |         add quote options          |
| `copier.yml`                                           |           add CLAUDE.md exclude           | already has exclude; leave lic-cli |
| `template/.gitlab-ci.yml`                              |          image v9.6.0 → v10.0.0           |        n/a (GL already v10)        |
| `AGENTS.md` (+ template if present)                    |  v9.6.0 → v10.0.0 in MegaLinter doc line  |       only if v9 refs remain       |
| `.github/workflows/mega-linter.yml` (root + template/) |              already v10 SHA              |           pin to v10 SHA           |
| `apm.yml`                                              |          already `ref: v10.0.0`           |   `ref: 10.0.0` → `ref: v10.0.0`   |
| `.agents/logs/2026-09-05.md`                           |                  append                   |               append               |

---

### Task 1: copier-mr-mise — mega-linter merge, GL/AGENTS v10, CLAUDE exclude, ls-lint comment

**Files:**

- Modify: `.mega-linter.yml`
- Modify: `template/.mega-linter.yml` (must match root)
- Modify: `.ls-lint.yml`
- Modify: `template/.ls-lint.yml` (must match root)
- Modify: `copier.yml`
- Modify: `template/.gitlab-ci.yml`
- Modify: `AGENTS.md`
- Modify: `template/AGENTS.md` (if it also mentions MegaLinter v9.6.0)
- Create/Append: `.agents/logs/2026-09-05.md`

**Interfaces:**

- Consumes: decided merged mega-linter target; nix DISABLE keep-sorted list of 5.
- Produces: mise repo on `mihir/chore/config-sync` with merged `.mega-linter.yml`, v10 GL/docs, CLAUDE exclude, corrected ls-lint comment; sibling-ready configs for Tasks 2–4.

- [ ] **Step 1: Create branch**

```bash
cd copier-mr-mise
git fetch origin
git checkout -B mihir/chore/config-sync
```

Expected: on branch `mihir/chore/config-sync`.

- [ ] **Step 2: Write merged `.mega-linter.yml` (root)**

Overwrite `.mega-linter.yml` with the full merged target (union of current mise richness + nix DISABLE list):

```yaml
---
# all, none, or list of linter keys
ACTION_ZIZMOR_UNSECURED_ENV_VARIABLES:
  - GITHUB_TOKEN
ADDITIONAL_EXCLUDED_DIRECTORIES:
  - apm_modules
  - node_modules
APPLY_FIXES: all
CLEAR_REPORT_FOLDER: true
DISABLE_LINTERS:
  # keep-sorted start
  - JAVASCRIPT_STANDARD
  - MARKDOWN_MARKDOWNLINT
  - PYTHON_BLACK
  - REPOSITORY_DEVSKIM
  - TYPESCRIPT_STANDARD
  # keep-sorted end
IGNORE_GITIGNORED_FILES: true
JAVASCRIPT_DEFAULT_STYLE: prettier
JSON_PRETTIER_PRE_COMMANDS:
  - command: npm i -g bun
    continue_if_failed: false
    cwd: workspace
    secured_env: true
    tag: default
  - command: bun ci
    continue_if_failed: true
    cwd: workspace
    secured_env: true
    tag: default
MARKDOWN_DEFAULT_STYLE: rumdl
PYTHON_DEFAULT_STYLE: ruff
REPOSITORY_KINGFISHER_ARGUMENTS: --exclude node_modules --exclude apm_modules
SHOW_ELAPSED_TIME: true
TYPESCRIPT_DEFAULT_STYLE: prettier
YAML_PRETTIER_PRE_COMMANDS:
  - command: npm i -g bun
    continue_if_failed: false
    cwd: workspace
    secured_env: true
    tag: default
  - command: bun ci
    continue_if_failed: true
    cwd: workspace
    secured_env: true
    tag: default
```

- [ ] **Step 3: Mirror to template/**

```bash
cp -f .mega-linter.yml template/.mega-linter.yml
cmp .mega-linter.yml template/.mega-linter.yml
```

Expected: `cmp` silent (identical).

- [ ] **Step 4: Fix `.ls-lint.yml` header comment (rules already kebab)**

Overwrite `.ls-lint.yml` (and then `template/.ls-lint.yml`) so the TypeScript comment matches kebab-case rules:

```yaml
---
# .ls-lint.yml
# File naming conventions based on official/authoritative style guides:
#   Nix        → kebab-case   (nixpkgs coding conventions)
#   Rust       → snake_case   (Rust RFC 430 / API Guidelines)
#   Python     → snake_case   (PEP 8)
#   JavaScript → kebab-case   (eslint-plugin-unicorn default)
#   TypeScript → kebab-case   (align with JavaScript / eslint-plugin-unicorn)
#   Java       → PascalCase   (Oracle Code Conventions — must match class name)
# ── Ignored paths ─────────────────────────────────────────────────────────
ignore:
  # keep-sorted start
  - .git
  - .gradle
  - .pytest_cache
  - .venv
  - __pycache__
  - apm_modules
  - build
  - dist
  - node_modules
  - result # Nix build result symlink
  - target # Rust/Java build output
  - venv
  # keep-sorted end
ls:
  .cjs: kebab-case
  .d.ts: kebab-case
  .java: PascalCase
  .js: kebab-case
  .mjs: kebab-case
  .nix: kebab-case
  .py: snake_case
  .rs: snake_case
  .ts: kebab-case
```

```bash
cp -f .ls-lint.yml template/.ls-lint.yml
cmp .ls-lint.yml template/.ls-lint.yml
```

- [ ] **Step 5: Add CLAUDE.md exclude to `copier.yml` (keep lic-cli)**

In `copier.yml` `_exclude`, add the following line next to the existing AGENTS.md exclude (alphabetically after AGENTS.md):

```yaml
- "{% if not use_agents %}CLAUDE.md{% endif %}"
```

Target `_exclude` / `_tasks` region after edit (lic-cli task unchanged):

```yaml
_exclude:
  - "*.py[co]"
  - "{% if ci != 'github' %}.github{% endif %}"
  - "{% if ci != 'gitlab' %}.gitlab-ci.yml{% endif %}"
  - "{% if not use_agents %}AGENTS.md{% endif %}"
  - "{% if not use_agents %}CLAUDE.md{% endif %}"
  - "{% if not use_skills %}.agents/skills{% endif %}"
  - "{% if not use_skills %}apm.yml{% endif %}"
  - .DS_Store
  - .git
  - .pre-commit-config-copier.yaml
  - .svn
  - __pycache__
  - copier.yaml
  - copier.yml
  - megalinter-reports
  - ~*
_tasks:
  - command: command -v mise > /dev/null 2>&1 && echo "✓ mise is installed" || echo "✗ mise not found! Please install from here - https://mise.jdx.dev/"
    when: "{{ _copier_operation == 'copy' }}"
  - command: uvx --from lic-cli lic
    when: "{{ _copier_operation == 'copy' }}"
```

Verify:

```bash
rg -n 'CLAUDE\.md|lic-cli' copier.yml
```

Expected: one CLAUDE.md exclude gated on `not use_agents`; `uvx --from lic-cli lic` still present.

- [ ] **Step 6: Bump GitLab MegaLinter image to v10.0.0**

In `template/.gitlab-ci.yml`, change:

```yaml
image: ghcr.io/oxsecurity/megalinter:v9.6.0
```

to:

```yaml
image: ghcr.io/oxsecurity/megalinter:v10.0.0
```

```bash
rg -n 'megalinter' template/.gitlab-ci.yml
```

Expected: `v10.0.0` only; no `v9.6.0`.

- [ ] **Step 7: Bump AGENTS.md MegaLinter doc string to v10.0.0**

Replace any `(CI: oxsecurity/megalinter v9.6.0)` with `(CI: oxsecurity/megalinter v10.0.0)` in `AGENTS.md` and `template/AGENTS.md` if present.

```bash
rg -n 'megalinter' AGENTS.md template/AGENTS.md 2>/dev/null || rg -n 'megalinter' AGENTS.md
```

Expected: no `v9.6.0` left in those files.

- [ ] **Step 8: Confirm GH workflow already on v10 SHA (no edit if already correct)**

```bash
rg -n 'oxsecurity/megalinter@' .github/workflows/mega-linter.yml template/.github/workflows/mega-linter.yml
```

Expected both:

```text
uses: oxsecurity/megalinter@15e5b45552097e318c93de385779ce3b1084052c # v10.0.0
```

If either still has another SHA, set it to that exact line.

- [ ] **Step 9: Verify mise policy files**

```bash
rg -n 'DISABLE_LINTERS|PRE_COMMANDS|KINGFISHER|node_modules|ZIZMOR' .mega-linter.yml
cmp .mega-linter.yml template/.mega-linter.yml
rg -n 'v9\.6\.0' template/.gitlab-ci.yml AGENTS.md template/AGENTS.md 2>/dev/null || true
rg -n 'singleQuote' .prettierrc.json
rg -n 'preserve_quotes|quote_representation' .yamlfix.toml
rg -n 'TypeScript|\.ts:|\.d\.ts:' .ls-lint.yml
```

Expected: DISABLE has 5 keep-sorted entries; PRE_COMMANDS + kingfisher + node_modules present; no v9.6.0 in GL/AGENTS; prettier `singleQuote: false`; yamlfix quote options present; TypeScript comment says kebab-case; `.ts`/`.d.ts` kebab-case.

- [ ] **Step 10: Log + commit (mise Task 1)**

Append to `.agents/logs/2026-09-05.md` (create with `# 2026-09-05` header if missing):

```markdown
## copier-mr-mise — config sync (mega-linter merge, v10 GL/AGENTS, CLAUDE exclude)

- Merged `.mega-linter.yml`: mise PRE_COMMANDS/kingfisher/excludes + nix DISABLE keep-sorted list + zizmor GITHUB_TOKEN
- Mirrored root ↔ template for `.mega-linter.yml` and `.ls-lint.yml`
- Fixed ls-lint TypeScript header comment to kebab-case
- Added `CLAUDE.md` exclude when `not use_agents`; kept lic-cli task
- Bumped `template/.gitlab-ci.yml` MegaLinter image and AGENTS.md docs to v10.0.0
- Confirmed GH workflows already on SHA 15e5b455… # v10.0.0
- Branch: mihir/chore/config-sync (not pushed)
```

Write `/tmp/commitmsg-mise-t1.txt`:

```text
chore: align mega-linter merge, v10 pins, CLAUDE exclude

Union mise MegaLinter richness with the shared DISABLE keep-sorted
list, bump GitLab/AGENTS to v10.0.0, exclude CLAUDE.md when
use_agents is false, and fix the ls-lint TypeScript comment.

Co-authored-by: Grok via Grok Bot <noreply@x.ai>
```

```bash
mkdir -p .agents/logs
git add .mega-linter.yml template/.mega-linter.yml \
  .ls-lint.yml template/.ls-lint.yml \
  copier.yml \
  template/.gitlab-ci.yml \
  AGENTS.md \
  .agents/logs/2026-09-05.md
git add template/AGENTS.md 2>/dev/null || true
git commit -F /tmp/commitmsg-mise-t1.txt
```

Expected: commit succeeds; `git status` clean for these paths; branch not pushed.

---

### Task 2: copier-mr-nix — prettier / yamlfix / ls-lint align

**Files:**

- Modify: `.prettierrc.json`
- Modify: `template/.prettierrc.json`
- Modify: `.yamlfix.toml`
- Modify: `template/.yamlfix.toml`
- Modify: `.ls-lint.yml`
- Modify: `template/.ls-lint.yml`
- Create/Append: `.agents/logs/2026-09-05.md`

**Interfaces:**

- Consumes: mise canonical prettier / yamlfix / ls-lint from Task 1 / current mise.
- Produces: nix smaller policy files byte-matching mise (comment + kebab rules).

- [ ] **Step 1: Create branch**

```bash
cd ../copier-mr-nix
git fetch origin
git checkout -B mihir/chore/config-sync
```

- [ ] **Step 2: Write `.prettierrc.json` (mise options)**

Overwrite root `.prettierrc.json`:

```json
{
  "overrides": [
    {
      "files": ["*.jsonc", "*.json"],
      "options": {
        "parser": "json",
        "trailingComma": "none"
      }
    }
  ],
  "singleQuote": false,
  "tabWidth": 2,
  "trailingComma": "none",
  "useTabs": false
}
```

```bash
cp -f .prettierrc.json template/.prettierrc.json
cmp .prettierrc.json template/.prettierrc.json
diff -u ../copier-mr-mise/.prettierrc.json .prettierrc.json
```

Expected: both `cmp` and sibling `diff` silent.

- [ ] **Step 3: Write `.yamlfix.toml` (mise quote options)**

Overwrite root `.yamlfix.toml` (filename is **`.yamlfix.toml`**, not yamlfmt):

```toml
comments_min_spaces_from_content = 1
line_length = 800
preserve_quotes = true
quote_representation = '"'
sequence_style = "block_style"
```

```bash
cp -f .yamlfix.toml template/.yamlfix.toml
cmp .yamlfix.toml template/.yamlfix.toml
diff -u ../copier-mr-mise/.yamlfix.toml .yamlfix.toml
```

Expected: identical to mise.

- [ ] **Step 4: Write `.ls-lint.yml` (kebab `.ts`/`.d.ts` + matching comment)**

Overwrite root `.ls-lint.yml` with the same full contents as mise Task 1 Step 4 (kebab `.ts`/`.d.ts`, TypeScript comment kebab-case):

```yaml
---
# .ls-lint.yml
# File naming conventions based on official/authoritative style guides:
#   Nix        → kebab-case   (nixpkgs coding conventions)
#   Rust       → snake_case   (Rust RFC 430 / API Guidelines)
#   Python     → snake_case   (PEP 8)
#   JavaScript → kebab-case   (eslint-plugin-unicorn default)
#   TypeScript → kebab-case   (align with JavaScript / eslint-plugin-unicorn)
#   Java       → PascalCase   (Oracle Code Conventions — must match class name)
# ── Ignored paths ─────────────────────────────────────────────────────────
ignore:
  # keep-sorted start
  - .git
  - .gradle
  - .pytest_cache
  - .venv
  - __pycache__
  - apm_modules
  - build
  - dist
  - node_modules
  - result # Nix build result symlink
  - target # Rust/Java build output
  - venv
  # keep-sorted end
ls:
  .cjs: kebab-case
  .d.ts: kebab-case
  .java: PascalCase
  .js: kebab-case
  .mjs: kebab-case
  .nix: kebab-case
  .py: snake_case
  .rs: snake_case
  .ts: kebab-case
```

```bash
cp -f .ls-lint.yml template/.ls-lint.yml
cmp .ls-lint.yml template/.ls-lint.yml
diff -u ../copier-mr-mise/.ls-lint.yml .ls-lint.yml
```

Expected: identical to mise; no `snake_case` on `.ts` / `.d.ts`.

- [ ] **Step 5: Verify**

```bash
rg -n 'singleQuote' .prettierrc.json template/.prettierrc.json
rg -n 'preserve_quotes|quote_representation' .yamlfix.toml template/.yamlfix.toml
rg -n '\.ts:|\.d\.ts:|TypeScript' .ls-lint.yml
ls .yamlfmt.toml template/.yamlfmt.toml 2>&1 || true
```

Expected: prettier/yamlfix options present; `.ts`/`.d.ts` kebab-case; no `.yamlfmt.toml` files.

- [ ] **Step 6: Log + commit (nix Task 2)**

Append to `.agents/logs/2026-09-05.md`:

```markdown
## copier-mr-nix — prettier / yamlfix / ls-lint align

- Adopted mise `.prettierrc.json` (`singleQuote: false`)
- Adopted mise `.yamlfix.toml` (`preserve_quotes`, `quote_representation`)
- Aligned `.ls-lint.yml` `.ts`/`.d.ts` to kebab-case + comment
- Mirrored root ↔ template for all three
- Branch: mihir/chore/config-sync (not pushed)
```

Write `/tmp/commitmsg-nix-t2.txt`:

```text
chore: align prettier, yamlfix, and ls-lint with mise

Bring nix personal template format/naming policy in line with
copier-mr-mise (singleQuote, yamlfix quotes, kebab .ts/.d.ts).

Co-authored-by: Grok via Grok Bot <noreply@x.ai>
```

```bash
mkdir -p .agents/logs
git add .prettierrc.json template/.prettierrc.json \
  .yamlfix.toml template/.yamlfix.toml \
  .ls-lint.yml template/.ls-lint.yml \
  .agents/logs/2026-09-05.md
git commit -F /tmp/commitmsg-nix-t2.txt
```

---

### Task 3: copier-mr-nix — mega-linter merge + GH pin + apm ref

**Files:**

- Modify: `.mega-linter.yml`
- Modify: `template/.mega-linter.yml`
- Modify: `.github/workflows/mega-linter.yml`
- Modify: `template/.github/workflows/mega-linter.yml`
- Modify: `apm.yml`
- Create/Append: `.agents/logs/2026-09-05.md`

**Interfaces:**

- Consumes: merged mega-linter target from Task 1; GH SHA `15e5b45552097e318c93de385779ce3b1084052c`.
- Produces: nix MegaLinter config + GH/apm pins matching mise v10.

Stay on branch `mihir/chore/config-sync` from Task 2.

- [ ] **Step 1: Write merged `.mega-linter.yml`**

Overwrite root `.mega-linter.yml` with the **same full merged target** as Task 1 Step 2 (zizmor GITHUB_TOKEN, apm_modules + node_modules excludes, full DISABLE keep-sorted list, JSON/YAML PRE_COMMANDS, kingfisher args, default styles):

```yaml
---
# all, none, or list of linter keys
ACTION_ZIZMOR_UNSECURED_ENV_VARIABLES:
  - GITHUB_TOKEN
ADDITIONAL_EXCLUDED_DIRECTORIES:
  - apm_modules
  - node_modules
APPLY_FIXES: all
CLEAR_REPORT_FOLDER: true
DISABLE_LINTERS:
  # keep-sorted start
  - JAVASCRIPT_STANDARD
  - MARKDOWN_MARKDOWNLINT
  - PYTHON_BLACK
  - REPOSITORY_DEVSKIM
  - TYPESCRIPT_STANDARD
  # keep-sorted end
IGNORE_GITIGNORED_FILES: true
JAVASCRIPT_DEFAULT_STYLE: prettier
JSON_PRETTIER_PRE_COMMANDS:
  - command: npm i -g bun
    continue_if_failed: false
    cwd: workspace
    secured_env: true
    tag: default
  - command: bun ci
    continue_if_failed: true
    cwd: workspace
    secured_env: true
    tag: default
MARKDOWN_DEFAULT_STYLE: rumdl
PYTHON_DEFAULT_STYLE: ruff
REPOSITORY_KINGFISHER_ARGUMENTS: --exclude node_modules --exclude apm_modules
SHOW_ELAPSED_TIME: true
TYPESCRIPT_DEFAULT_STYLE: prettier
YAML_PRETTIER_PRE_COMMANDS:
  - command: npm i -g bun
    continue_if_failed: false
    cwd: workspace
    secured_env: true
    tag: default
  - command: bun ci
    continue_if_failed: true
    cwd: workspace
    secured_env: true
    tag: default
```

```bash
cp -f .mega-linter.yml template/.mega-linter.yml
cmp .mega-linter.yml template/.mega-linter.yml
diff -u ../copier-mr-mise/.mega-linter.yml .mega-linter.yml
```

Expected: identical to mise after Task 1.

- [ ] **Step 2: Pin GitHub MegaLinter workflows to v10 SHA**

In both `.github/workflows/mega-linter.yml` and `template/.github/workflows/mega-linter.yml`, replace the `uses:` pin line with:

```yaml
uses: oxsecurity/megalinter@15e5b45552097e318c93de385779ce3b1084052c # v10.0.0
```

(Replace any `ef3e84b8b836d76db562d0f3ed7da61e8fd538bc # v9.6.0` or other SHA.)

```bash
rg -n 'oxsecurity/megalinter@' .github/workflows/mega-linter.yml template/.github/workflows/mega-linter.yml
```

Expected: both files show `15e5b45552097e318c93de385779ce3b1084052c # v10.0.0` only.

- [ ] **Step 3: Fix apm.yml ref to `v10.0.0`**

In `apm.yml`, change:

```yaml
ref: 10.0.0
```

to:

```yaml
ref: v10.0.0
```

for the `oxsecurity/megalinter` git dependency (keep surrounding structure).

```bash
rg -n 'megalinter|ref:' apm.yml
```

Expected: `ref: v10.0.0` (with the `v` prefix), matching `../copier-mr-mise/apm.yml`.

Confirm GitLab workflow already on v10 (no change expected):

```bash
rg -n 'megalinter' template/.gitlab/workflows/megalinter.yml
```

Expected: `image: ghcr.io/oxsecurity/megalinter:v10.0.0`.

Confirm `copier.yml` still has CLAUDE exclude + lic-cli (no edit):

```bash
rg -n 'CLAUDE\.md|lic-cli' copier.yml
```

Expected: both present.

- [ ] **Step 4: Verify**

```bash
rg -n 'v9\.6\.0|ef3e84b8' .github/workflows/mega-linter.yml template/.github/workflows/mega-linter.yml apm.yml .mega-linter.yml || true
diff -u ../copier-mr-mise/.mega-linter.yml .mega-linter.yml
cmp .mega-linter.yml template/.mega-linter.yml
```

Expected: no v9.6.0 / old SHA in those files; mega-linter diffs silent vs mise.

- [ ] **Step 5: Log + commit (nix Task 3)**

Append to `.agents/logs/2026-09-05.md`:

```markdown
## copier-mr-nix — mega-linter merge + GH/apm v10

- Wrote merged `.mega-linter.yml` (mise richness + DISABLE list + zizmor); mirrored to template/
- Pinned GH workflows to 15e5b455… # v10.0.0 (root + template)
- Set apm.yml megalinter ref to v10.0.0
- Confirmed GL workflow already v10.0.0; CLAUDE exclude + lic-cli unchanged
- Branch: mihir/chore/config-sync (not pushed)
```

Write `/tmp/commitmsg-nix-t3.txt`:

```text
chore: merge mega-linter config and pin MegaLinter v10

Adopt the shared mega-linter union config, pin GitHub Actions to
v10.0.0 (15e5b455…), and normalize apm megalinter ref to v10.0.0.

Co-authored-by: Grok via Grok Bot <noreply@x.ai>
```

```bash
git add .mega-linter.yml template/.mega-linter.yml \
  .github/workflows/mega-linter.yml \
  template/.github/workflows/mega-linter.yml \
  apm.yml \
  .agents/logs/2026-09-05.md
git commit -F /tmp/commitmsg-nix-t3.txt
```

---

### Task 4: Cross-repo verification (do not push)

**Files:**

- Read-only verification across `../copier-mr-mise` and `../copier-mr-nix`
- Optional append: each repo’s `.agents/logs/2026-09-05.md` with verification notes

**Interfaces:**

- Consumes: Tasks 1–3 commits on `mihir/chore/config-sync`.
- Produces: confirmation that policy surfaces match; no push.

- [ ] **Step 1: Byte-identical shared policy files**

From `copier-mr-nix` (sibling of mise):

```bash
for f in .mega-linter.yml .prettierrc.json .yamlfix.toml .ls-lint.yml; do
  echo "=== $f ==="
  diff -u ../copier-mr-mise/$f $f && echo OK
  cmp ../copier-mr-mise/$f ../copier-mr-mise/template/$f && echo "mise root=template OK"
  cmp $f template/$f && echo "nix root=template OK"
done
```

Expected: all diffs silent; root=template in both repos.

- [ ] **Step 2: MegaLinter version matrix**

```bash
echo '--- mise ---'
rg -n 'oxsecurity/megalinter@|megalinter:v|megalinter v|ref:.*10' \
  ../copier-mr-mise/.github/workflows/mega-linter.yml \
  ../copier-mr-mise/template/.github/workflows/mega-linter.yml \
  ../copier-mr-mise/template/.gitlab-ci.yml \
  ../copier-mr-mise/apm.yml \
  ../copier-mr-mise/AGENTS.md

echo '--- nix ---'
rg -n 'oxsecurity/megalinter@|megalinter:v|megalinter v|ref:.*10' \
  .github/workflows/mega-linter.yml \
  template/.github/workflows/mega-linter.yml \
  template/.gitlab/workflows/megalinter.yml \
  apm.yml
```

Expected:

- GH `uses:` → `15e5b45552097e318c93de385779ce3b1084052c # v10.0.0` in both repos (root + template).
- GL images → `v10.0.0` (mise `template/.gitlab-ci.yml`; nix `template/.gitlab/workflows/megalinter.yml`).
- apm `ref: v10.0.0` in both.
- **No** `v9.6.0` / `ef3e84b8` remaining in those surfaces.
- mise AGENTS.md documents v10.0.0.

- [ ] **Step 3: CLAUDE exclude + lic-cli on both**

```bash
rg -n 'CLAUDE\.md|lic-cli' ../copier-mr-mise/copier.yml ../copier-mr-nix/copier.yml
```

Expected: both have `{% if not use_agents %}CLAUDE.md{% endif %}` and `uvx --from lic-cli lic`.

- [ ] **Step 4: Filename sanity**

```bash
ls ../copier-mr-mise/.yamlfix.toml ../copier-mr-nix/.yamlfix.toml
ls ../copier-mr-mise/.yamlfmt.toml ../copier-mr-nix/.yamlfmt.toml 2>&1 || true
```

Expected: `.yamlfix.toml` exists; `.yamlfmt.toml` does not.

- [ ] **Step 5: Branch / push guard**

```bash
git -C ../copier-mr-mise branch --show-current
git -C ../copier-mr-nix branch --show-current
git -C ../copier-mr-mise status -sb
git -C ../copier-mr-nix status -sb
```

Expected: both on `mihir/chore/config-sync`; working trees clean; **do not** `git push`.

- [ ] **Step 6: Optional verification log note**

Append to each repo’s `.agents/logs/2026-09-05.md`:

```markdown
## cross-repo verification

- Shared policy files identical between ../copier-mr-mise and ../copier-mr-nix
- MegaLinter v10.0.0 / SHA 15e5b455… everywhere in scope
- CLAUDE.md exclude + lic-cli present on both copier.yml
- Not pushed
```

If the log is dirty after the last feature commit, write `/tmp/commitmsg-verify.txt`:

```text
docs: record cross-repo config-sync verification

Co-authored-by: Grok via Grok Bot <noreply@x.ai>
```

Then per repo if needed: `git add .agents/logs/2026-09-05.md && git commit -F /tmp/commitmsg-verify.txt`

**Still do not push.**

---

## Self-review checklist

1. Spec coverage: Tasks 1–4 cover merge mega-linter, v10 everywhere, kebab ls-lint, mise prettier/yamlfix into nix, CLAUDE exclude both, lic-cli both, root+template, branch, Co-authored-by, logs, no push.
2. No placeholders / TBD.
3. Filename `.yamlfix.toml` used throughout.
4. Sibling paths are relative (`../copier-mr-*`) only.
