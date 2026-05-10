/** @type {import('next').NextConfig} */
const nextConfig = {
  typedRoutes: true,
  images: {
    remotePatterns: [],
  },
  // Lint runs via root flat config (`pnpm lint`), not next build.
  eslint: { ignoreDuringBuilds: true },
};

module.exports = nextConfig;
