const fs = require("node:fs");
const path = require("node:path");

const rootDir = path.resolve(__dirname, "..");
const distDir = path.join(rootDir, "dist");
const assetsDir = path.join(distDir, "assets");
const cliDir = path.join(rootDir, "cli");

fs.rmSync(assetsDir, { recursive: true, force: true });
fs.mkdirSync(assetsDir, { recursive: true });

fs.cpSync(path.join(cliDir, "template"), path.join(assetsDir, "template"), {
  recursive: true,
});
fs.cpSync(
  path.join(cliDir, "system-prompt"),
  path.join(assetsDir, "system-prompt"),
  { recursive: true }
);

const binPath = path.join(distDir, "feai");
if (fs.existsSync(binPath)) {
  fs.chmodSync(binPath, 0o755);
}
