#!/usr/bin/env bash

set -euo pipefail

mode="${1:---preview}"
case "$mode" in
  --preview | --apply) ;;
  *) printf 'Usage: bash scripts/restore-demo.sh [--preview|--apply]\n' >&2; exit 1 ;;
esac

if [[ "$mode" == "--apply" && "${2:-}" != "RESTORE" ]]; then
  printf 'Restore cancelled. Pass RESTORE as the second argument to confirm.\n' >&2
  exit 1
fi

repo_root="$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"
cd "$repo_root"
baseline="54ff58848f9034f932785e719dbd9d32efe37763"
git cat-file -e "${baseline}^{commit}"

if [[ "$(git symbolic-ref --quiet --short HEAD || true)" != "main" ]]; then
  printf 'Switch to main before restoring the demo.\n' >&2
  exit 1
fi

for operation in MERGE_HEAD CHERRY_PICK_HEAD REVERT_HEAD rebase-merge rebase-apply sequencer; do
  if [[ -e "$(git rev-parse --git-path "$operation")" ]]; then
    printf 'Finish or abort the active Git operation before restoring.\n' >&2
    exit 1
  fi
done

paths=(
  .
  ':(exclude).vscode/tasks.json'
  ':(exclude).vscode/README.md'
  ':(exclude)scripts/restore-demo.sh'
)

printf 'Demo baseline: %s\n' "$baseline"
if [[ "$mode" == "--preview" ]]; then
  git diff --stat "$baseline" -- "${paths[@]}"
  printf '\nUntracked files (preserved by restore):\n'
  git ls-files --others --exclude-standard
  printf '\nRestore replaces tracked demo files and stages the result. No commit or push is made.\n'
  exit 0
fi

git restore --source="$baseline" --staged --worktree -- "${paths[@]}"
git diff --quiet "$baseline" -- "${paths[@]}"
git diff --cached --quiet "$baseline" -- "${paths[@]}"

if git diff --cached --quiet; then
  printf 'Already at the demo baseline. Nothing to commit.\n'
else
  printf 'Demo restored. Review the staged changes, then commit and push when ready.\n'
  git diff --cached --stat
fi