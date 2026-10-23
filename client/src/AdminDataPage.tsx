import { ChangeEvent, useEffect, useMemo, useState } from 'react';
import { Database, Download, FileSpreadsheet, FileUp, RefreshCw, ShieldCheck, Upload } from 'lucide-react';
import * as XLSX from 'xlsx';

const API = import.meta.env.VITE_API_URL || 'http://localhost:5000/api';
const templates: Record<string, string[]> = {
  products: ['id', 'name', 'code', 'product_type', 'description', 'unit', 'is_active'],
  machines: ['id', 'machine_name', 'machine_code', 'machine_type', 'production_line', 'status', 'operating_hours', 'downtime_hours'],
  raw_materials: ['id', 'material_name', 'material_code', 'material_type', 'supplier', 'unit', 'current_stock', 'minimum_stock_level', 'maximum_stock_level', 'cost_per_unit', 'status'],
  production_batches: ['id', 'batch_number', 'product_id', 'machine_id', 'operator_id', 'production_date', 'planned_quantity', 'produced_quantity', 'rejected_quantity', 'unit', 'status', 'quality_status', 'efficiency', 'rejection_rate', 'remarks'],
  material_consumption: ['id', 'batch_id', 'material_id', 'quantity_used', 'unit', 'consumption_date', 'operator_id', 'notes'],
  quality_parameters: ['id', 'parameter_name', 'parameter_code', 'unit', 'is_critical', 'description', 'is_active'],
  quality_tests: ['id', 'batch_id', 'parameter_id', 'tester_id', 'test_date', 'expected_value', 'actual_value', 'min_limit', 'max_limit', 'result', 'remarks'],
  stock_history: ['id', 'material_id', 'change_type', 'quantity', 'stock_before', 'stock_after', 'notes', 'performed_by', 'created_at'],
  batch_status_history: ['id', 'batch_id', 'old_status', 'new_status', 'changed_by', 'notes', 'created_at'],
  machine_downtime: ['id', 'machine_id', 'batch_id', 'start_time', 'end_time', 'duration_hours', 'reason', 'category', 'reported_by', 'notes'],
  maintenance_records: ['id', 'machine_id', 'maintenance_type', 'maintenance_date', 'performed_by', 'cost', 'description', 'parts_replaced', 'next_maintenance', 'status'],
  alerts: ['id', 'alert_type', 'severity', 'title', 'message', 'batch_id', 'machine_id', 'material_id', 'status', 'created_at'],
};
type ImportRows = Record<string, Record<string, unknown>[]>;
type Counts = Record<string, number>;

async function call(path: string, init: RequestInit = {}) {
  const token = localStorage.getItem('polymer-token');
  const response = await fetch(`${API}${path}`, { ...init, headers: { ...(init.body ? { 'Content-Type': 'application/json' } : {}), ...(token ? { Authorization: `Bearer ${token}` } : {}), ...init.headers } });
  const body = await response.json().catch(() => ({}));
  if (!response.ok) throw new Error(body.message || `Request failed (${response.status})`);
  return body;
}

