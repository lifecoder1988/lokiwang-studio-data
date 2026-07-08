# AGENTS.md

## Project Overview

- Content repository for blog posts and articles authored in Markdown, later distributed to multiple publishing platforms.
- Project type: content (no build/runtime)
- Package manager: none
- Main content paths:
  - `blog/` — Markdown blog posts / articles (the source of truth for distribution)
  - `work/` — working drafts and in-progress material

## Important Documentation

- Architecture: `docs/architecture/`
- Domain rules: `docs/domain/`
- API conventions: `docs/api/`
- Engineering rules: `docs/engineering/`
- Architecture decisions: `docs/adr/`
- Product capability specs: `openspec/specs/`
- Active changes: `openspec/changes/`

## Working Rules

- Read the nearest applicable `AGENTS.md` before modifying files.
- Read related domain documentation before changing business behavior.
- Do not modify third-party or vendored code (`node_modules/`, `vendor/`, `third_party/`, `patches/`). Wrap or extend it instead; if patching is unavoidable, record an ADR first.
- Do not use user-level (global) skills, plugins, or MCP tools unless the human explicitly asks for them. Prefer tools, scripts, and skills defined inside this repository.
- Never violate declared hard constraints (`docs/domain/*/rules.md` 硬限制 sections and `docs/engineering/constraints.md`). If a limit is not declared, ask the human instead of assuming it is negotiable.
- If you are guessing, fabricating, or cannot verify a conclusion, stop and ask the human.
- Do not duplicate domain rules in this file.
- Update OpenSpec specs when externally observable behavior changes.
- Add or update tests for behavior changes.
- Do not mix unrelated refactors into a feature change.

## High-Risk Areas

Before changing payment, order, commission, settlement, withdrawal, permissions, webhooks, inventory, or audit logging, read the applicable documentation under `docs/domain/`. Hard constraints for these areas are declared in each domain's `rules.md` under 硬限制（不可违反）.

## Definition of Done

- Relevant tests pass.
- Type checking and lint pass where configured.
- A human has reviewed the change.
- All declared hard constraints hold.
- Behavior changes include documentation or specification updates where applicable.
- High-risk changes include rollback and failure-path consideration.
