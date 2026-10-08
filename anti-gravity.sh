#!/usr/bin/env bash
set -euo pipefail

APP_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PYTHON_BIN="${PYTHON_BIN:-python3}"
WORKSPACE_DIR="${WORKSPACE_DIR:-/workspace}"

usage() {
  cat <<'EOF'
Anti-Gravity Uncensored - bootstrap installer

Uso:
  ./anti-gravity.sh [install|check|run|test]

Comandos:
  install   Verifica dependencias y prepara el sistema.
  check     Comprueba requisitos mínimos y estado del sandbox.
  run       Ejecuta el agente interactivo.
  test      Ejecuta la suite de validación del sandbox.
EOF
}

require_root() {
  if [[ ${EUID} -ne 0 ]]; then
    echo "[!] Este script requiere privilegios root para instalar paquetes y validar bwrap." >&2
    exit 1
  fi
}

ensure_dirs() {
  mkdir -p "$WORKSPACE_DIR"
  mkdir -p "$APP_DIR/logs"
  chmod 700 "$APP_DIR/logs"
}

install_dependencies() {
  echo "[+] Verificando dependencias..."
  export DEBIAN_FRONTEND=noninteractive

  if command -v apt-get >/dev/null 2>&1; then
    apt-get update
    apt-get install -y --no-install-recommends \
      python3 python3-pip python3-venv curl bubblewrap ca-certificates \
      python3-yaml procps iproute2
  else
    echo "[!] apt-get no está disponible. Instala manualmente python3, bubblewrap y PyYAML." >&2
    exit 1
  fi

  if ! command -v bwrap >/dev/null 2>&1; then
    echo "[!] bubblewrap no quedó disponible tras la instalación." >&2
    exit 1
  fi

  if ! "$PYTHON_BIN" - <<'PY'
import yaml
print('pyyaml-ok')
PY
  then
    echo "[!] PyYAML no está disponible. Reinstala python3-yaml o usa pip install pyyaml." >&2
    exit 1
  fi

  echo "[+] Dependencias instaladas correctamente."
}

check_environment() {
  local missing=0
  for tool in "$PYTHON_BIN" curl bwrap; do
    if ! command -v "$tool" >/dev/null 2>&1; then
      echo "[!] Falta: $tool" >&2
      missing=1
    fi
  done

  if ! command -v ollama >/dev/null 2>&1; then
    echo "[!] Ollama no está instalado o no está en PATH. Instálalo para usar el modelo local." >&2
    echo "    Docs: https://ollama.com/download" >&2
    missing=1
  fi

  if [[ ! -f "$APP_DIR/config.yaml" ]]; then
    echo "[!] Falta config.yaml en $APP_DIR" >&2
    missing=1
  fi

  if [[ ! -f "$APP_DIR/agent.py" ]]; then
    echo "[!] Falta agent.py en $APP_DIR" >&2
    missing=1
  fi

  if [[ "$missing" -ne 0 ]]; then
    exit 1
  fi

  echo "[+] Requisitos básicos verificados."
}

run_tests() {
  if [[ ! -x "$APP_DIR/test_sandbox.sh" ]]; then
    chmod +x "$APP_DIR/test_sandbox.sh"
  fi
  "$APP_DIR/test_sandbox.sh"
}

run_agent() {
  if [[ ! -x "$APP_DIR/agent.py" ]]; then
    chmod +x "$APP_DIR/agent.py"
  fi
  exec "$PYTHON_BIN" "$APP_DIR/agent.py" "$@"
}

main() {
  case "${1:-install}" in
    install)
      require_root
      ensure_dirs
      install_dependencies
      check_environment
      ;;
    check)
      ensure_dirs
      check_environment
      ;;
    test)
      ensure_dirs
      check_environment
      run_tests
      ;;
    run)
      ensure_dirs
      shift || true
      run_agent "$@"
      ;;
    -h|--help|help)
      usage
      ;;
    *)
      usage
      exit 1
      ;;
  esac
}

main "$@"
