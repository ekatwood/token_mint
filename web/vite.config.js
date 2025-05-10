// web/vite.config.js
import { defineConfig } from 'vite';

export default defineConfig({
    build: {
        rollupOptions: {
            input: {
                main: 'web/javascript/solflare_utils.js', // Entry point
            },
            output: {
                dir: 'build/web', // Output directory (important!)
                format: 'es',     // Use ES modules
                entryFileNames: 'js/[name].js', // Output file name structure
                chunkFileNames: 'js/chunk-[hash].js',
                assetFileNames: 'assets/[name]-[hash][extname]',
            },
        },
        manifest: true, // For Flutter
    },
});