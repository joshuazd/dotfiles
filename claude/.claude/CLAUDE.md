# Global Preferences

## CLI Tools
- Shortcut: use `short` CLI, not API calls
- GitHub: use `gh` CLI, not API calls

## Memory
- Store project-specific memories in the repo's `CLAUDE.local.md`, not in the auto-memory directory
- The auto-memory directory changes per worktree path and won't persist across worktrees
- Append a `## Notes` section (or similar) to `CLAUDE.local.md` for things worth remembering

## Ruby Workflow
- Run `bundle exec rubocop` on changed files before committing; fix all offenses before committing
- After implementing a story, check whether specs need updating
- Always run relevant spec files to confirm nothing is broken
- Run rubocop and specs in parallel

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

### SimpleCov branch coverage
- A test can pass for the wrong reason — verify which branch is actually being exercised
- Adding more test cases through the same code path does not increase branch coverage
- Distinguish "new branches covered" from "more confidence on existing branches" before writing tests

### Rails: pending migrations before specs
- Run `bin/rails db:migrate` if specs fail with `ActiveRecord::PendingMigrationError`