export default function AdminDataPage() {
  const [counts, setCounts] = useState<Counts>({}), [workbook, setWorkbook] = useState<ImportRows>({}), [filename, setFilename] = useState(''), [busy, setBusy] = useState(false), [error, setError] = useState(''), [notice, setNotice] = useState('');
  const rowTotal = useMemo(() => Object.values(workbook).reduce((sum, rows) => sum + rows.length, 0), [workbook]);
  const reload = async () => { try { setError(''); const result = await call('/setup/overview'); setCounts(result.data.collections || {}); } catch (e) { setError((e as Error).message); } };
  useEffect(() => { void reload(); }, []);

  const downloadTemplate = () => {
    const book = XLSX.utils.book_new();
    for (const [sheet, headers] of Object.entries(templates)) {
      const worksheet = XLSX.utils.aoa_to_sheet([headers]);
      XLSX.utils.book_append_sheet(book, worksheet, sheet);
    }
    XLSX.writeFile(book, 'polymer-operations-import-template.xlsx');
  };

  const onFile = async (event: ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0]; if (!file) return;
    setError(''); setNotice(''); setWorkbook({}); setFilename(file.name);
    try {
      const book = XLSX.read(await file.arrayBuffer(), { type: 'array', cellDates: true });
      const parsed: ImportRows = {};
      const unknown = book.SheetNames.filter(name => !templates[name.toLowerCase().trim().replace(/[ -]+/g, '_')]);
      if (unknown.length) throw new Error(`Unknown worksheet(s): ${unknown.join(', ')}. Use the provided template worksheet names.`);
      for (const name of book.SheetNames) {
        const key = name.toLowerCase().trim().replace(/[ -]+/g, '_');
        const rows = XLSX.utils.sheet_to_json<Record<string, unknown>>(book.Sheets[name], { defval: null, raw: true });
        parsed[key] = rows.map(row => Object.fromEntries(Object.entries(row).map(([column, value]) => [String(column).trim().toLowerCase().replace(/[ -]+/g, '_'), value]))).filter(row => Object.values(row).some(value => value !== null && value !== ''));
      }
      if (!Object.values(parsed).some(rows => rows.length)) throw new Error('The workbook has worksheet headers but no data rows.');
      setWorkbook(parsed);
    } catch (e) { setError((e as Error).message); setWorkbook({}); }
  };

  const importWorkbook = async () => {
    if (!rowTotal) return;
    try { setBusy(true); setError(''); const result = await call('/setup/import-excel', { method: 'POST', body: JSON.stringify({ sheets: workbook }) }); setNotice(result.message || 'Workbook imported. Existing records were left unchanged.'); setWorkbook({}); setFilename(''); await reload(); }
    catch (e) { setError((e as Error).message); } finally { setBusy(false); }
  };

  return <>
    <div className="page-head"><div><div className="eyebrow muted">ADMINISTRATION · DATA</div><h1>Data &amp; imports</h1><p>Review the database contents and import workbook data into Polymer Ops.</p></div><button className="secondary-btn" onClick={() => void reload()}><RefreshCw size={15}/> Refresh counts</button></div>
    {error && <div className="error-banner">{error}</div>}{notice && <div className="team-notice"><ShieldCheck size={16}/>{notice}</div>}
    <div className="admin-count-grid">{Object.entries(counts).map(([name,count])=><div className="admin-count-card" key={name}><span>{name.replaceAll('_',' ')}</span><b>{count}</b><small>records</small></div>)}</div>
    <div className="panel admin-import-panel"><div className="panel-head"><div><h3><FileSpreadsheet size={18}/> Import an Excel workbook</h3><p>Each worksheet name must match a collection in the template. One row represents one record.</p></div><button className="secondary-btn" onClick={downloadTemplate}><Download size={15}/> Download Excel template</button></div>
      <label className="excel-drop"><FileUp size={24}/><b>{filename || 'Choose an .xlsx workbook'}</b><span>Excel workbooks only · maximum 2,000 rows per import</span><input type="file" accept=".xlsx,.xls" onChange={onFile}/></label>
      {rowTotal > 0 && <><div className="import-preview"><b>Import preview</b><span>{rowTotal} rows across {Object.keys(workbook).length} worksheet(s)</span>{Object.entries(workbook).map(([sheet, rows])=><span key={sheet}>{sheet.replaceAll('_',' ')}: {rows.length}</span>)}</div><button className="primary-btn" disabled={busy} onClick={() => void importWorkbook()}><Upload size={15}/>{busy ? 'Importing…' : `Import ${rowTotal} rows`}</button></>}
    </div>
    <div className="info-card"><Database size={18}/><div><b>Safe import behavior</b><p>New records are added by ID. Existing IDs are skipped so spreadsheet imports do not overwrite records already in the database. User accounts and role definitions cannot be imported from a workbook.</p></div></div>
  </>;
}
