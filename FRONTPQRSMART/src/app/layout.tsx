import type { Metadata } from "next";
import { Geist, Geist_Mono } from "next/font/google";
import "./globals.css";
import I18nProvider from "./providers/I18nProvider";
import TokenWatcher from "./utils/auth/TokenWatcher";

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
});

export const metadata: Metadata = {
  title: "PQRSmart",
  description:
    "PQRSmart - Efficiently Manage Your Petitions, Complaints, Claims, and Suggestions",
  other: {
    google: "notranslate", // 👈 Desactiva el traductor
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" translate="no">
      <body
        className={`${geistSans.variable} ${geistMono.variable} antialiased`}
      >
        <TokenWatcher />
        <I18nProvider>{children}</I18nProvider>
      </body>
    </html>
  );
}
