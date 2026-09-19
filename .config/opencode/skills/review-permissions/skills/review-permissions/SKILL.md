---
name: review-permissions
description: Review OpenCode session-granted permissions against durable permissions in opencode.json. Use after a session with many permission prompts, or when the user wants to promote repeated approvals into persistent settings.
---

# Review Permissions

Use this skill when the user wants to:

- see which permissions were temporarily allowed in the current or latest session
- compare session-granted permissions to durable config in `~/.config/opencode/opencode.json`
- decide which repeated approvals should become permanent

## What this skill checks

It compares two sources:

- durable permissions from `~/.config/opencode/opencode.json`
- session-observed permission allows from the latest OpenCode log in `~/.local/share/opencode/log/`

Important limits:

- OpenCode does not appear to persist all session approvals into the durable config automatically
- the database permission table may be empty even when a session had many approvals
- session approvals are therefore best reconstructed from the log files

## Fast path

Run the bundled script:

```bash
node "$HOME/.config/opencode/skills/review-permissions/scripts/review-permissions.mjs"
```

Optional: point it at a specific log file:

```bash
node "$HOME/.config/opencode/skills/review-permissions/scripts/review-permissions.mjs" \
  "$HOME/.local/share/opencode/log/2026-05-12T052941.log"
```

## Expected output

The script prints:

- the durable allow rules
- the session allow rules seen in the chosen log
- the session allow rules missing from durable config
- broad wildcard approvals seen in the session log

## How to use the result

1. Review `Session-only allow rules`.
2. Keep narrow, repeatable rules such as `obsidian *` or `brew outdated *`.
3. Be careful with broad rules such as `bash: *`, `edit: *`, `external_directory: /Users/max/*`, or `external_directory: /opt/homebrew/*`.
4. If the user approves, update `~/.config/opencode/opencode.json`.

## Suggested workflow in a session

1. Run the script.
2. Summarize the missing durable rules.
3. Separate them into:
   - safe to persist
   - broad or risky, keep as ask
4. Ask one concise confirmation question if needed.
5. Apply the approved config change.

## Notes

- The script only uses local files.
- It is optimized for speed and low noise.
- It focuses on `allow` decisions, since those are the ones usually promoted into durable config.
