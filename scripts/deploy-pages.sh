#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

BASE_URL="${BASE_URL:-/mathematical-analysis}"
REMOTE="${REMOTE:-origin}"
BRANCH="${BRANCH:-gh-pages}"
JUPYTER_BIN="${JUPYTER_BIN:-$ROOT_DIR/.venv/bin/jupyter}"
GHP_IMPORT_BIN="${GHP_IMPORT_BIN:-$ROOT_DIR/.venv/bin/ghp-import}"

if [[ ! -x "$JUPYTER_BIN" ]]; then
  echo "Jupyter not found: $JUPYTER_BIN" >&2
  echo "Run: uv venv --python 3.12 && uv pip install -r requirements.txt" >&2
  exit 1
fi

if [[ ! -x "$GHP_IMPORT_BIN" ]]; then
  echo "ghp-import not found: $GHP_IMPORT_BIN" >&2
  echo "Run: uv pip install -r requirements.txt" >&2
  exit 1
fi

if ! git remote get-url "$REMOTE" >/dev/null 2>&1; then
  echo "Git remote not found: $REMOTE" >&2
  exit 1
fi

export BASE_URL
export MPLCONFIGDIR="${MPLCONFIGDIR:-$ROOT_DIR/.matplotlib-cache}"
export IPYTHONDIR="${IPYTHONDIR:-$ROOT_DIR/.ipython-cache}"
mkdir -p "$MPLCONFIGDIR" "$IPYTHONDIR"

echo "Building Jupyter Book for GitHub Pages..."
echo "BASE_URL=$BASE_URL"
"$JUPYTER_BIN" book build --html --execute --execute-parallel 1

echo
echo "Publishing _build/html to $REMOTE/$BRANCH..."
"$GHP_IMPORT_BIN" -n -p -f -r "$REMOTE" -b "$BRANCH" _build/html

echo
echo "Published:"
echo "https://aizawan.github.io${BASE_URL}/"
