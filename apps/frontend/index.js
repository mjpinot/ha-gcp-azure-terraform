import express from "express";

const app = express();
const PORT = process.env.PORT || 3000;

app.get("/healthz", (_req, res) => res.json({ status: "ok" }));

app.get("/", (_req, res) => {
  res.send(`<!doctype html>
<html lang="en">
<head><meta charset="utf-8"><title>HA App</title></head>
<body><h1>Frontend</h1><p>Multi-cloud HA — <a href="/api/healthz">/api/healthz</a></p></body>
</html>`);
});

app.listen(PORT, () => console.log(`frontend listening on ${PORT}`));
