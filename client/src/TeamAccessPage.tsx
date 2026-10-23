import { FormEvent, useEffect, useState } from 'react';
import { Check, Database, Plus, RefreshCw, ShieldCheck, Users } from 'lucide-react';

type Row = Record<string, any>;
const API = import.meta.env.VITE_API_URL || 'http://localhost:5000/api';
async function api(path: string, init: RequestInit = {}) {
  const token = localStorage.getItem('polymer-token');
  const response = await fetch(`${API}${path}`, { ...init, headers: { 'Content-Type': 'application/json', ...(token ? { Authorization: `Bearer ${token}` } : {}), ...init.headers } });
  const body = await response.json().catch(() => ({}));
  if (!response.ok) throw new Error(body.message || `Request failed (${response.status})`);
  return body;
}

export default function TeamAccessPage() {
  const [rows, setRows] = useState<Row[]>([]), [error, setError] = useState(''), [notice, setNotice] = useState(''), [busy, setBusy] = useState(false), [showForm, setShowForm] = useState(false);
  const load = async () => { try { const result = await api('/users'); setRows(result.data || []); setError(''); } catch (e) { setError((e as Error).message); } };
  useEffect(() => { void load(); }, []);
  const createUser = async (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault(); const formElement = event.currentTarget, form = new FormData(formElement);
    try { setBusy(true); await api('/users', { method: 'POST', body: JSON.stringify({ email: form.get('email'), password: form.get('password'), first_name: form.get('first_name'), last_name: form.get('last_name'), role_id: Number(form.get('role_id')) }) }); setNotice('Account created successfully.'); setShowForm(false); formElement.reset(); await load(); }
    catch (e) { setError((e as Error).message); } finally { setBusy(false); }
  };
  const seed = async () => { try { setBusy(true); const result = await api('/setup/sample-data', { method: 'POST' }); setNotice(result.message || 'Missing sample records loaded; existing records were kept.'); await load(); } catch (e) { setError((e as Error).message); } finally { setBusy(false); } };
  return <>
    <div className="page-head"><div><div className="eyebrow muted">ADMINISTRATION · ACCESS</div><h1>Team access</h1><p>Manage role based accounts and restore the original sample data.</p></div><div className="team-actions"><button className="secondary-btn" onClick={() => void load()}><RefreshCw size={15}/> Refresh</button><button className="primary-btn" onClick={() => setShowForm(!showForm)}><Plus size={16}/> Add account</button></div></div>
    {error && <div className="error-banner">{error}</div>}{notice && <div className="team-notice"><Check size={16}/>{notice}</div>}
    {showForm && <form className="panel team-form" onSubmit={createUser}><div className="panel-head"><div><h3>Create an account</h3><p>Choose a role to set the account's access level.</p></div></div><div className="team-form-grid"><label>First name<input name="first_name" required/></label><label>Last name<input name="last_name" required/></label><label>Work email<input name="email" type="email" required/></label><label>Password<input name="password" type="password" minLength={8} required/></label><label>Role<select name="role_id" defaultValue="2"><option value="1">Administrator</option><option value="2">Production</option><option value="3">Quality</option><option value="4">Inventory</option></select></label><button className="primary-btn" disabled={busy}>{busy ? 'Saving…' : 'Create account'}</button></div></form>}
    <div className="panel table-panel"><div className="panel-head"><div><h3><Users size={17}/> Workspace members</h3><p>{rows.length} registered accounts</p></div></div><div className="table-wrap"><table><thead><tr><th>Team member</th><th>Email</th><th>Role</th><th>Last sign in</th><th>Status</th></tr></thead><tbody>{rows.map(u=><tr key={u.id}><td><b>{u.first_name} {u.last_name}</b></td><td>{u.email}</td><td>{u.role_name}</td><td>{u.last_login ? new Date(u.last_login).toLocaleString() : 'Never'}</td><td><span className={`pill ${u.is_active ? 'running' : 'inactive'}`}>{u.is_active ? 'Active' : 'Inactive'}</span></td></tr>)}</tbody></table>{!rows.length&&<div className="empty-state">No team accounts found.</div>}</div></div>
    <div className="info-card team-seed"><ShieldCheck size={18}/><div><b>Role based access is enabled</b><p>Use the demo role accounts on the sign in screen or create accounts for your team.</p></div><button className="secondary-btn" onClick={() => void seed()} disabled={busy}><Database size={15}/>{busy ? 'Loading…' : 'Load sample dataset'}</button></div>
  </>;
}
