# Global Preferences
- Be extremely concise. Sacrifice grammar for the sake of concision.
- Push back on silly ideas.
- Never use the em dash "—". Use plain dash "-" instead
- When making technical decision, do not give much weight to development cost. Instead, prefer quality, simplicity, robustness, scalability, and long term maintainability
- Prefer no code comments whenever possible. Comments should only be used in cases where the meaning of the code cannot be inferred from reading it.


## NEVER reply to humans
Never post replies/comments/messages to humans on PRs, Slack, GitHub issues, or any other channel as the user. Not inline review replies, not top-level PR comments, not Slack messages, not @mentions — nothing user-facing addressed to other humans. The user posts. I do not. This is absolute, not a "confirm first" rule. Drafting a reply for the user to send themselves is fine; sending it is not. "Address the feedback" or "update the comments" means change the code/story to address it, not post replies.

**Exception — automated review bots:** Replying to, resolving, and retriggering review-bot threads (e.g. Greptile, Dependabot, CI bots) is allowed and expected. These are bot-to-bot interactions, not messages to humans. The ban above applies only to content addressed to humans.

## CLI Tools
- Shortcut: use `short` CLI, not API calls
- GitHub: use `gh` CLI, not API calls
- PR comments have 3 separate APIs (top-level, inline review, review verdicts) — `gh pr view --json comments` only gets top-level; use the `/gh` skill for the full picture

## Bash Usage
- Never use heredoc syntax (`<<EOF`, `<<'EOF'`) in Bash — use the Write tool to create files, and `echo "..." | cmd` or `cmd <<< "..."` to feed stdin to CLI tools

## Shell Aliases
- `cp` and `rm` are aliased to interactive mode (`-i`) — use `\rm` and `\cp` to bypass aliases and avoid confirmation prompts that hang

## Memory
- Store project-specific memories in the repo's `CLAUDE.local.md`, not in the auto-memory directory
- The auto-memory directory changes per worktree path and won't persist across worktrees
- Append a `## Notes` section (or similar) to `CLAUDE.local.md` for things worth remembering

## Code Changes
- Before implementing anything, search for existing patterns, helpers, utilities, and abstractions that already solve the problem — reuse over reinvention
- Check for existing base classes, concerns, service objects, shared helpers, and similar patterns before writing new ones

## Debugging

- Add diagnostic instrumentation (log file, trap, explicit echo at each step) before theorizing — a log file gives definitive answers faster than reasoning about internals
- Propose fixes only after confirmed root cause; plausible ≠ true, and wrong fixes cause real damage
- When the user pushes back on a hypothesis, treat it as signal to question the hypothesis, not defend it

