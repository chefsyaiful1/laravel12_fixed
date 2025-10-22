/**
 * fix-manifest.js
 * -------------------------------------------------------
 * Ensures Laravel can find the Vite manifest at:
 *   public/build/manifest.json
 * after each "npm run build"
 * -------------------------------------------------------
 */

import { promises as fs } from "fs";
import path from "path";

async function run() {
  const root = process.cwd(); // should be laravel_core
  const buildDir = path.join(root, "public", "build");
  const viteManifestPath = path.join(buildDir, ".vite", "manifest.json");
  const manifestPath = path.join(buildDir, "manifest.json");

  try {
    // --- Case 1: manifest inside .vite ---
    await fs.access(viteManifestPath);
    const data = await fs.readFile(viteManifestPath, "utf8");
    await fs.writeFile(manifestPath, data, "utf8");
    console.log("✅  Manifest copied to:", manifestPath);

    // Optional cleanup
    try {
      const viteDir = path.join(buildDir, ".vite");
      const files = await fs.readdir(viteDir);
      for (const file of files) {
        await fs.unlink(path.join(viteDir, file));
      }
      await fs.rmdir(viteDir);
      console.log("🧹  Removed .vite directory");
    } catch {
      console.warn("⚠️  Could not remove .vite directory (not critical)");
    }
  } catch {
    // --- Case 2: manifest already correct ---
    try {
      await fs.access(manifestPath);
      console.log("✅  Manifest already present:", manifestPath);
    } catch {
      console.error("❌  No manifest found in .vite or build root!");
      process.exitCode = 2;
    }
  }

  console.log("✨  fix-manifest.js finished.");
}

run().catch((e) => {
  console.error("🔥  fix-manifest.js failed:", e);
  process.exitCode = 1;
});
