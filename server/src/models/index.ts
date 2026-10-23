import mongoose, { Schema } from 'mongoose';
import { v4 as uuidv4 } from 'uuid';

const options = { strict: false, versionKey: false, minimize: false } as const;
function makeModel(name: string, collection: string, fields: Record<string, unknown>, idType: typeof String | typeof Number = Number): any {
  const schema = new Schema({ id: { type: idType, required: true, unique: true, index: true }, ...fields }, options);
  return mongoose.models[name] || mongoose.model(name, schema, collection);
}

export const Role = makeModel('Role', 'roles', { name: { type: String, required: true, unique: true }, description: String, created_at: Date });
export const User = makeModel('User', 'users', { id: { type: String, default: uuidv4, unique: true, index: true }, email: { type: String, required: true, unique: true, lowercase: true, trim: true }, password: { type: String, required: true, select: false }, first_name: { type: String, required: true }, last_name: { type: String, required: true }, role_id: { type: Number, required: true, index: true }, is_active: { type: Boolean, default: true }, last_login: Date, created_at: Date, updated_at: Date }, String);
export const Product = makeModel('Product', 'products', { name: String, code: { type: String, unique: true }, product_type: String, description: String, unit: String, is_active: Boolean, created_at: Date, updated_at: Date });
export const Machine = makeModel('Machine', 'machines', { machine_name: String, machine_code: { type: String, unique: true }, machine_type: String, production_line: String, status: String, operating_hours: Number, downtime_hours: Number, last_maintenance_date: Date, next_maintenance_date: Date, notes: String, created_at: Date, updated_at: Date });
export const RawMaterial = makeModel('RawMaterial', 'raw_materials', { material_name: String, material_code: { type: String, unique: true }, material_type: String, supplier: String, unit: String, current_stock: Number, minimum_stock_level: Number, maximum_stock_level: Number, cost_per_unit: Number, status: String, notes: String, created_at: Date, updated_at: Date });
export const StockHistory = makeModel('StockHistory', 'stock_history', {});
export const Batch = makeModel('Batch', 'production_batches', { id: { type: String, default: uuidv4, unique: true, index: true }, batch_number: { type: String, required: true, unique: true }, product_id: Number, machine_id: Number, operator_id: String, production_date: Date, planned_quantity: Number, produced_quantity: Number, rejected_quantity: Number, unit: String, start_time: Date, end_time: Date, status: String, quality_status: String, efficiency: Number, rejection_rate: Number, remarks: String, created_by: String, created_at: Date, updated_at: Date }, String);
export const BatchStatusHistory = makeModel('BatchStatusHistory', 'batch_status_history', {});
export const MaterialConsumption = makeModel('MaterialConsumption', 'material_consumption', {});
export const QualityParameter = makeModel('QualityParameter', 'quality_parameters', { parameter_name: String, parameter_code: { type: String, unique: true }, unit: String, is_critical: Boolean, description: String, is_active: Boolean, created_at: Date });
export const QualityTest = makeModel('QualityTest', 'quality_tests', {});
export const MachineDowntime = makeModel('MachineDowntime', 'machine_downtime', {});
export const MaintenanceRecord = makeModel('MaintenanceRecord', 'maintenance_records', {});
export const Alert = makeModel('Alert', 'alerts', { alert_type: String, severity: String, title: String, message: String, batch_id: String, machine_id: Number, material_id: Number, status: String, acknowledged_by: String, acknowledged_at: Date, resolved_at: Date, created_at: Date });

export const collections: Record<string, any> = {
  roles: Role, users: User, products: Product, machines: Machine, raw_materials: RawMaterial,
  stock_history: StockHistory, production_batches: Batch, batch_status_history: BatchStatusHistory,
  material_consumption: MaterialConsumption, quality_parameters: QualityParameter, quality_tests: QualityTest,
  machine_downtime: MachineDowntime, maintenance_records: MaintenanceRecord, alerts: Alert,
};

const Counter: any = mongoose.models.Counter || mongoose.model('Counter', new Schema({ _id: String, seq: { type: Number, default: 0 } }, { versionKey: false }), 'counters');
const uuidCollections = new Set(['users', 'production_batches']);

export async function initializeSequences(): Promise<void> {
  for (const [name, Model] of Object.entries(collections)) {
    if (uuidCollections.has(name)) continue;
    const last = await Model.findOne().sort({ id: -1 }).select({ id: 1 }).lean();
    await Counter.updateOne({ _id: name }, { $max: { seq: Number(last?.id || 0) } }, { upsert: true });
  }
}

export async function nextId(collection: string): Promise<number> {
  const counter = await Counter.findOneAndUpdate({ _id: collection }, { $inc: { seq: 1 } }, { new: true, upsert: true, setDefaultsOnInsert: true });
  return counter.seq;
}

export function plain(value: any): any {
  if (Array.isArray(value)) return value.map(plain);
  if (value === null || value === undefined || value instanceof Date) return value;
  if (typeof value.toObject === 'function') value = value.toObject({ virtuals: false });
  if (value && typeof value === 'object') {
    if (value._bsontype === 'ObjectId') return String(value);
    const out: Record<string, any> = {};
    for (const [key, child] of Object.entries(value)) if (key !== '_id' && key !== '__v') out[key] = plain(child);
    if (value._id && out.id === undefined) out.id = String(value._id);
    return out;
  }
  return value;
}
