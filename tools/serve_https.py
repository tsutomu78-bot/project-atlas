"""Serve build/web over HTTPS for phone camera testing.

getUserMedia (the barcode scanner's camera access) requires a secure
context. localhost qualifies, but a phone reaching this PC over LAN does
not — so phone testing needs HTTPS (this script) or `adb reverse` (see
below, simpler if USB debugging is available).

Usage (from the repo root):
  1. One-time: generate a self-signed cert (openssl ships with Git Bash):
       openssl req -x509 -newkey rsa:2048 -nodes -days 365 \
         -keyout tools/dev-key.pem -out tools/dev-cert.pem \
         -subj "/CN=project-atlas-dev"
  2. py tools/serve_https.py
  3. On the phone (same Wi-Fi): https://<this PC's LAN IP>:5758
     Chrome will warn about the self-signed cert — Advanced > Proceed.
     Camera permission then works normally.

Alternative without certs (needs adb + USB debugging enabled):
  adb reverse tcp:5757 tcp:5757
  ...then the phone's own http://localhost:5757 serves the app and IS a
  secure context. Preferred when adb is available.
"""
import http.server
import ssl
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent / "build" / "web"
CERT = Path(__file__).resolve().parent / "dev-cert.pem"
KEY = Path(__file__).resolve().parent / "dev-key.pem"
PORT = 5758

if not CERT.exists() or not KEY.exists():
    raise SystemExit(
        "Missing tools/dev-cert.pem / dev-key.pem — run the openssl command "
        "in this file's docstring first."
    )


class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=str(ROOT), **kwargs)


ctx = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
ctx.load_cert_chain(certfile=str(CERT), keyfile=str(KEY))
httpd = http.server.ThreadingHTTPServer(("0.0.0.0", PORT), Handler)
httpd.socket = ctx.wrap_socket(httpd.socket, server_side=True)
print(f"Serving {ROOT} at https://0.0.0.0:{PORT} (self-signed)")
httpd.serve_forever()
