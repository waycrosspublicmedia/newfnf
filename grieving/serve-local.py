from http.server import ThreadingHTTPServer,SimpleHTTPRequestHandler
from pathlib import Path
import json,urllib.parse
ROOT=Path(__file__).resolve().parent
class Handler(SimpleHTTPRequestHandler):
    def __init__(self,*args,**kwargs):super().__init__(*args,directory=str(ROOT),**kwargs)
    def log_message(self,fmt,*args):
        if len(args)>1 and str(args[1])=='404':
            with (ROOT/'missing-requests.jsonl').open('a',encoding='utf-8') as out:out.write(json.dumps({'request':self.path})+'\n')
    def end_headers(self):
        self.send_header('Cache-Control','no-cache')
        super().end_headers()
print('Serving http://localhost:8000/',flush=True)
ThreadingHTTPServer(('127.0.0.1',8000),Handler).serve_forever()
