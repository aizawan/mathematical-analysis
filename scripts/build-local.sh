#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

REQUESTED_PORT="${1:-8000}"
PYTHON_BIN="${PYTHON_BIN:-$ROOT_DIR/.venv/bin/python}"
JUPYTER_BIN="${JUPYTER_BIN:-$ROOT_DIR/.venv/bin/jupyter}"

if [[ ! -x "$PYTHON_BIN" ]]; then
  echo "Python not found: $PYTHON_BIN" >&2
  echo "Run: uv venv --python 3.12 && uv pip install -r requirements.txt" >&2
  exit 1
fi

if [[ ! -x "$JUPYTER_BIN" ]]; then
  echo "Jupyter not found: $JUPYTER_BIN" >&2
  echo "Run: uv pip install -r requirements.txt" >&2
  exit 1
fi

export MPLCONFIGDIR="${MPLCONFIGDIR:-$ROOT_DIR/.matplotlib-cache}"
export IPYTHONDIR="${IPYTHONDIR:-$ROOT_DIR/.ipython-cache}"
mkdir -p "$MPLCONFIGDIR" "$IPYTHONDIR"

BUILD_SRC_DIR="$(mktemp -d "${TMPDIR:-/tmp}/mathematical-analysis-build.XXXXXX")"
trap 'rm -rf "$BUILD_SRC_DIR"' EXIT

echo "Preparing temporary build tree..."
"$PYTHON_BIN" - "$ROOT_DIR" "$BUILD_SRC_DIR" <<'PY'
import shutil
import sys
from pathlib import Path

source = Path(sys.argv[1])
target = Path(sys.argv[2])

ignore = shutil.ignore_patterns(
    ".git",
    ".venv",
    "_build",
    ".ipynb_checkpoints",
    ".matplotlib-cache",
    ".ipython-cache",
    "__pycache__",
    ".DS_Store",
)

shutil.copytree(source, target, dirs_exist_ok=True, ignore=ignore)
PY

NOTEBOOK_LIST="$BUILD_SRC_DIR/.notebooks-to-execute"
"$PYTHON_BIN" - "$BUILD_SRC_DIR/myst.yml" > "$NOTEBOOK_LIST" <<'PY'
import re
import sys
from pathlib import Path

for line in Path(sys.argv[1]).read_text(encoding="utf-8").splitlines():
    if line.lstrip().startswith("#"):
        continue
    match = re.search(r"file:\s*([^\n#]+\.ipynb)", line)
    if match:
        print(match.group(1).strip())
PY

echo "Executing notebooks in temporary build tree..."
while IFS= read -r notebook; do
  [[ -n "$notebook" ]] || continue
  echo "  executing $notebook"
  "$JUPYTER_BIN" nbconvert \
    --to notebook \
    --execute \
    --inplace \
    --ExecutePreprocessor.timeout="${NOTEBOOK_TIMEOUT:-600}" \
    "$BUILD_SRC_DIR/$notebook"
done < "$NOTEBOOK_LIST"

echo "Building Jupyter Book from executed notebooks..."
(
  cd "$BUILD_SRC_DIR"
  "$JUPYTER_BIN" book build --html
)

rm -rf "$ROOT_DIR/_build/html"
mkdir -p "$ROOT_DIR/_build"
cp -R "$BUILD_SRC_DIR/_build/html" "$ROOT_DIR/_build/html"

PORT="$("$PYTHON_BIN" - "$REQUESTED_PORT" <<'PY'
import socket
import sys

port = int(sys.argv[1])
while True:
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
        try:
            sock.bind(("127.0.0.1", port))
        except OSError:
            port += 1
        else:
            print(port)
            break
PY
)"

echo
echo "Serving _build/html"
echo "Open: http://localhost:$PORT"
echo "Press Ctrl+C to stop."

exec "$PYTHON_BIN" -m http.server "$PORT" -d "$ROOT_DIR/_build/html"
