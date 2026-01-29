import { NextResponse } from "next/server";
import { generateEuropassHTML } from "@/lib/pdf/europass-template";
import { EuropassCV } from "@/lib/europass-types";
import { chromium } from "playwright";

export async function POST(req: Request) {
  const data: EuropassCV = await req.json();

  const html = generateEuropassHTML(data);

  const browser = await chromium.launch();
  const page = await browser.newPage();

  await page.setContent(html, { waitUntil: "load" });

  const pdf = await page.pdf({
    format: "A4",
    printBackground: true,
  });

  await browser.close();

  return new NextResponse(pdf, {
    headers: {
      "Content-Type": "application/pdf",
      "Content-Disposition": "attachment; filename=curriculo-europass.pdf",
    },
  });
}
