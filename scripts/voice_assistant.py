#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Asistente de voz IA para el rice de BSPWM (Kali).

Arquitectura:
  microfono -> Whisper API (STT)  -> texto
  texto    -> Claude API (LLM)    -> decide accion / responde
  respuesta-> espeak (TTS local)  -> hablada

Claude SOLO puede ejecutar acciones predefinidas de assistant_actions.py.
Las API keys se leen de variables de entorno (NO se guardan en el repo):
  ANTHROPIC_API_KEY  (Claude)
  OPENAI_API_KEY     (Whisper, solo para el modo voz)

Uso:
  python3 voice_assistant.py          # modo voz (Whisper + microfono)
  python3 voice_assistant.py --text   # modo texto (escribes tu)
  python3 voice_assistant.py "frase"  # texto directo
"""

import argparse
import os
import shlex
import subprocess
import sys
import tempfile
import time

# --- Dependencias opcionales (se importan dentro de las funciones) ---------

SYSTEM_PROMPT = """Eres un asistente de voz integrado en un entorno Linux BSPWM de Kali Linux, \
orientado a pentesting y personalizacion del rice.

Tienes acceso a unas pocas herramientas/acciones seguras y predefinidas. Cuando el usuario \
pida algo que coincida con una de tus acciones, usa esa herramienta y confirma el resultado. \
Cuando no coincida con ninguna accion, responde de forma breve y util (max 2-3 frases).

Siempre responde en espanol, de forma corta, directa y sin relleno."""


def get_env_keys():
    """Comprueba las API keys necesarias."""
    anth = os.environ.get("ANTHROPIC_API_KEY", "")
    openai = os.environ.get("OPENAI_API_KEY", "")
    return anth, openai


def espeak_tts(texto):
    """Sintetiza texto con espeak (local, gratis)."""
    try:
        subprocess.run(
            ["espeak", f'"{texto}"'],
            capture_output=True,
            timeout=60,
            check=False,
        )
        return True
    except Exception:  # noqa: BLE001
        return False


def notificar(texto):
    """Muestra un aviso y sintetiza voz si es posible."""
    print(f"\n[IA] {texto}")
    espeak_tts(texto)


def capturar_voz_whisper(openai_key):
    """Captura audio del microfono y lo transcribe con Whisper API."""
    import openai  # pip install openai
    from openai import OpenAI

    client = OpenAI(api_key=openai_key)

    # Grabar con arecord (ALSA) a un archivo temporal
    tmp = tempfile.mktemp(suffix=".mp3")
    print("[*] Escuchando... (habla, Ctrl+C para terminar)")
    try:
        rc = subprocess.run(
            [
                "arecord", "-f", "S16_LE", "-r", "16000", "-c", "1",
                "-d", "6", tmp,
            ],
            capture_output=True,
            check=False,
        )
        if rc.returncode != 0:
            notificar("No pude capturar audio (arecord). Prueba el modo texto.")
            return ""
    except FileNotFoundError:
        notificar("arecord no esta instalado. Instala con: sudo apt install alsa-utils")
        return ""

    try:
        with open(tmp, "rb") as fh:
            transcript = client.audio.transcriptions.create(
                model="whisper-1",
                file=fh,
                language="es",
            )
        return (transcript.text or "").strip()
    except Exception as exc:  # noqa: BLE001
        notificar(f"Error transcribiendo: {exc}")
        return ""
    finally:
        try:
            os.remove(tmp)
        except OSError:
            pass


def preguntar_claude(anthripic_key, user_input):
    """Envia a Claude y procesa el tool-calling. Devuelve (respuesta, accion_usada)."""
    import assistant_actions as actions  # importacion local (mismo dir)
    from anthropic import Anthropic

    client = Anthropic(api_key=anthripic_key)

    tools = actions.get_tools()

    messages = [{"role": "user", "content": user_input}]
    respuesta_texto = ""
    accion = ""
    max_turns = 3

    for _ in range(max_turns):
        try:
            resp = client.messages.create(
                model="claude-sonnet-4-20250514",
                max_tokens=500,
                system=SYSTEM_PROMPT,
                messages=messages,
                tools=tools,
            )
        except Exception as exc:  # noqa: BLE001
            return f"Error de API (Claude): {exc}", ""

        # Procesar bloques
        stop_reason = getattr(resp, "stop_reason", "")
        tool_uses = [b for b in resp.content if b.type == "tool_use"]
        text_blocks = [b for b in resp.content if b.type == "text"]

        for tb in text_blocks:
            respuesta_texto += tb.text

        if not tool_uses:
            break

        # Ejecutar todas las herramientas solicitadas
        for tu in tool_uses:
            accion = tu.name
            name = tu.name
            arguments = tu.input or {}
            ok, msg = actions.executar(name, **arguments)
            notificar(f"Accion '{name}': {msg}")
            messages.append(
                {
                    "role": "assistant",
                    "content": resp.content,
                }
            )
            messages.append(
                {
                    "role": "user",
                    "content": [
                        {
                            "type": "tool_result",
                            "tool_use_id": tu.id,
                            "content": str(msg),
                        }
                    ],
                }
            )
    return (respuesta_texto.strip() or "Listo."), accion


def main():
    parser = argparse.ArgumentParser(description="Asistente de voz IA")
    parser.add_argument(
        "--text", action="store_true", help="Modo texto (escribes tu peticion)"
    )
    parser.add_argument("frase", nargs="?", help="Peticion directa")
    args = parser.parse_args()

    # Pre-cargar acciones (solo valida que el modulo este bien)
    sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
    try:
        import assistant_actions  # noqa: F401
    except Exception as exc:  # noqa: BLE001
        print(f"ERROR cargando assistant_actions.py: {exc}")
        sys.exit(1)

    anth_key, openai_key = get_env_keys()

    if not anth_key:
        print("ERROR: falta ANTHROPIC_API_KEY en el entorno.")
        print("  export ANTHROPIC_API_KEY=tu_clave")
        sys.exit(1)

    # Modo texto: no necesita Whisper
    if args.text or args.frase:
        user_input = args.frase or input("Escribe tu peticion: ")
        if not user_input:
            sys.exit(0)
        resp, accion = preguntar_claude(anth_key, user_input)
        print(f"\n[IA] {resp}")
        return

    # Modo voz
    if not openai_key:
        print("ERROR: modo voz requiere OPENAI_API_KEY (Whisper).")
        print("  export OPENAI_API_KEY=tu_clave   (o usa --text)")
        sys.exit(1)

    print("=== Asistente de voz IA ===")
    print("Habla. (Ctrl+C para salir)\n")
    while True:
        try:
            texto = capturar_voz_whisper(openai_key)
            if not texto:
                time.sleep(1)
                continue
            print(f"\n[Tú] {texto}")
            resp, accion = preguntar_claude(anth_key, texto)
            notificar(resp)
            print()
        except KeyboardInterrupt:
            print("\nSaliendo...")
            break
    return 0


if __name__ == "__main__":
    sys.exit(main())
