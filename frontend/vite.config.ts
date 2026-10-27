import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

// BASE_PATH: subruta on es publica la web darrere d'un proxy (p. ex. `/parlaval`). Buida o sense definir = arrel.
const basePath = (process.env.BASE_PATH ?? '').replace(/\/+$/, '');

export default defineConfig({ base: `${basePath}/`, plugins: [react()] });
