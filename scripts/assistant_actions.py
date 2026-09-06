#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Catalogo de acciones que el asistente de voz (Claude) puede ejecutar.

SOLO se permiten las acciones definidas aqui. Claude recibe estas
funciones en el tool-calling y nunca ejecuta comandos arbitrarios.

Cada accion define:
  - name        : nombre unico (usado por Claude)
  - description : que hace, y cuando usarla
  - args        : parametros que recibe
  - run_fn      : funcion que ejecuta la accion
"""

import os
import subprocess
import sys

HOME = os.path.expanduser("~")
SCRIPTS_DIR = os.path.expanduser("~/scripts")


def _run(cmd, **kwargs):
    """Ejecuta un comando y devuelve su salida (texto)."""
    try:
        proc = subprocess.run(
            cmd,
            shell=True,
            capture_output=True,
            text=True,
            timeout=180,
            **kwargs,
        )
        out = (proc.stdout or "").strip()
        err = (proc.stderr or "").strip()
        if proc.returncode != 0:
            return f"ERROR (exit {proc.returncode}): {err or out or 'sin detalle'}"
        return out or "OK"
    except subprocess.TimeoutExpired:
        return "ERROR: el comando excedio el tiempo de espera (3 min)"
    except Exception as exc:  # noqa: BLE001
        return f"ERROR: {exc}"


def _script_path(name):
    path = os.path.join(SCRIPTS_DIR, name)
    if os.path.exists(path):
        return path
    binpath = os.path.join(HOME, ".config/bin", name)
    if os.path.exists(binpath):
        return binpath
    return path  # devuelve la ruta esperada aunque no exista


# --------------------------------------------------------------------------
# Implementaciones de cada accion
# --------------------------------------------------------------------------

def _act_scan_target(target):
    """Escaneo rapido nmap de un objetivo."""
    if not target:
        return "ERROR: falta la IP del objetivo"
    return _run(f"nmap -sC -sV -T4 {target}")


def _act_set_target(ip, name=""):
    """Fija el target actual (IP y nombre opcional) en la polybar."""
    if not ip:
        return "ERROR: falta la IP"
    target_file = os.path.expanduser("~/.config/polybar/cuts/scripts/target")
    os.makedirs(os.path.dirname(target_file), exist_ok=True)
    with open(target_file, "w") as fh:
        fh.write(f"{ip} {name}".strip() + "\n")
    return f"Target fijado: {ip} {name}".strip()


def _act_clear_target():
    """Limpia el target actual."""
    target_file = os.path.expanduser("~/.config/polybar/cuts/scripts/target")
    if os.path.exists(target_file):
        os.remove(target_file)
        return "Target limpiado"
    return "No habia target"


def _act_apply_theme(theme, mode="normal"):
    """Aplica un tema (Zenitsu/Raven/Simon/Camila/Ryan/Esmeralda/Xavier/Nami)
    en modo normal o pentest (penetration)."""
    script = _script_path("Theaming.sh")
    if not os.path.exists(script):
        return f"ERROR: no se encontro {script}"
    # Theaming es interactivo (menu) -> lo lanzamos en terminal separada
    cmd = f"kitty -e bash {script}"
    # No podemos seleccion el tema automaticamente por el menu, asi que
    # documentamos que se abre el selector para que el usuario elija.
    return _run(f"nohup {cmd} >/dev/null 2>&1 & echo 'Se abrio el selector de temas' ")


# --------------------------------------------------------------------------
# Definiciones de herramientas para Claude (formato Anthropic tool JSON)
# --------------------------------------------------------------------------

def _tool(name, description, props, required=()):
    return {
        "name": name,
        "description": description,
        "input_schema": {
            "type": "object",
            "properties": props,
            "required": list(required),
        },
    }


_TOOLS = [
    _tool(
        "scan_target",
        "Realiza un escaneo rapido de puertos y servicios con nmap contra una IP objetivo. "
        "Usa esto cuando el usuario pida escanear un objetivo o una IP.",
        {"target": {"type": "string", "description": "IP o hostname del objetivo"}},
        required=["target"],
    ),
    _tool(
        "set_target",
        "Fija el target de pentesting actual (IP y nombre opcional) que muestra la polybar. "
        "Usa cuando el usuario diga 'pon de target', 'set target', 'fija el objetivo'.",
        {
            "ip": {"type": "string", "description": "Direccion IP del objetivo"},
            "name": {"type": "string", "description": "Nombre opcional de la maquina"},
        },
        required=["ip"],
    ),
    _tool(
        "clear_target",
        "Limpia/borra el target de pentesting actual de la polybar.",
        {},
    ),
    _tool(
        "apply_theme",
        "Aplica un tema en el rice. Los temas son: Zenitsu, Raven, Simon, Camila, Ryan, "
        "Esmeralda, Xavier, Nami. Abre el selector de temas de Theaming. Usa cuando pida "
        "cambiar de tema o aplicar un tema.",
        {
            "theme": {"type": "string", "description": "Nombre del tema a aplicar"},
            "mode": {
                "type": "string",
                "enum": ["normal", "pentest"],
                "description": "Modo normal o pentest",
            },
        },
        required=["theme"],
    ),
]


def get_tools():
    """Devuelve la lista de herramientas (JSON) para Anthropic."""
    return _TOOLS


def executar(accion_name, **kwargs):
    """Ejecuta una accion por su nombre. Retorna (ok:bool, msg:str)."""
    acciones = {
        "scan_target": lambda k: _act_scan_target(k.get("target", "")),
        "set_target": lambda k: _act_set_target(
            k.get("ip", ""), k.get("name", "")
        ),
        "clear_target": lambda k: _act_clear_target(),
        "apply_theme": lambda k: _act_apply_theme(
            k.get("theme", ""), k.get("mode", "normal")
        ),
    }
    fn = acciones.get(accion_name)
    if fn is None:
        return False, f"Accion desconocida: {accion_name}"
    try:
        msg = fn(kwargs)
        return True, msg
    except Exception as exc:  # noqa: BLE001
        return False, f"Error ejecutando {accion_name}: {exc}"


if __name__ == "__main__":
    # Modo pruebas: python3 actions.py <accion> [json args]
    import json

    if len(sys.argv) < 2:
        print("Uso: python3 actions.py <accion> [json_args]")
        sys.exit(1)
    nombre = sys.argv[1]
    args = json.loads(sys.argv[2]) if len(sys.argv) > 2 else {}
    ok, msg = executar(nombre, **args)
    print(f"[{'OK' if ok else 'ERROR'}] {msg}")
