#!/usr/bin/env bash
set -euo pipefail

APP_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE="${WORKSPACE:-/workspace}"

echo "[+] Verificando entorno de sandbox..."
if ! command -v bwrap >/dev/null 2>&1; then
  echo "[!] bubblewrap no está disponible." >&2
  exit 1
fi

echo "[+] Comprobando que /workspace exista..."
mkdir -p "$WORKSPACE"
chmod 700 "$WORKSPACE"

TEST_CMD='echo "sandbox-ok"; id; pwd; ls -la /workspace'

echo "[+] Ejecutando prueba de aislamiento con bwrap..."
if bwrap --unshare-net --new-session --die-with-parent --proc /proc --dev /dev --tmpfs /tmp --tmpfs /run --ro-bind / / --bind "$WORKSPACE" "$WORKSPACE" --chdir "$WORKSPACE" -- /bin/bash -lc "$TEST_CMD" >/tmp/anti_gravity_test.out 2>/tmp/anti_gravity_test.err; then
  echo "[OK] Ejecución aislada completada."
else
  echo "[!] La ejecución aislada falló." >&2
  cat /tmp/anti_gravity_test.err >&2 || true
  exit 1
fi

if grep -Eqi 'sandbox-ok' /tmp/anti_gravity_test.out; then
  echo "[OK] Se detectó salida válida desde el sandbox."
else
  echo "[!] La salida del sandbox no contiene la marca esperada." >&2
  exit 1
fi

if ! grep -q 'unshare' <(bwrap --help 2>&1 || true); then
  echo "[!] bubblewrap no expone capacidades de aislamiento suficientes en este entorno." >&2
  exit 1
fi

# Prueba de bloqueo de comando potencialmente destructivo
DANGEROUS='rm -rf /'
if bwrap --unshare-net --new-session --die-with-parent --proc /proc --dev /dev --tmpfs /tmp --tmpfs /run --ro-bind / / --bind "$WORKSPACE" "$WORKSPACE" --chdir "$WORKSPACE" -- /bin/bash -lc "$DANGEROUS" >/dev/null 2>&1; then
  echo "[WARN] El comando destructivo se ejecutó dentro del sandbox; revisa las restricciones." >&2
else
  echo "[OK] El comando destructivo fue bloqueado o falló de forma segura."
fi

echo "[OK] Suite de validación del sandbox completada."
