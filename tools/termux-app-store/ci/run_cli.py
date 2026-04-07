import subprocess

commands = [
    ["python", "ci/run_termux_build.py"],
    ["python", "ci/run_tasctl.py"],
]

for cmd in commands:
    subprocess.check_call(cmd)
