import "./globals.css";

export const metadata = {
  title: "Journey to Europe",
  description: "Blog e ferramentas para quem quer viver na Europa",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="pt-BR">
      <body>{children}</body>
    </html>
  );
}
