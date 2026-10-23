import { Router } from 'express';
import { authenticate, allowRoles } from '../middleware/auth';
import { loadSampleData } from '../database/sampleData';
import { sendSuccess } from '../utils/response';
import { collections, initializeSequences, nextId } from '../models';
import { v4 as uuidv4 } from 'uuid';

const excelFields: Record<string, string[]> = {
  products: ['id','name','code','product_type','description','unit','is_active','created_at','updated_at'],
  machines: ['id','machine_name','machine_code','machine_type','production_line','status','operating_hours','downtime_hours','last_maintenance_date','next_maintenance_date','notes','created_at','updated_at'],
  raw_materials: ['id','material_name','material_code','material_type','supplier','unit','current_stock','minimum_stock_level','maximum_stock_level','cost_per_unit','status','notes','created_at','updated_at'],
  production_batches: ['id','batch_number','product_id','machine_id','operator_id','production_date','planned_quantity','produced_quantity','rejected_quantity','unit','start_time','end_time','status','quality_status','efficiency','rejection_rate','remarks','created_by','created_at','updated_at'],
  material_consumption: ['id','batch_id','material_id','quantity_used','unit','consumption_date','operator_id','notes','created_at'],
  quality_parameters: ['id','parameter_name','parameter_code','unit','is_critical','description','is_active','created_at'],
  quality_tests: ['id','batch_id','parameter_id','tester_id','test_date','expected_value','actual_value','min_limit','max_limit','result','remarks','created_at','updated_at'],
  stock_history: ['id','material_id','change_type','quantity','stock_before','stock_after','reference_id','notes','performed_by','created_at'],
  batch_status_history: ['id','batch_id','old_status','new_status','changed_by','notes','created_at'],
  machine_downtime: ['id','machine_id','batch_id','start_time','end_time','duration_hours','reason','category','reported_by','notes','created_at'],
  maintenance_records: ['id','machine_id','maintenance_type','maintenance_date','performed_by','cost','description','parts_replaced','next_maintenance','status','created_by','created_at'],
  alerts: ['id','alert_type','severity','title','message','batch_id','machine_id','material_id','status','acknowledged_by','acknowledged_at','resolved_at','created_at'],
};
const uuidCollections = new Set(['production_batches']);

const r = Router();
r.use(authenticate, allowRoles('admin'));
r.get('/overview', async (_req, res, next) => {
  try {
    const entries = await Promise.all(Object.entries(collections).map(async ([name, Model]) => [name, await Model.countDocuments()] as const));
    sendSuccess(res, { collections: Object.fromEntries(entries) });
  } catch (error) { next(error); }
});
r.post('/sample-data', async (_req, res, next) => {
  try {
    const result = await loadSampleData();
    sendSuccess(res, result, result.inserted ? `Loaded ${result.inserted} missing sample records` : 'The sample dataset is already loaded');
  } catch (error) { next(error); }
});
r.post('/import-excel', async (req, res, next) => {
  try {
    const sheets = req.body?.sheets;
    if (!sheets || typeof sheets !== 'object' || Array.isArray(sheets)) return res.status(400).json({ success: false, message: 'Provide an Excel workbook with named data worksheets.' });
    const names = Object.keys(sheets), unknown = names.filter(name => !excelFields[name]);
    if (unknown.length) return res.status(400).json({ success: false, message: `Unsupported worksheet(s): ${unknown.join(', ')}` });
    const total = names.reduce((sum, name) => sum + (Array.isArray(sheets[name]) ? sheets[name].length : 0), 0);
    if (total < 1 || total > 2000) return res.status(400).json({ success: false, message: 'An import must contain between 1 and 2,000 data rows.' });
    const prepared: Record<string, any[]> = {};
    for (const name of names) {
      if (!Array.isArray(sheets[name])) return res.status(400).json({ success: false, message: `Worksheet ${name} must contain rows.` });
      const allowed = new Set(excelFields[name]);
      prepared[name] = [];
      for (const [index, row] of sheets[name].entries()) {
        if (!row || typeof row !== 'object' || Array.isArray(row)) return res.status(400).json({ success: false, message: `${name}, row ${index + 2} is invalid.` });
        const unexpected = Object.keys(row).filter(key => !allowed.has(key));
        if (unexpected.length) return res.status(400).json({ success: false, message: `${name}, row ${index + 2} has unsupported column(s): ${unexpected.join(', ')}` });
        const record: Record<string, any> = Object.fromEntries(Object.entries(row).filter(([, value]) => value !== '' && value !== null && value !== undefined));
        const required: Record<string, string[]> = { products: ['name','code'], machines: ['machine_name','machine_code','machine_type'], raw_materials: ['material_name','material_code','material_type'], production_batches: ['batch_number','product_id','planned_quantity'], material_consumption: ['batch_id','material_id','quantity_used'], quality_parameters: ['parameter_name','parameter_code'], quality_tests: ['batch_id','parameter_id','actual_value'], machine_downtime: ['machine_id','start_time','reason'], maintenance_records: ['machine_id','maintenance_type','maintenance_date','performed_by'], alerts: ['alert_type','severity','title','message'] };
        const missing = (required[name] || []).filter(key => record[key] === undefined || record[key] === '');
        if (missing.length) return res.status(400).json({ success: false, message: `${name}, row ${index + 2} is missing required column(s): ${missing.join(', ')}` });
        if (record.id === undefined) record.id = uuidCollections.has(name) ? uuidv4() : await nextId(name);
        if (typeof record.id === 'string' && !uuidCollections.has(name)) record.id = Number(record.id);
        if (!record.id || (typeof record.id === 'number' && !Number.isFinite(record.id))) return res.status(400).json({ success: false, message: `${name}, row ${index + 2} has an invalid ID.` });
        prepared[name].push(record);
      }
    }
    const imported: Record<string, { rows: number; inserted: number }> = {};
    for (const [name, records] of Object.entries(prepared)) {
      if (!records.length) continue;
      const result = await collections[name].bulkWrite(records.map(record => ({ updateOne: { filter: { id: record.id }, update: { $setOnInsert: record }, upsert: true } })), { ordered: true });
      imported[name] = { rows: records.length, inserted: result.upsertedCount };
    }
    await initializeSequences();
    const inserted = Object.values(imported).reduce((sum, result) => sum + result.inserted, 0);
    sendSuccess(res, { total, inserted, collections: imported }, `Imported ${inserted} new records; existing IDs were kept.`);
  } catch (error) { next(error); }
});
export default r;
