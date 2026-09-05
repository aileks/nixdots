import os
from pathlib import Path
import shutil
import signal
import select
import subprocess
import tempfile
import unittest


SCRIPT = Path(__file__).resolve().parents[1] / "bin/screenrecord"


class ScreenrecordTests(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory()
        self.addCleanup(temporary.cleanup)
        self.directory = Path(temporary.name)
        self.bin = self.directory / "bin"
        self.bin.mkdir()
        self.state = self.directory / "screenrecord.state"
        self.env = os.environ | {
            "PATH": f"{self.bin}:{os.environ['PATH']}",
            "XDG_RUNTIME_DIR": str(self.directory),
            "XDG_VIDEOS_DIR": str(self.directory),
            "MOCK_NOTIFICATIONS": str(self.directory / "notifications"),
        }
        # A real executable exercises /proc identity and SIGINT handling.
        recorder = self.directory / "recorder.c"
        recorder.write_text("""
#include <signal.h>
#include <stdio.h>
#include <unistd.h>
static void stop(int unused) { _exit(0); }
int main(int argc, char **argv) {
    signal(SIGINT, stop);
    FILE *file = fopen(argv[argc - 1], "w");
    if (!file) return 1;
    fputs("recording", file);
    fclose(file);
    for (;;) pause();
}
""")
        subprocess.run(["cc", recorder, "-o", self.bin / "gpu-screen-recorder"], check=True)
        self.mock("xdg-user-dir", "exit 1")
        self.mock("notify-send", 'printf "%s\\n" "$*" >> "$MOCK_NOTIFICATIONS"')
        self.mock("slop", 'echo "640x480+0+0"')
        self.addCleanup(self.stop_recorder)

    def mock(self, name, body):
        command = self.bin / name
        command.write_text(f"#!{shutil.which('bash')}\n{body}\n")
        command.chmod(0o755)

    def run_script(self, *args):
        with tempfile.TemporaryFile() as errors:
            result = subprocess.run(
                ["bash", SCRIPT, *args], env=self.env,
                stdout=subprocess.DEVNULL, stderr=errors, timeout=10,
            )
            errors.seek(0)
            result.stderr = errors.read()
            return result

    def stop_recorder(self):
        if self.state.exists():
            pid = int(self.state.read_text().splitlines()[0])
            try:
                os.kill(pid, signal.SIGTERM)
            except ProcessLookupError:
                pass

    def test_start_stop_releases_lock_and_reports_saved_file(self):
        started = self.run_script("region")
        self.assertEqual(started.returncode, 0, started.stderr)
        self.assertEqual(self.run_script("status").returncode, 0)
        stopped = self.run_script("stop")
        self.assertEqual(stopped.returncode, 0, stopped.stderr)
        self.assertFalse(self.state.exists())
        self.assertIn("Recording saved", (self.directory / "notifications").read_text())

    def test_concurrent_start_does_not_open_another_selector(self):
        # Hold the first selection open until the competing invocation has finished.
        read_fd, write_fd = os.pipe()
        self.addCleanup(os.close, read_fd)
        self.addCleanup(os.close, write_fd)
        self.mock("slop", f'echo ready >&{write_fd}; read -r answer; exit 1')
        with subprocess.Popen(
            ["bash", SCRIPT, "region"], env=self.env,
            stdin=subprocess.PIPE, stdout=subprocess.DEVNULL,
            stderr=subprocess.PIPE, pass_fds=(write_fd,),
        ) as first:
            try:
                self.assertTrue(select.select([read_fd], [], [], 5)[0], "selector did not start")
                self.assertEqual(os.read(read_fd, 6), b"ready\n")
                self.assertNotEqual(self.run_script("region").returncode, 0)
            finally:
                first.communicate(b"cancel\n", timeout=5)
        self.assertFalse(self.state.exists())

    def test_stale_state_cannot_signal_an_unrelated_process(self):
        with subprocess.Popen(["sleep", "30"]) as unrelated:
            try:
                start_time = Path(f"/proc/{unrelated.pid}/stat").read_text().split()[21]
                self.state.write_text(f"{unrelated.pid}\n{start_time}\nunused.mp4\n")
                self.assertNotEqual(self.run_script("status").returncode, 0)
                self.assertEqual(self.run_script("stop").returncode, 0)
                self.assertIsNone(unrelated.poll())
            finally:
                unrelated.terminate()


if __name__ == "__main__":
    unittest.main()
