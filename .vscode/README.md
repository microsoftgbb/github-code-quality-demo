# Demo Restore Tasks

In VS Code, open **Terminal > Run Task**, then choose:

- **Demo: Preview Restore** to inspect differences from the baseline.
- **Demo: Restore Baseline** and select **RESTORE** to replace tracked demo
  files with commit `54ff58848f9034f932785e719dbd9d32efe37763` and stage the result.

Both tasks require `main` and refuse to run during an unfinished merge, rebase,
cherry-pick, or revert. Restore discards tracked local edits and staged changes
within its scope. It does not move the branch, rewrite history, commit, push,
or delete untracked or ignored files. An untracked file at a path required by
the baseline can block restoration; move it aside and retry.

The task configuration, this document, and `scripts/restore-demo.sh` are excluded
from restoration so the reset tooling survives once committed. All other tracked
files, including workflows added during a demo, are restored or removed to match
the baseline. The untracked coverage workflow currently in the workspace is left
untouched; once tracked, it will be removed on restore because it is not in the
baseline.

Repeating Restore with no intervening changes leaves the same files and index.
When there are staged changes, review and publish them yourself:

```sh
git diff --cached
git commit -m "Reset demo to baseline"
git push origin main
```

If `main` requires pull requests, create a reset branch after running Restore,
commit there, and open a PR instead of pushing directly to `main`.

These tasks do not fetch remote changes. Sync `main` before a reset when needed.
They do not reset GitHub settings, pull requests, findings, or scan history.