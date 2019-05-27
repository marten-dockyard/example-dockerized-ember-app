const express = require('express');
const fs = require('fs');
const path = require('path');

const assetsPath = 'dist';
const indexFile = fs.readFileSync(`${assetsPath}/index.html`, 'utf-8');
const fingerprintRegex = /-[a-f0-9]{32}/;

const app = express();

app.get('/healthcheck', (req, res) => {
  res.status(200).end('OK!');
});

// Serve static assets
app.use(
  express.static(assetsPath, {
    index: false,

    // Allow assets with a fingerprint to be cached for 1 year
    // Assets without fingerprint must be validated (no-cache)
    setHeaders(res, filepath) {
      if (fingerprintRegex.test(path.basename(filepath))) {
        res.set('Cache-Control', 'public, max-age=31536000');
      } else {
        res.set('Cache-Control', 'no-cache');
      }
    }
  })
);

// Wildcard route that serves index.html
app.get('*', (req, res, next) => {
  if (req.accepts('html') && !req.path.startsWith('/assets/')) {
    res.set('Cache-Control', 'no-cache');
    res.send(indexFile);
  } else {
    next();
  }
});

app.listen(8080);
