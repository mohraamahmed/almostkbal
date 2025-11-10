/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: false, // تم تغييرها لتحسين الأداء
  swcMinify: true,
  output: 'standalone', // إضافة لتحسين الأداء في الإنتاج
  poweredByHeader: false, // إزالة رأس Powered-By للأمان
  typescript: {
    // !! WARN !!
    // Dangerously allow production builds to successfully complete even if
    // your project has type errors.
    // !! WARN !!
    ignoreBuildErrors: true,
  },
  eslint: {
    // Skip ESLint during builds
    ignoreDuringBuilds: true,
  },
  compiler: {
    removeConsole: process.env.NODE_ENV === 'production' ? {exclude: ['error', 'warn']} : false,
  },
  images: {
    formats: ['image/avif', 'image/webp'],
    remotePatterns: [
      {
        protocol: 'https',
        hostname: '**', // يسمح بالصور من أي مضيف
      },
    ],
  },
  experimental: {
    optimizeCss: false, // تعطيل لحل مشاكل CSS preload
    scrollRestoration: true,
    optimizePackageImports: ['react-icons'],
    serverActions: true,
    // تحسين تحميل الصفحات
    gzipSize: true,
  },
  // تعطيل preload للـ CSS لحل warning
  productionBrowserSourceMaps: false,
  webpack: (config, { isServer }) => {
    // حل مشاكل الـ chunks
    if (!isServer) {
      config.optimization.splitChunks = {
        chunks: 'all',
        cacheGroups: {
          default: {
            minChunks: 2,
            priority: -20,
            reuseExistingChunk: true,
          },
        },
      };
    }
    return config;
  },
  // إعدادات التخزين المؤقت
  onDemandEntries: {
    // للتطوير فقط
    maxInactiveAge: 25 * 1000,
    pagesBufferLength: 5,
  },
  // إعدادات الأمان
  headers: async () => {
    return [
      {
        source: '/:path*',
        headers: [
          {
            key: 'X-Content-Type-Options',
            value: 'nosniff',
          },
          {
            key: 'X-Frame-Options',
            value: 'DENY',
          },
          {
            key: 'X-XSS-Protection',
            value: '1; mode=block',
          },
        ],
      },
    ];
  },
}

module.exports = nextConfig
