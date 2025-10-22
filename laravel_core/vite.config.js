import { defineConfig } from 'vite';
import laravel from 'laravel-vite-plugin';
import path from 'path';

export default defineConfig({
    plugins: [
        laravel({
            input: [
                'resources/css/app.css',
                'resources/js/app.js',
            ],
            refresh: true,
            buildDirectory: 'build',
        }),
    ],

    base: '/build/',

    build: {
        outDir: 'public/build',
        manifest: true,
        emptyOutDir: true,
        rollupOptions: {
            output: {
                assetFileNames: 'assets/[name]-[hash][extname]',
                chunkFileNames: 'assets/[name]-[hash].js',
                entryFileNames: 'assets/[name]-[hash].js',
            },
        },
    },

    server: {
        host: 'laravel12_fixed.test',
        port: 5173,
        origin: 'http://laravel12_fixed.test:5173',
        cors: true,
        strictPort: true,
        hmr: {
            host: 'laravel12_fixed.test',
            protocol: 'ws',
        },
    },

    resolve: {
        alias: {
            '@': path.resolve(__dirname, 'resources/js'),
        },
    },

    clearScreen: false,
});
