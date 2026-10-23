import fs from 'fs';
import path from 'path';
import { collections, initializeSequences } from '../models';

export type SampleLoadSummary = { total: number; inserted: number; collections: Record<string, { total: number; inserted: number }> };

export async function loadSampleData(): Promise<SampleLoadSummary> {
  const file = path.resolve(__dirname, '../../../database/seed.json');
  const dataset = JSON.parse(fs.readFileSync(file, 'utf8')) as Record<string, any[]>;
  const summary: SampleLoadSummary = { total: 0, inserted: 0, collections: {} };
  for (const [name, Model] of Object.entries(collections)) {
    const records = dataset[name] || [];
    let inserted = 0;
    if (records.length) {
      const result = await Model.bulkWrite(records.map((record) => ({ updateOne: { filter: { id: record.id }, update: { $setOnInsert: record }, upsert: true } })), { ordered: true });
      inserted = result.upsertedCount;
    }
    summary.collections[name] = { total: records.length, inserted };
    summary.total += records.length;
    summary.inserted += inserted;
  }
  await initializeSequences();
  return summary;
}
