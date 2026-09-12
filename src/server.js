const http = require('node:http');

const PORT = Number(process.env.PORT) || 8080;

function handleRequest(req, res) {
  if (req.url === '/healthz') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ status: 'ok', uptimeSeconds: process.uptime() }));
    return;
  }

  if (req.url === '/') {
    res.writeHead(200, { 'Content-Type': 'text/plain' });
    res.end('healthcheck-api is running\n');
    return;
  }

  res.writeHead(404, { 'Content-Type': 'text/plain' });
  res.end('not found\n');
}

const server = http.createServer(handleRequest);

server.listen(PORT, () => {
  console.log(`healthcheck-api listening on port ${PORT}`);
});

module.exports = server;
