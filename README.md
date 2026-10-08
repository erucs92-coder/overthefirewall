# Anti-Gravity Uncensored

## Visión general

Anti-Gravity Uncensored es un proyecto de referencia para combinar un modelo local sin alineación con un entorno de ejecución restringido a nivel de kernel. El objetivo es permitir consultas técnicas sin filtros morales y, al mismo tiempo, mitigar el riesgo de que el agente ejecute comandos destructivos sobre la máquina host.

La entrega puede ejecutarse con Ollama y `bubblewrap` para mantener una separación efectiva entre el entorno del agente y el sistema operativo host.

## Arquitectura

- Modelo local: `dolphin-llama3.1:8b` a través de Ollama.
- Interfaz de usuario: CLI interactiva en Python.
- Modo de ejecución:
  - `sandbox`: ejecuta comandos bajo `bwrap` con red no compartida y raíz aislada.
  - `confirm`: pide confirmación antes de ejecutar cada comando.
  - `direct`: ejecuta directamente sin capa de barrera adicional.
- Auditoría: JSONL para registrar solicitudes, respuestas y comandos ejecutados.

## Archivos incluidos

- `anti-gravity.sh`: instala dependencias y prepara el sistema.
- `agent.py`: agente interactivo basado en Ollama y modos de ejecución.
- `config.yaml`: parámetros de conexión, tiempo de espera y patrones de seguridad.
- `test_sandbox.sh`: validación del aislamineto con `bubblewrap`.
- `README.md`: documentación del proyecto.
- `Anti_Gravity_Proyecto_Completo.txt`: entrega consolidada del proyecto.

## Requisitos

- Linux con soporte de namespaces y `bubblewrap`.
- Python 3.9+
- Ollama instalado y un modelo disponible (`dolphin-llama3.1:8b`).
- `bwrap` y `python3-yaml`.

## Instalación rápida

```bash
sudo ./anti-gravity.sh install
sudo ./anti-gravity.sh run
```

También puedes consultar el estado del entorno:

```bash
sudo ./anti-gravity.sh check
sudo ./anti-gravity.sh test
```

## Uso

### 1) Arrancar el agente

```bash
./anti-gravity.sh run
```

### 2) Ejecutar comandos desde la CLI

Si prefieres lanzar un comando directamente desde la terminal del agente:

```text
!cmd whoami
!cmd ls -la /workspace
```

### 3) Modos de ejecución

```bash
python3 agent.py --mode sandbox
python3 agent.py --mode confirm
python3 agent.py --mode direct
```

## Seguridad y limitaciones

Este proyecto está diseñado para reducir el riesgo de impacto sobre el sistema host, pero no sustituye una política de seguridad del sistema operativo ni un entorno de producción validado por un equipo de seguridad.

Las capas implementadas incluyen:

- detección de comandos peligrosos,
- verificación de dependencias,
- ejecución bajo namespaces de Linux,
- auditoría de eventos en formato JSONL.

## Limitaciones conocidas

- La protección depende del soporte del kernel y del host Linux.
- `bwrap` no garantiza una ejecución completamente libre de riesgos si el host está mal configurado.
- Los modelos generativos pueden producir comandos que no sean detectados por expresiones regulares.
- La correcta operación requiere un entorno local con permisos suficientes para crear namespaces.

## Licencia

Este repositorio es un conjunto de archivos de referencia para investigación y validación técnica. Ajusta la licencia según tu política interna antes de desplegarlo en entornos reales.
