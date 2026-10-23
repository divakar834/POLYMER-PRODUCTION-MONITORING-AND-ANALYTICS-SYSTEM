import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import morgan from 'morgan';
import rateLimit from 'express-rate-limit';
import dotenv from 'dotenv';
import path from 'path';

import mongoose from 'mongoose';
import { connectDatabase } from './database/mongo';
import { testRedisConnection } from './cache/redis';
import { errorHandler } from './middleware/errorHandler';
import { notFound } from './middleware/notFound';

import authRoutes from './routes/auth';
import userRoutes from './routes/users';
import batchRoutes from './routes/batches';
import materialRoutes from './routes/materials';
import consumptionRoutes from './routes/consumption';
import qualityRoutes from './routes/quality';
import machineRoutes from './routes/machines';
import analyticsRoutes from './routes/analytics';
import alertRoutes from './routes/alerts';
import productRoutes from './routes/products';
import setupRoutes from './routes/setup';

dotenv.config({ path: path.resolve(__dirname, '../../.env') });

const app = express();
const PORT = process.env.PORT || 5000;

if (!process.env.JWT_SECRET || process.env.JWT_SECRET.length < 32) {
  throw new Error('JWT_SECRET must be set to a random value of at least 32 characters.');
}

// ── Security middleware ──────────────────────────────────
app.use(helmet());
app.use(cors({
  origin: process.env.CLIENT_URL || 'http://localhost:3000',
  credentials: true,
}));

// ── Rate limiting ─────────────────────────────────────────
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 500,
  standardHeaders: true,
  legacyHeaders: false,
  message: { success: false, message: 'Too many requests, please try again later.' },
});
app.use('/api/', limiter);

// ── General middleware ────────────────────────────────────
app.use(compression());
app.use(morgan('combined'));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// ── Health check ──────────────────────────────────────────
app.get('/api/health', (_req, res) => {
  res.json({ status: mongoose.connection.readyState === 1 ? 'ok' : 'degraded', database: mongoose.connection.readyState === 1 ? 'connected' : 'disconnected', timestamp: new Date().toISOString(), service: 'Polymer Production System API' });
});

// ── Routes ────────────────────────────────────────────────
app.use('/api/auth',        authRoutes);
app.use('/api/users',       userRoutes);
app.use('/api/batches',     batchRoutes);
app.use('/api/materials',   materialRoutes);
app.use('/api/consumption', consumptionRoutes);
app.use('/api/quality',     qualityRoutes);
app.use('/api/machines',    machineRoutes);
app.use('/api/analytics',   analyticsRoutes);
app.use('/api/alerts',      alertRoutes);
app.use('/api/products',    productRoutes);
app.use('/api/setup',       setupRoutes);

// ── Error handling ────────────────────────────────────────
app.use(notFound);
app.use(errorHandler);

// ── Start server ──────────────────────────────────────────
async function startServer() {
  try {
    await connectDatabase();
    await testRedisConnection();
    app.listen(PORT, () => {
      console.log(`✅ Server running on http://localhost:${PORT}`);
      console.log(`📦 Environment: ${process.env.NODE_ENV || 'development'}`);
    });
  } catch (err) {
    console.error('❌ Failed to start server:', err);
    process.exit(1);
  }
}

startServer();

export default app;
