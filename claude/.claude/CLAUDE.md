# Global Preferences
Be extremely concise. Sacrifice grammar for the sake of concision.
Push back on silly ideas.

## CLI Tools
- Shortcut: use `short` CLI, not API calls
- GitHub: use `gh` CLI, not API calls
- PR comments have 3 separate APIs (top-level, inline review, review verdicts) — `gh pr view --json comments` only gets top-level; use the `/gh` skill for the full picture

## Shell Aliases
- `cp` and `rm` are aliased to interactive mode (`-i`) — use `\rm` and `\cp` to bypass aliases and avoid confirmation prompts that hang

## Memory
- Store project-specific memories in the repo's `CLAUDE.local.md`, not in the auto-memory directory
- The auto-memory directory changes per worktree path and won't persist across worktrees
- Append a `## Notes` section (or similar) to `CLAUDE.local.md` for things worth remembering

## Code Changes
- Before implementing anything, search for existing patterns, helpers, utilities, and abstractions that already solve the problem — reuse over reinvention
- Check for existing base classes, concerns, service objects, shared helpers, and similar patterns before writing new ones

## Ruby Workflow
- Linting is handled automatically by a PostToolUse hook — no need to run linters manually
- After implementing a story, check whether specs need updating
- Always run relevant spec files to confirm nothing is broken

## Debugging

- Add diagnostic instrumentation (log file, trap, explicit echo at each step) before theorizing — a log file gives definitive answers faster than reasoning about internals
- Propose fixes only after confirmed root cause; plausible ≠ true, and wrong fixes cause real damage
- When the user pushes back on a hypothesis, treat it as signal to question the hypothesis, not defend it

## tmux run-shell

- `run-shell` keybind jobs have no implicit current client — `switch-client` and `display-popup` return "no current client" unless `-c` is passed explicitly
- Capture the client before any switching: `current_client="$(tmux display-message -p '#{client_name}')"`
- Pass `-c "${current_client}"` to both `switch-client` and `display-popup`
- `run-shell` CWD is the tmux server's startup dir (`~`), not the triggering pane's dir — use `tmux display-message -p '#{pane_current_path}'` when you need the pane's path

## Ruby Reference

### URI.parse host behavior
- `URI.parse("file:///local/path").host` → `""` (empty string, NOT nil)
- `URI.parse("mailto:user@example.com").host` → nil
- `URI.parse("github.com").host` → nil (no scheme = no authority)
- To test a `return false if host.nil?` branch, use a `mailto:` URI


