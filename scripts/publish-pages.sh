#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

export BASE_URL="${BASE_URL:-/mathematical-analysis}"
export MPLCONFIGDIR="${MPLCONFIGDIR:-$ROOT_DIR/.matplotlib-cache}"
export IPYTHONDIR="${IPYTHONDIR:-$ROOT_DIR/.ipython-cache}"
mkdir -p "$MPLCONFIGDIR" "$IPYTHONDIR"

echo "Building Jupyter Book for GitHub Pages..."
echo "BASE_URL=$BASE_URL"
uv run jupyter book build --html --execute --execute-parallel 1

echo
echo "Publishing _build/html to gh-pages..."
uv run ghp-import -n -p -f _build/html
