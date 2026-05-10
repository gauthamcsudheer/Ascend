import type { Metadata } from 'next';

import '../styles/globals.css';

export const metadata: Metadata = {
  title: 'Ascend',
  description: 'Knowledge and mentorship platform for the RSET community.',
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
