# SPDX-FileCopyrightText: Chris Braun (cryzed) <cryzed@googlemail.com>
# SPDX-License-Identifier: GPL-3.0-or-later
"""Adapted from qutebrowser v3.7.0's qute-bitwarden userscript.

Run `bw login` once in a terminal. Sessions stay in the kernel keyring for
15 minutes; filling uses a private file instead of logged fake-key commands.
"""

import argparse
import json
import os
from pathlib import Path
import shlex
import shutil
import signal
import stat
import subprocess
import tempfile
import time
from urllib.parse import unquote, urlsplit


KEY_NAME = "qutebrowser-bitwarden-session"
LOCK_SECONDS = 900


class Cancelled(Exception):
    pass


class VaultError(Exception):
    pass


def run(command, *, stdin=None, env=None, timeout=30):
    return subprocess.run(
        command,
        input=stdin,
        env=env,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        timeout=timeout,
        check=False,
    )


def qute_command(command):
    # A browser which has exited must not leave us blocked opening its FIFO.
    fd = os.open(os.environ["QUTE_FIFO"], os.O_WRONLY | os.O_NONBLOCK)
    with os.fdopen(fd, "w", encoding="utf-8") as fifo:
        fifo.write(command + "\n")


def unlock_password():
    reply = run(
        ["pinentry-gnome3"],
        stdin=(
            "SETTITLE Bitwarden\n"
            "SETDESC Unlock Bitwarden for qutebrowser\n"
            "SETPROMPT Master password:\nGETPIN\nBYE\n"
        ),
        timeout=120,
    )
    for line in reply.stdout.splitlines():
        if line.startswith("D "):
            return unquote(line[2:])
    raise Cancelled


def session_key():
    existing = run(["keyctl", "search", "@s", "user", KEY_NAME])
    if existing.returncode == 0:
        key_id = existing.stdout.strip()
        cached = run(["keyctl", "pipe", key_id])
        if cached.returncode == 0 and cached.stdout:
            return key_id, cached.stdout

    status = run(["bw", "status"])
    if status.returncode != 0 or json.loads(status.stdout).get("status") == "unauthenticated":
        raise VaultError("Run bw login in a terminal first")
    unlocked = run(
        ["bw", "unlock", "--raw", "--passwordenv", "BW_MASTERPASS", "--nointeraction"],
        env={**os.environ, "BW_MASTERPASS": unlock_password()},
        timeout=60,
    )
    if unlocked.returncode != 0 or not unlocked.stdout.strip():
        raise VaultError("Could not unlock the vault")
    session = unlocked.stdout.strip()
    # padd reads the key payload from stdin, unlike keyctl add's argv payload.
    # The session keyring gives child processes possession and expiry rights.
    stored = run(["keyctl", "padd", "user", KEY_NAME, "@s"], stdin=session)
    if stored.returncode != 0:
        raise VaultError("Could not cache the session in the kernel keyring")
    key_id = stored.stdout.strip()
    if run(["keyctl", "timeout", key_id, str(LOCK_SECONDS)]).returncode != 0:
        run(["keyctl", "revoke", key_id])
        raise VaultError("Could not set the session expiry")
    return key_id, session


def vault_command(arguments, key_id, session):
    result = run(
        ["bw", *arguments, "--nointeraction"],
        env={**os.environ, "BW_SESSION": session},
    )
    if result.returncode != 0:
        run(["keyctl", "revoke", key_id])
        raise VaultError("Vault request failed; retry to unlock again")
    return result.stdout


def origin(url):
    try:
        parsed = urlsplit(url)
        if parsed.scheme not in ("http", "https") or not parsed.hostname:
            return None
        return parsed.scheme, parsed.hostname.lower(), parsed.port or (443 if parsed.scheme == "https" else 80)
    except ValueError:
        return None


def choose_login(url, key_id, session):
    matches = json.loads(vault_command(["list", "items", "--url", url], key_id, session))
    # Also require an exact origin: never broaden filling to a parent domain.
    matches = [
        entry for entry in matches
        if entry.get("login") and any(
            uri.get("match") != 5 and origin(uri.get("uri") or "") == origin(url)
            for uri in entry["login"].get("uris") or []
        )
    ]
    if not matches:
        raise VaultError("No login with a matching site URL")
    labels = [
        f"{index + 1}: {entry.get('name', '')} | {entry['login'].get('username') or ''}"
        for index, entry in enumerate(matches)
    ]
    labels = [" ".join(label.splitlines()) for label in labels]
    choice = run(["wmenu", "-i", "-p", "Bitwarden"], stdin="\n".join(labels), timeout=120)
    if choice.returncode != 0 or not choice.stdout.strip():
        raise Cancelled
    try:
        return matches[labels.index(choice.stdout.rstrip("\n"))]
    except ValueError:
        raise Cancelled from None


def fill_login(payload):
    runtime = Path(os.environ["XDG_RUNTIME_DIR"])
    permissions = runtime.stat()
    if permissions.st_uid != os.getuid() or stat.S_IMODE(permissions.st_mode) & 0o077:
        raise VaultError("XDG_RUNTIME_DIR must be private to your user")
    template = Path(__file__).with_name("fill.js").read_text(encoding="utf-8")
    with tempfile.TemporaryDirectory(prefix="qute-bitwarden-", dir=runtime) as directory:
        path = Path(directory) / "fill.js"
        with path.open("x", encoding="utf-8") as output:
            os.chmod(path, 0o600)
            output.write(template.replace("/*__LOGIN__*/", json.dumps(payload, ensure_ascii=True)))
        # jseval reads the file synchronously before the next command can run.
        # Keep a 30-second fallback for browser exit or an interrupted command.
        qute_command("\n".join([
            "jseval --file --quiet " + shlex.quote(str(path)),
            "spawn -- " + shlex.quote(shutil.which("rm")) + " -- " + shlex.quote(str(path)),
        ]))
        deadline = time.monotonic() + 30
        while path.exists() and time.monotonic() < deadline:
            time.sleep(0.1)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    modes = parser.add_mutually_exclusive_group()
    modes.add_argument("--username-only", action="store_true")
    modes.add_argument("--password-only", action="store_true")
    modes.add_argument("--totp-only", action="store_true")
    args = parser.parse_args()
    os.umask(0o077)
    url = os.environ.get("QUTE_URL", "")
    if not origin(url):
        raise VaultError("Open an HTTP or HTTPS login page first")
    key_id, session = session_key()
    selected = choose_login(url, key_id, session)
    mode = "login"
    credentials = selected["login"]
    if args.totp_only:
        mode = "totp"
        if not credentials.get("totp"):
            raise VaultError("This login has no TOTP configured")
        value = vault_command(["get", "totp", selected["id"]], key_id, session).strip()
    elif args.username_only:
        mode, value = "username", credentials.get("username") or ""
    elif args.password_only:
        mode, value = "password", credentials.get("password") or ""
    else:
        value = {
            "username": credentials.get("username") or "",
            "password": credentials.get("password") or "",
        }
    fill_login({"url": url, "mode": mode, "value": value})


def interrupted(_signal, _frame):
    raise Cancelled


if __name__ == "__main__":
    for signum in (signal.SIGTERM, signal.SIGINT, signal.SIGHUP):
        signal.signal(signum, interrupted)
    try:
        main()
    except Cancelled:
        pass
    except Exception as error:
        # Never echo subprocess output, credential values, or a traceback.
        reason = str(error) if isinstance(error, VaultError) else "Request failed or timed out"
        try:
            qute_command("message-error " + shlex.quote("Bitwarden: " + reason))
        except OSError:
            pass
