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

// SIGTERM has no default Node handler, so without this the process exits
// immediately on `docker stop` / `compose down`, cutting off in-flight
// requests instead of letting them finish.
function shutdown(signal) {
  console.log(`${signal} received, closing server`);
  server.close(() => process.exit(0));
}

process.on('SIGTERM', () => shutdown('SIGTERM'));
process.on('SIGINT', () => shutdown('SIGINT'));

module.exports = server;
