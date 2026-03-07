#!/usr/bin/env bash
# Usage: ./create-feature-branch.sh <feature-number> <short-feature-name>
# Example: ./create-feature-branch.sh 0007 user-profile
#
# Creates branch feature/####-short-feature-name in both cpr-api and cpr-ui,
# branching off from their current 'develop' branch.

set -euo pipefail

FEATURE_NUMBER="${1:-}"
SHORT_NAME="${2:-}"

if [[ -z "$FEATURE_NUMBER" || -z "$SHORT_NAME" ]]; then
  echo "Usage: $0 <feature-number> <short-feature-name>"
  echo "Example: $0 0007 user-profile"
  exit 1
fi

# Zero-pad to 4 digits if needed
FEATURE_NUMBER=$(printf "%04d" "$((10#$FEATURE_NUMBER))")
BRANCH="feature/${FEATURE_NUMBER}-${SHORT_NAME}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
API_DIR="$REPO_ROOT/source/cpr-api"
UI_DIR="$REPO_ROOT/source/cpr-ui"

for REPO_DIR in "$API_DIR" "$UI_DIR"; do
  REPO_NAME=$(basename "$REPO_DIR")

  if [[ ! -d "$REPO_DIR/.git" ]]; then
    echo "ERROR: $REPO_DIR is not a git repository."
    exit 1
  fi

  echo "[$REPO_NAME] Fetching origin..."
  git -C "$REPO_DIR" fetch origin

  echo "[$REPO_NAME] Checking out develop and pulling latest..."
  git -C "$REPO_DIR" checkout develop
  git -C "$REPO_DIR" pull origin develop

  if git -C "$REPO_DIR" show-ref --verify --quiet "refs/heads/$BRANCH"; then
    echo "[$REPO_NAME] Branch '$BRANCH' already exists — checking it out."
    git -C "$REPO_DIR" checkout "$BRANCH"
  else
    echo "[$REPO_NAME] Creating branch '$BRANCH' from develop..."
    git -C "$REPO_DIR" checkout -b "$BRANCH"
  fi

  echo "[$REPO_NAME] Done. Current branch: $(git -C "$REPO_DIR" branch --show-current)"
  echo ""
done

echo "Feature branches ready: $BRANCH"
