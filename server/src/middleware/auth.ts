import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
export interface AuthRequest extends Request { user?: { userId: string; email: string; roleId: number; roleName: string } }
export function authenticate(req: AuthRequest, res: Response, next: NextFunction): void {
  const token = req.header('Authorization')?.replace(/^Bearer\s+/i, '');
  if (!token) { res.status(401).json({ success: false, message: 'Authentication required' }); return; }
  try { req.user = jwt.verify(token, process.env.JWT_SECRET as string) as AuthRequest['user']; next(); }
  catch { res.status(401).json({ success: false, message: 'Invalid or expired session' }); }
}
export function allowRoles(...roles: string[]) {
  return (req: AuthRequest, res: Response, next: NextFunction): void => {
    if (!req.user || !roles.includes(req.user.roleName)) { res.status(403).json({ success: false, message: 'You do not have permission to perform this action' }); return; }
    next();
  };
}
