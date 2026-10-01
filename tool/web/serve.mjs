import http from 'node:http';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const rootDir = path.resolve(__dirname, '..', '..');
const webDir = path.join(rootDir, 'example', 'build', 'web');

const mimeTypes = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'text/javascript; charset=utf-8',
  '.mjs': 'text/javascript; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.gif': 'image/gif',
  '.svg': 'image/svg+xml',
  '.wav': 'audio/wav',
  '.mp4': 'video/mp4',
  '.woff': 'application/font-woff',
  '.ttf': 'application/font-ttf',
  '.eot': 'application/vnd.ms-fontobject',
  '.otf': 'application/font-otf',
  '.wasm': 'application/wasm',
};

const basePath = '/animal-island-ui';

const server = http.createServer((req, res) => {
  let cleanUrl = (req.url || '/').split('?')[0];

  // Strip optional base path
  if (cleanUrl.startsWith(basePath)) {
    cleanUrl = cleanUrl.substring(basePath.length);
    if (!cleanUrl.startsWith('/')) {
      cleanUrl = '/' + cleanUrl;
    }
  }

  if (cleanUrl === '/' || cleanUrl === '') {
    cleanUrl = '/index.html';
  }

  let filePath = path.join(webDir, cleanUrl);

  fs.stat(filePath, (err, stats) => {
    if (err || !stats.isFile()) {
      filePath = path.join(webDir, 'index.html');
    }

    const extname = String(path.extname(filePath)).toLowerCase();
    const contentType = mimeTypes[extname] || 'application/octet-stream';

    fs.readFile(filePath, (error, content) => {
      if (error) {
        res.writeHead(404, { 'Content-Type': 'text/plain' });
        res.end('Not Found');
      } else {
        res.writeHead(200, {
          'Content-Type': contentType,
          'Cross-Origin-Opener-Policy': 'same-origin',
          'Cross-Origin-Embedder-Policy': 'require-corp',
        });
        res.end(content);
      }
    });
  });
});

const PORT = process.env.PORT || 8089;
server.listen(PORT, '127.0.0.1', () => {
  console.log(`Animal Island Gallery evidence server running at http://127.0.0.1:${PORT}${basePath}/`);
});
