from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlsplit
import hashlib,json,re,sys
MANIFEST=Path(sys.argv[1])
PORT=int(sys.argv[2])
NAME='GCompris-PT-PT-Windows-x64.exe'
class Download(BaseHTTPRequestHandler):
    def do_HEAD(self): self.respond(False)
    def do_GET(self): self.respond(True)
    def respond(self,body):
        path=urlsplit(self.path).path
        meta=json.loads(MANIFEST.read_text(encoding='utf-8'))
        if path in ('/SHA256SUMS.txt','/version.json'):
            if path=='/SHA256SUMS.txt':data=(meta['sha256']+'  '+NAME+'\n').encode();mime='text/plain; charset=utf-8'
            else:data=(json.dumps({k:meta[k] for k in ('run','source','sha256','bytes')},indent=2)+'\n').encode();mime='application/json'
            self.send_response(200);self.send_header('Content-Type',mime);self.send_header('Content-Length',str(len(data)));self.send_header('Cache-Control','no-store');self.end_headers()
            if body:self.wfile.write(data)
            return
        if path not in ('/','/gcompris.exe','/'+NAME):self.send_error(404);return
        installer=Path(meta['installer']);size=meta['bytes'];etag='"'+meta['sha256']+'"'
        start=0;end=size-1;partial=False
        requested=self.headers.get('Range')
        if requested and self.headers.get('If-Range',etag)==etag:
            match=re.fullmatch(r'bytes=(\d+)-(\d*)',requested)
            if not match:self.invalid_range(size);return
            start=int(match[1]);end=min(int(match[2]),size-1) if match[2] else size-1
            if start>end or start>=size:self.invalid_range(size);return
            partial=True
        with installer.open('rb') as stream:
            if installer.stat().st_size!=size:self.send_error(503);return
            self.send_response(206 if partial else 200)
            self.send_header('Content-Type','application/octet-stream')
            self.send_header('Content-Disposition','attachment; filename="'+NAME+'"')
            self.send_header('Content-Length',str(end-start+1));self.send_header('Accept-Ranges','bytes')
            self.send_header('Cache-Control','no-store');self.send_header('ETag',etag)
            if partial:self.send_header('Content-Range',f'bytes {start}-{end}/{size}')
            self.end_headers()
            if not body:return
            try:
                stream.seek(start);remaining=end-start+1
                while remaining:
                    block=stream.read(min(1024*1024,remaining))
                    if not block:break
                    self.wfile.write(block);remaining-=len(block)
            except (BrokenPipeError,ConnectionResetError):pass
    def invalid_range(self,size):
        self.send_response(416);self.send_header('Content-Range',f'bytes */{size}');self.send_header('Content-Length','0');self.end_headers()
meta=json.loads(MANIFEST.read_text(encoding='utf-8'))
installer=Path(meta['installer'])
if installer.stat().st_size!=meta['bytes'] or hashlib.file_digest(installer.open('rb'),'sha256').hexdigest()!=meta['sha256']:
    raise ValueError('Installer differs from the verified manifest')
ThreadingHTTPServer(('127.0.0.1',PORT),Download).serve_forever()
