const accounts = [
  ['Administrator', 'admin@polymer.com', 'Admin@123'],
  ['Production', 'prod@polymer.com', 'Prod@123'],
  ['Quality', 'quality@polymer.com', 'Quality@123'],
  ['Inventory', 'inventory@polymer.com', 'Inventory@123'],
];
export default function DemoRolePicker({ onSelect }: { onSelect: (email: string, password: string) => void }) {
  return <><b>Quick sign in by role</b><div className="demo-roles">{accounts.map(([label, email, password]) => <button type="button" key={email} onClick={() => onSelect(email, password)}>{label}</button>)}</div></>;
}
