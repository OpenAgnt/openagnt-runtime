/**
 * Minimal static file server for static/SPA releases (platform-owned).
 * Resolves every path inside the release root, serves index.html as the SPA
 * fallback, and never follows a path outside the root.
 */
import { extname, join, normalize, resolve } from "node:path";

const root = resolve(process.argv[2] ?? ".");
const port = Number(process.env.PORT ?? 3000);
const hostname = process.env.HOSTNAME ?? "0.0.0.0";

const MIME: Record<string, string> = {
  ".html": "text/html; charset=utf-8",
  ".js": "text/javascript; charset=utf-8",
  ".mjs": "text/javascript; charset=utf-8",
  ".css": "text/css; charset=utf-8",
  ".json": "application/json; charset=utf-8",
  ".svg": "image/svg+xml",
  ".png": "image/png",
  ".jpg": "image/jpeg",
  ".jpeg": "image/jpeg",
  ".webp": "image/webp",
  ".gif": "image/gif",
  ".ico": "image/x-icon",
  ".woff": "font/woff",
  ".woff2": "font/woff2",
  ".txt": "text/plain; charset=utf-8",
  ".map": "application/json; charset=utf-8",
};

function safePath(urlPath: string): string | null {
  const decoded = decodeURIComponent(urlPath.split("?")[0] ?? "/");
  const candidate = resolve(join(root, normalize(decoded)));
  if (candidate !== root && !candidate.startsWith(root + "/")) return null;
  return candidate;
}

const server = Bun.serve({
  port,
  hostname,
  async fetch(req) {
    const url = new URL(req.url);
    const path = safePath(url.pathname);
    if (!path) return new Response("Not found", { status: 404 });

    const file = Bun.file(path);
    if (await file.exists()) {
      if ((await file.stat()).isDirectory()) {
        const index = Bun.file(join(path, "index.html"));
        if (await index.exists()) {
          return new Response(index, {
            headers: { "content-type": "text/html; charset=utf-8" },
          });
        }
      } else {
        return new Response(file, {
          headers: {
            "content-type":
              MIME[extname(path).toLowerCase()] ?? "application/octet-stream",
          },
        });
      }
    }

    // SPA fallback (client-side routes) when index.html exists.
    const fallback = Bun.file(join(root, "index.html"));
    if (await fallback.exists()) {
      return new Response(fallback, {
        headers: { "content-type": "text/html; charset=utf-8" },
      });
    }
    return new Response("Not found", { status: 404 });
  },
});

console.log(`static server listening on ${hostname}:${server.port}`);
