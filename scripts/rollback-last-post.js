import fs from "fs";
import path from "path";

const postsDir = "content/posts";

const posts = fs
  .readdirSync(postsDir)
  .filter(f => f.endsWith(".mdx"))
  .sort();

if (posts.length === 0) {
  console.log("Nenhum post para remover");
  process.exit(0);
}

const last = posts[posts.length - 1];
fs.unlinkSync(path.join(postsDir, last));

console.log("Último post removido:", last);
