import dotenv from 'dotenv';
import path from 'path';
import mongoose from 'mongoose';
import { loadSampleData } from './sampleData';

dotenv.config({ path: path.resolve(__dirname, '../../../.env') });

async function setupDatabase(): Promise<void> {
  const uri = process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017/polymer_production';
  await mongoose.connect(uri, { serverSelectionTimeoutMS: 5000 });
  try {
    const result = await loadSampleData();
    console.log(`MongoDB is ready. Added ${result.inserted} sample records (${result.total} available).`);
  } finally { await mongoose.disconnect(); }
}

setupDatabase().catch((error) => { console.error(error.message || error); process.exitCode = 1; });
