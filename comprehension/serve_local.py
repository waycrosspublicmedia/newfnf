from http.server import ThreadingHTTPServer, SimpleHTTPRequestHandler
from pathlib import Path
import socket
import webbrowser
root = Path(__file__).resolve().parent
class Handler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs): super().__init__(*args, directory=str(root), **kwargs)
    def end_headers(self):
        self.send_header("Cache-Control", "no-cache")
        super().end_headers()
server = None
for port in range(8000, 8050):
    try:
        server = ThreadingHTTPServer(("127.0.0.1", port), Handler)
        break
    except OSError: pass
if server is None: raise SystemExit("No local port available between 8000 and 8049.")
url = f"http://127.0.0.1:{server.server_port}/"
print("Open " + url + " — keep this window open while playing.", flush=True)
webbrowser.open(url)
try: server.serve_forever()
except KeyboardInterrupt: server.server_close()
