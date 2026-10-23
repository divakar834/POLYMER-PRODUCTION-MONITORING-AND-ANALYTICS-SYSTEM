import mongoose from 'mongoose';
import { loadSampleData } from './sampleData';

export async function connectDatabase(): Promise<void> {
  const uri = process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017/polymer_production';
  await mongoose.connect(uri, { serverSelectionTimeoutMS: 5000 });
  await mongoose.connection.db?.admin().ping();
  await loadSampleData();
}

export async function closeDatabase(): Promise<void> { await mongoose.disconnect(); }
