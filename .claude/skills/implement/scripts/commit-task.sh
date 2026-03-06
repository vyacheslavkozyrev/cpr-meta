#!/usr/bin/env bash
# Usage: ./commit-task.sh <feature-number> <message>
# Example: ./commit-task.sh 0007 "add UserProfile entity and migration"
#
# Stages all changes and creates a commit in both cpr-api and cpr-ui.
# Skips a repo silently if there are no changes to commit.

set -euo pipefail

FEATURE_NUMBER="${1:-}"
MESSAGE="${2:-}"

if [[ -z "$FEATURE_NUMBER" || -z "$MESSAGE" ]]; then
  echo "Usage: $0 <feature-number> <message>"
  echo "Example: $0 0007 \"add UserProfile entity and migration\""
  exit 1
fi

# Zero-pad to 4 digits if needed
FEATURE_NUMBER=$(printf "%04d" "$((10#$FEATURE_NUMBER))")

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../../.." && pwd)"
API_DIR="$REPO_ROOT/source/cpr-api"
UI_DIR="$REPO_ROOT/source/cpr-ui"

COMMIT_MSG="feat(${FEATURE_NUMBER}): ${MESSAGE}"

for REPO_DIR in "$API_DIR" "$UI_DIR"; do
  REPO_NAME=$(basename "$REPO_DIR")

  if [[ ! -d "$REPO_DIR/.git" ]]; then
    echo "ERROR: $REPO_DIR is not a git repository."
    exit 1
  fi

  CURRENT_BRANCH=$(git -C "$REPO_DIR" branch --show-current)

  if [[ "$CURRENT_BRANCH" != feature/* ]]; then
    echo "[$REPO_NAME] WARNING: current branch is '$CURRENT_BRANCH', not a feature branch. Skipping commit."
    continue
  fi

  # Check for any changes (staged or unstaged)
  if git -C "$REPO_DIR" diff --quiet && git -C "$REPO_DIR" diff --cached --quiet; then
    echo "[$REPO_NAME] No changes to commit. Skipping."
    continue
  fi

  echo "[$REPO_NAME] Staging all changes..."
  git -C "$REPO_DIR" add -A

  echo "[$REPO_NAME] Committing: $COMMIT_MSG"
  git -C "$REPO_DIR" commit -m "$COMMIT_MSG"

  echo "[$REPO_NAME] Done. Latest commit: $(git -C "$REPO_DIR" log -1 --oneline)"
  echo ""
done

echo "Commit step complete."
