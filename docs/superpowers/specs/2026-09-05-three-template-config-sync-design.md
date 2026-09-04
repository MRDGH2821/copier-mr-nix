# Design Document: Synchronise copier-mr-mise and copier-mr-nix policy configs

## Overview

Align shared Copier-template policy configs between the personal **mise** and **nix** templates so lint/CI defaults match where intended, without collapsing the intentional product fork (mise + hk vs Nix flake).

| Template       | Role                                           |
| -------------- | ---------------------------------------------- |
| copier-mr-mise | Personal; mise + hk; dual CI (GitHub / GitLab) |
| copier-mr-nix  | Personal; Nix flake; dual CI (GitHub / GitLab) |

**Approach:** surgical align — apply decided deltas per repo (independent change sets). No shared config pack or submodule in this pass.

**Decision rule:** no hierarchy. Winners were chosen file-by-file in brainstorming (recorded below). Within a single repo, when root dogfood configs and `template/` drift on shared policy files, **root wins** and `template/` is updated to match (jinja/host-aware).

Spec home: `docs/superpowers/specs/` in copier-mr-nix. Implementation touches both personal templates listed above.

## Goals

1. Remove unintentional policy drift (versions, naming rules, formatter options, MegaLinter config, CLAUDE.md handling, known template bugs).
2. Preserve the intentional product fork (mise + hk vs Nix flake) and per-host CI surfaces.
3. Keep each repo independently reviewable and releasable.

## Non-goals

- Introducing a shared config submodule/include pack
- Adding editorconfig, renovate/dependabot, CONTRIBUTING, just/Makefile, or ruff configs
- Replacing mise + hk with Nix (or vice versa)
- Unifying remotes, cog owner fields, GPG identity, or README install URLs beyond what each personal template already uses
- Full bake-test of every generated project unless a change looks risky
- Documenting or coupling this public design to any private/org templates

## Decided alignments

| Concern                 | Decision                                                                                        |
| ----------------------- | ----------------------------------------------------------------------------------------------- |
| MegaLinter version      | Pin **v10.0.0** everywhere it appears (GitHub actions and GitLab images/jobs)                   |
| MegaLinter config       | **Merge** (union of mise richness and nix settings), adapted per CI host                        |
| ls-lint `.ts` / `.d.ts` | **kebab-case** in both                                                                          |
| prettier + yamlfmt      | Adopt **mise** options into nix                                                                 |
| Root vs `template/`     | **Root wins**, then refresh `template/`                                                         |
| CLAUDE.md               | Present in both **with exclusion rules** when agents are off (match nix’s pattern; add to mise) |
| lic-cli post-copy       | Keep on **both** personal templates                                                             |
| Cross-repo hierarchy    | None — apply the table above, not “repo X is canonical”                                         |

## Architecture (work units)

Each repo is one change set (own branch / PR), same checklist:

1. **Policy files** — apply the decided alignments to root configs where they exist.
2. **Root → template** — for shared policy files present in both places, update `template/` from root, preserving jinja and host-specific differences (e.g. GitHub vs GitLab paths).
3. **Intentional forks** — do not “fix” differences listed under Non-goals.

### Suggested order

1. **copier-mr-mise** — donor for prettier/yamlfmt/MegaLinter richness; also receives CLAUDE.md excludes + MegaLinter v10 on any lagging GitLab paths + kebab ls-lint if still needed after root→template.
2. **copier-mr-nix** — receive mise prettier/yamlfmt; MegaLinter v10 + merged config on GH and GL; kebab ls-lint; root→template refresh; confirm CLAUDE exclude already correct.

### Components touched (typical)

- `.mega-linter.yml` (root + template)
- CI references to MegaLinter version (`.github/workflows/*`, `.gitlab-ci.yml`, `.gitlab/workflows/*` as present)
- `.ls-lint.yml`, `.prettierrc.json`, `.yamlfmt.toml` (root + template)
- `copier.yml` exclusion / task rules for CLAUDE.md (lic-cli remains on both)
- CLAUDE.md (or template equivalent) where missing
- Other shared policy files only when applying root→template for the same concern (cog/apm/cspell/cliff only if they are part of an in-scope root→template refresh for that file; do not expand into unrelated refactors)

## Data / sync flow

```text
Brainstorm decisions (this spec)
        │
        ▼
copier-mr-mise  ──apply──►  root then template/
        │
        │  (prettier/yamlfmt/MegaLinter richness as source content)
        ▼
copier-mr-nix   ──apply──►  root then template/
        │
        ▼
Verification checklist (in-scope mismatches gone; product fork intact)
```

Within each repo: read root policy file → write matching `template/` variant → leave host-specific fields unchanged.

## Error handling / risk

- **Jinja breakage:** when copying root→template, preserve `{{ }}` / `{% %}` and host conditionals; never overwrite template-only markers with literal root values that belong as Copier answers.
- **Host leakage:** keep GitHub and GitLab surfaces correctly gated by each template’s existing `ci` question / conditionals.
- **Partial apply:** if one repo’s change set fails review, the other may still merge; re-check the decision table before a follow-up pass.
- **Version pin miss:** search both trees for `oxsecurity/megalinter` and MegaLinter image tags so no v9.6.0 reference remains in scope.

## Testing / verification

Success criteria:

1. Every MegaLinter version pin in scope is `v10.0.0`.
2. `.mega-linter.yml` across both repos reflects the merged policy (host-adapted), not the old lean-vs-rich split.
3. Both repos use kebab-case for `.ts` / `.d.ts` in ls-lint.
4. nix prettier/yamlfmt match mise’s decided options (root and template).
5. CLAUDE.md + agent-off exclusion rules exist in both; lic-cli remains on both.
6. Out-of-scope forks listed above are unchanged.

Method: file-level diff checklist against this table. Optional: one smoke `copier copy` per template only if a change risks jinja or post-copy tasks.

## Implementation notes (for writing-plans)

- Prefer two small PRs/branches over one mega-diff.
- Do not bump template `_version_` / release tags in this sync unless the user asks; config sync can land as chore commits.
- Pedantix pins and repo-local typos exceptions stay out of this sync unless they block an in-scope edit.
- After this spec is approved, next step is the **writing-plans** skill — not implementation yet.
- Any alignment with private/org templates is out of scope for this public document and must be planned only in private context.
