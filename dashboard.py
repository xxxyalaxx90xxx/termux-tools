#!/usr/bin/env python3
"""
Bratucha's Web Dashboard v1.0
Simple HTTP server with Termux tool management UI
"""

import http.server
import json
import os
import subprocess
import socketserver

PORT = 8080
HOME = os.path.expanduser("~")

TOOLS = [
    {"name": "Writer Tool", "cmd": "writer", "cat": "Writing"},
    {"name": "System Tune", "cmd": "system-tune", "cat": "System"},
    {"name": "Lazymux", "cmd": "lazymux", "cat": "Collections"},
    {"name": "Wolkansec", "cmd": "wolkansec", "cat": "Collections"},
    {"name": "M4t01 Launcher", "cmd": "m4t01", "cat": "Collections"},
    {"name": "SL Store", "cmd": "slstore", "cat": "Collections"},
    {"name": "App Store", "cmd": "tas", "cat": "Collections"},
    {"name": "CLI Manager", "cmd": "tcm", "cat": "System"},
    {"name": "Matrix Rain", "cmd": "matrix-rain", "cat": "Fun"},
    {"name": "AI Dashboard", "cmd": "ai-dash", "cat": "AI"},
    {"name": "AI Hub", "cmd": "ai-hub", "cat": "AI"},
    {"name": "Speed Boost", "cmd": "speed-boost", "cat": "System"},
    {"name": "Phone Tune", "cmd": "phone-tune", "cat": "System"},
]

def get_system_info():
    try:
        ram = subprocess.check_output("free -h 2>/dev/null | grep Mem | awk '{print $3\"/\"$2}'", shell=True).decode().strip()
    except:
        ram = "N/A"
    try:
        home = subprocess.check_output(f"du -sh {HOME} 2>/dev/null | cut -f1", shell=True).decode().strip()
    except:
        home = "N/A"
    try:
        batt = subprocess.check_output("cat /sys/class/power_supply/battery/capacity 2>/dev/null", shell=True).decode().strip()
    except:
        batt = "N/A"
    try:
        cpu = subprocess.check_output("nproc 2>/dev/null", shell=True).decode().strip()
    except:
        cpu = "N/A"
    return {"ram": ram, "home": home, "battery": batt, "cpu": cpu}

HTML = """<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Bratucha Dashboard</title>
<style>
* { margin: 0; padding: 0; box-sizing: border-box; }
body { font-family: system-ui, sans-serif; background: #0f172a; color: #e2e8f0; }
header { background: linear-gradient(135deg, #1e293b, #334155); padding: 1.5rem; text-align: center; border-bottom: 2px solid #3b82f6; }
header h1 { font-size: 1.5rem; color: #60a5fa; }
.stats { display: grid; grid-template-columns: repeat(auto-fit, minmax(140px, 1fr)); gap: 1rem; padding: 1rem; }
.stat { background: #1e293b; padding: 1rem; border-radius: 8px; text-align: center; }
.stat .label { color: #94a3b8; font-size: 0.8rem; }
.stat .value { color: #60a5fa; font-size: 1.2rem; font-weight: bold; }
.tools { padding: 1rem; }
.tools h2 { color: #60a5fa; margin-bottom: 1rem; }
.grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(180px, 1fr)); gap: 0.75rem; }
.tool { background: #1e293b; padding: 1rem; border-radius: 8px; border-left: 3px solid #3b82f6; }
.tool .name { font-weight: bold; margin-bottom: 0.25rem; }
.tool .cat { color: #94a3b8; font-size: 0.75rem; }
footer { padding: 1rem; text-align: center; color: #64748b; font-size: 0.8rem; }
</style>
</head>
<body>
<header><h1>🔥 Bratucha Dashboard</h1></header>
<div class="stats" id="stats"></div>
<div class="tools"><h2>📦 Tools ({count})</h2><div class="grid" id="tools"></div></div>
<footer>Termux Tools Collection v4.0 | Auto-refresh every 30s</footer>
<script>
const tools = {tools_json};
function renderStats(data) {{
    document.getElementById('stats').innerHTML =
        `<div class="stat"><div class="label">RAM</div><div class="value">${{data.ram}}</div></div>` +
        `<div class="stat"><div class="label">Home</div><div class="value">${{data.home}}</div></div>` +
        `<div class="stat"><div class="label">Battery</div><div class="value">${{data.battery}}%</div></div>` +
        `<div class="stat"><div class="label">CPU Cores</div><div class="value">${{data.cpu}}</div></div>`;
}}
function renderTools() {{
    document.getElementById('tools').innerHTML = tools.map(t =>
        `<div class="tool"><div class="name">${{t.name}}</div><div class="cat">${{t.cat}} | ${{t.cmd}}</div></div>`
    ).join('');
}}
renderTools();
fetch('/api/stats').then(r => r.json()).then(renderStats);
setInterval(() => fetch('/api/stats').then(r => r.json()).then(renderStats), 30000);
</script>
</body>
</html>"""

class Handler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/api/stats':
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            self.wfile.write(json.dumps(get_system_info()).encode())
        elif self.path == '/':
            self.send_response(200)
            self.send_header('Content-Type', 'text/html')
            self.end_headers()
            html = HTML.format(tools_json=json.dumps(TOOLS), count=len(TOOLS))
            self.wfile.write(html.encode())
        else:
            self.send_response(404)
            self.end_headers()

    def log_message(self, format, *args):
        pass

if __name__ == '__main__':
    with socketserver.TCPServer(("", PORT), Handler) as httpd:
        print(f"Dashboard: http://localhost:{PORT}")
        httpd.serve_forever()
