import { defineConfig } from 'vite';
import { tanstackStart } from '@tanstack/start/plugin/vite';
import tsConfigPaths from 'vite-tsconfig-paths';

export default defineConfig({
  plugins: [tsConfigPaths(), tanstackStart()],
});
