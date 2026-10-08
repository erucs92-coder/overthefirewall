# Anti-Gravity Uncensored

## Visión general

Anti-Gravity Uncensored es un proyecto de referencia que combina un modelo local de lenguaje con un entorno de ejecución fuertemente aislado a nivel de kernel. La propuesta central es simple: permitir un modelo con menos restricciones de alineación en la capa de conversación, mientras se exige un control estricto en la capa operativa para minimizar riesgos de ejecución.

El proyecto está pensado como prototipo técnico y de validación para entornos Linux, utilizando Ollama para servir el modelo local y bubblewrap (bwrap) para aplicar aislamiento de namespaces, red, sistema de archivos y directorio de trabajo.

## Propósito

- Permitir un agente LLM técnicamente más directo y menos sesgado por filtros morales en consultas de tipo técnico.
- Mantener un control rígido sobre el entorno donde se ejecutan comandos.
- Reducir el riesgo de que herramientas o scripts generados por la IA afecten sistemas críticos del host.
- Registrar eventos de ejecución para análisis, auditoría y diagnóstico.

## Principios de diseño

### 1. Separación entre modelo y sistema operativo

El modelo actúa como capa de razonamiento y generación de contenido, pero la ejecución real de comandos se controla fuera del propio modelo.

### 2. Defensa en profundidad

Se implementan varias capas:

- UX / heurísticas: detección de patrones potencialmente peligrosos antes de ejecutar comandos.
- Política: modos de ejecución (`sandbox`, `confirm`, `direct`).
- Kernel: namespaces de Linux y aislamiento con `bubblewrap`.
- Auditoría: logs JSONL con eventos registrados en disco.

### 3. Aislamiento de trabajo

El entorno se restringe a un directorio de trabajo específico (`/workspace`) y se evita el acceso no autorizado a recursos sensibles del sistema host.

## Estructura del repositorio

- `anti-gravity.sh`: script de instalación y validación del entorno.
- `agent.py`: agente interactivo CLI en Python.
- `config.yaml`: configuración del modelo, timeouts y detección de patrones peligrosos.
- `test_sandbox.sh`: pruebas de validación del sandbox.
- `README.md`: documentación técnica y guía de uso.
- `Anti_Gravity_Proyecto_Completo.txt`: síntesis del proyecto en formato de entrega.

## Requisitos

- Sistema operativo Linux con soporte de namespaces.
- Python 3.9 o superior.
- `bubblewrap` (`bwrap`) instalado.
- Ollama instalado y funcionando en localhost.
- Modelo local disponible, por ejemplo: `dolphin-llama3.1:8b`.
- Paquete `python3-yaml`.

## Instalación

Ejecuta lo siguiente desde la raíz del repositorio:

```bash
sudo ./anti-gravity.sh install
```

Este comando valida dependencias, prepara directorios y comprueba que `bwrap` y Ollama estén disponibles.

## Verificación y pruebas

```bash
sudo ./anti-gravity.sh check
sudo ./anti-gravity.sh test
```

La validación comprueba:

- presencia de dependencias,
- disponibilidad de `bwrap`,
- acceso a Ollama,
- ejecución de una prueba mínima dentro del sandbox.

## Ejecución del agente

```bash
./anti-gravity.sh run
```

También puedes iniciar el agente directamente:

```bash
python3 agent.py --mode sandbox
python3 agent.py --mode confirm
python3 agent.py --mode direct
```

## Modos operativos

### `sandbox`

Ejecuta comandos bajo un entorno aislado mediante `bwrap`.

- red no compartida,
- directorio de trabajo restringido,
- montaje de recursos mínimos,
- intento de prevenir impacto en el host.

### `confirm`

Solicita confirmación explícita antes de ejecutar cada comando.

### `direct`

Ejecuta el comando sin aislamiento adicional.

Este modo es útil solo en entornos altamente controlados y con tiempo de revisión manual.

## Ejecución de comandos desde la CLI

Dentro del agente, puedes invocar comandos con el prefijo `!cmd`:

```text
!cmd whoami
!cmd ls -la /workspace
!cmd uname -a
```

Si una orden coincide con patrones peligrosos como `rm -rf /`, `mkfs`, `dd if=/dev/zero`, `curl ... | bash`, etc., el sistema la bloquea o la requiere de aprobación según el modo activo.

## Auditoría

El agente registra eventos en formato JSONL dentro de `logs/audit.jsonl`.

Los eventos pueden incluir:

- inicio de sesión del agente,
- comandos ejecutados,
- comandos bloqueados,
- respuestas del modelo,
- errores y fallos de ejecución.

## Limitaciones y advertencias

Este proyecto es una referencia técnica, no una solución de seguridad "lista para producción" sin revisión. Debe considerarse como prototipo con fines de validación y aprendizaje.

Entre sus principales limitaciones se incluyen:

- Dependencia del soporte del kernel Linux.
- Dependencia de la configuración correcta de `bubblewrap`.
- Detección heurística de patrones no exhaustiva.
- Necesidad de permisos suficientes para crear namespaces.
- Riesgo residual si el host está mal configurado o los controles de seguridad no están bien definidos.

## Seguridad

El modelo puede generar respuestas o comandos muy complejos; por ello, la capa de ejecución debe tratarse como una frontera de seguridad. El proyecto pretende reducir riesgo, pero no reemplaza un diseño serio de seguridad del sistema operativo ni una revisión de profesionales de seguridad para despliegues reales.

## Resumen ejecutivo

Anti-Gravity Uncensored busca un equilibrio técnico muy concreto:

- libertad funcional del modelo en el plano intelectual,
- control estricto del entorno operativo,
- trazabilidad de la actividad,
- aislamiento de ejecución a nivel de kernel.

## Licencia

Este repositorio se entrega como referencia técnica para investigación, validación y desarrollo interno. Antes de utilizarlo en producción, conviene revisar la licencia y adaptarla a la política del entorno donde se desplegará.

## Notas finales

Este repositorio está pensado como una base de trabajo para demostrar cómo combinar:

- un modelo local sin alineación explícita,
- un LLM con historial de conversación,
- auditoría de eventos,
- y aislamiento operativo con `bubblewrap`.

La idea no es reemplazar prácticas de seguridad, sino exponer una implementación concreta para pruebas y análisis técnico.
