const { test } = require('node:test');
const assert = require('node:assert/strict');
const http = require('node:http');

// A fixed, unusual port rather than 0: `Number(process.env.PORT) || 8080` in
// server.js treats 0 as falsy and would silently fall back to 8080, which
// smoke-test.sh may also be exercising.
process.env.PORT = '8098';
const server = require('../src/server.js');

const listening = server.listening
  ? Promise.resolve()
  : new Promise((resolve) => server.once('listening', resolve));

function request(path) {
  return new Promise((resolve, reject) => {
    const { port } = server.address();
    http
      .get(`http://127.0.0.1:${port}${path}`, (res) => {
        let body = '';
        res.on('data', (chunk) => {
          body += chunk;
        });
        res.on('end', () => resolve({ statusCode: res.statusCode, body }));
      })
      .on('error', reject);
  });
}

test.before(() => listening);

test('GET /healthz returns 200 with an ok status', async () => {
  const { statusCode, body } = await request('/healthz');
  assert.equal(statusCode, 200);
  assert.equal(JSON.parse(body).status, 'ok');
});

test('GET / returns 200 with a plain-text banner', async () => {
  const { statusCode, body } = await request('/');
  assert.equal(statusCode, 200);
  assert.match(body, /healthcheck-api is running/);
});

test('GET /nope returns 404', async () => {
  const { statusCode } = await request('/nope');
  assert.equal(statusCode, 404);
});

test.after(() => {
  server.close();
});
