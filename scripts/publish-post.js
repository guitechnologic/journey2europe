import fs from "fs";
import path from "path";

const draft = "content/drafts/current.mdx";
const postsDir = "content/posts";

if (!fs.existsSync(draft)) {
  console.error("Draft não encontrado");
  process.exit(1);
}

const content = fs.readFileSync(draft, "utf-8");

const title = content.match(/title:\s*"(.*)"/)?.[1];
const date = content.match(/date:\s*"(.*)"/)?.[1];

if (!title || !date) {
  console.error("title ou date ausente no frontmatter");
  process.exit(1);
}

const slug = title
  .toLowerCase()
  .normalize("NFD")
  .replace(/[\u0300-\u036f]/g, "")
  .replace(/[^a-z0-9]+/g, "-")
  .replace(/(^-|-$)/g, "");

const filename = `${date}-${slug}.mdx`;
const output = path.join(postsDir, filename);

if (fs.existsSync(output)) {
  console.error("Este post já foi publicado");
  process.exit(1);
}

fs.writeFileSync(output, content, "utf-8");

console.log("Post publicado:", filename);
