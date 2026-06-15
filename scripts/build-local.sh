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

echo "Building Jupyter Book..."
"$JUPYTER_BIN" book build --html --execute --execute-parallel 1

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
