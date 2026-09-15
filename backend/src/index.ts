import 'dotenv/config';
import express from 'express';
import cors from 'cors';
import { scenariosRouter } from './routes/scenarios.js';
import { ttsRouter } from './routes/tts.js';
import { sessionsRouter } from './routes/sessions.js';
import { turnRouter } from './routes/turn.js';

const app = express();
app.use(cors({
  origin: (origin, callback) => {
    // Allow requests with no origin (server-to-server, curl, etc.)
    if (!origin) return callback(null, true);
    // Allow any localhost origin (any port)
    if (/^https?:\/\/(localhost|127\.0\.0\.1)(:\d+)?$/.test(origin)) return callback(null, true);
    // Allow explicitly configured origins
    const allowed = process.env.FRONTEND_ORIGIN?.split(',') || [];
    if (allowed.includes(origin)) return callback(null, true);
    callback(new Error('Not allowed by CORS'));
  },
}));
app.use(express.json({ limit: '12mb' }));

app.get('/health', (_req, res) => res.json({ ok: true }));
app.use(scenariosRouter, ttsRouter, sessionsRouter, turnRouter);

app.listen(Number(process.env.PORT) || 3001, () => console.log('ParlaVal agent listening'));
