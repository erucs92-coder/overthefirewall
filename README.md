# Anti-Gravity Uncensored

## Visión general

Anti-Gravity Uncensored es un prototipo técnico de referencia que combina un modelo local de lenguaje con un entorno de ejecución aislado a nivel de kernel. La idea principal es permitir que el modelo responda con menos restricciones de alineación en consultas técnicas, mientras se aplica un control estricto en la capa de ejecución para mitigar riesgos sobre el sistema operativo host.

El proyecto está pensado para entornos Linux y utiliza Ollama como backend del modelo y `bubblewrap` para aplicar aislamiento de namespaces, red y espacio de trabajo.

## Propósito

- Permitir un agente LLM más directo y menos condicionado por filtros morales en consultas técnicas.
- Reduzir el riesgo de ejecución destructiva mediante entorno sandbox.
- Registrar eventos para auditoría y análisis forense.
- Mantener la lógica de IA separada del sistema operativo real.

## Principios de diseño

### 1. Modelo y sistema operativo separados

La capa del modelo genera texto y recomendaciones, pero la ejecución real de comandos está controlada por un entorno restringido.

### 2. Defensa en profundidad

Incluye varias capas:

- heurísticas de seguridad para bloquear patrones peligrosos,
- modos de ejecución según el nivel de riesgo,
- aislamiento a nivel de kernel con `bwrap`,
- auditoría en JSONL para trazabilidad.

### 3. Aislamiento de espacio de trabajo

El agente trabaja dentro de un directorio acotado, por defecto `/workspace`, para evitar accesos no autorizados a archivos del host.

## Estructura del repositorio

- `anti-gravity.sh`: script de instalación y validación del entorno.
- `agent.py`: agente interactivo CLI en Python.
- `config.yaml`: configuración del modelo, timeout y patrones de seguridad.
- `test_sandbox.sh`: suite de prueba de aislamiento.
- `README.md`: guía técnica y de uso.
- `Anti_Gravity_Proyecto_Completo.txt`: documento de referencia del proyecto.

## Requisitos

- Linux con soporte de namespaces.
- Python 3.9+
- `bubblewrap` instalado (`bwrap`)
- Ollama instalado y funcionando en localhost
- Modelo disponible, por ejemplo: `dolphin-llama3.1:8b`
- Paquete `python3-yaml`

## Instalación rápida

```bash
sudo ./anti-gravity.sh install
```

También puedes comprobar el estado del entorno:

```bash
sudo ./anti-gravity.sh check
sudo ./anti-gravity.sh test
```

## Ejecutar el agente

```bash
./anti-gravity.sh run
```

O directamente:

```bash
python3 agent.py --mode sandbox
python3 agent.py --mode confirm
python3 agent.py --mode direct
```

## Modos operativos

### `sandbox`

Ejecución bajo aislamiento de kernel. Se habilita `bwrap` con red no compartida y un directorio de trabajo acotado.

### `confirm`

Antes de ejecutar un comando, el sistema solicita confirmación explícita.

### `direct`

Ejecución sin aislamiento adicional. Solo recomendable en entornos muy controlados.

## Uso desde la CLI

Dentro del agente puedes lanzar órdenes con el prefijo `!cmd`:

```text
!cmd whoami
!cmd ls -la /workspace
!cmd uname -a
```

Si el comando coincide con patrones sospechosos como:

- `rm -rf /`
- `mkfs`
- `dd if=/dev/zero`
- `curl ... | bash`
- `wget ... | bash`

el agente lo bloquea o exige confirmación según el modo activo.

## Auditoría

El sistema registra eventos en formato JSONL en la carpeta `logs/`:

- inicio del agente,
- comandos ejecutados,
- comandos bloqueados,
- respuestas del modelo,
- errores y casos de seguridad.

## Limitaciones y advertencias

Este proyecto es una referencia técnica y un prototipo de validación, no una solución de seguridad lista para producción sin revisión.

Entre sus principales limitaciones:

- La protección depende del soporte del kernel Linux.
- `bwrap` no garantiza seguridad absoluta si el host está mal configurado.
- Las expresiones regulares de detección no cubren todas las ejecuciones maliciosas.
- Se requiere permiso suficiente para crear namespaces.
- El entorno debe revisarse antes de ser usado en un sistema productivo.

## Seguridad

La ejecución del modelo no debe tratarse como un entorno de confianza total. El bloque de ejecución debe considerarse una frontera de seguridad. El proyecto intenta reducir riesgo, pero no sustituye una política seria de seguridad del sistema operativo ni una revisión de expertos.

## Resumen ejecutivo

Anti-Gravity Uncensored busca un balance técnico concreto:

- libertad funcional del modelo en la capa de razonamiento,
- control estricto del entorno operativo,
- trazabilidad de acciones mediante auditoría,
- aislamiento real de ejecución a nivel de kernel.

## Licencia

Este repositorio se entrega como referencia técnica para investigación, pruebas y validación interna. Ajusta la licencia antes de desplegarlo en producción o en entornos de terceros.

## Notas finales

La idea de este proyecto es demostrar cómo combinar:

- un modelo local sin alineación explícita,
- un historial de conversación,
- una política de seguridad en ejecución,
- y aislamiento operativo con `bubblewrap`.

El objetivo no es reemplazar prácticas de seguridad, sino exponer un diseño técnico concreto y discutible para análisis y desarrollo.
