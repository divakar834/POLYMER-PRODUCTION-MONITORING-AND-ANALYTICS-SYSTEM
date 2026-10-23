import { Request, Response, NextFunction } from 'express';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import { Role, User } from '../models';
import { sendSuccess, sendError } from '../utils/response';
import { AuthRequest } from '../middleware/auth';

export async function login(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    const email = String(req.body.email || '').trim().toLowerCase();
    const user = await User.findOne({ email }).select('+password');
    if (!user) return sendError(res, 'Invalid email or password', 401);
    if (!user.is_active) return sendError(res, 'Account is inactive. Contact administrator.', 403);
    if (!await bcrypt.compare(String(req.body.password || ''), user.password)) return sendError(res, 'Invalid email or password', 401);
    const role = await Role.findOne({ id: user.role_id }).lean();
    if (!role) return sendError(res, 'User role is not configured', 403);
    user.last_login = new Date(); await user.save();
    const token = jwt.sign({ userId: user.id, email: user.email, roleId: user.role_id, roleName: role.name }, process.env.JWT_SECRET as string,
      { expiresIn: (process.env.JWT_EXPIRES_IN || '8h') as jwt.SignOptions['expiresIn'] });
    sendSuccess(res, { token, user: { id: user.id, email: user.email, first_name: user.first_name, last_name: user.last_name, role_id: user.role_id, role_name: role.name } }, 'Login successful');
  } catch (err) { next(err); }
}

export async function register(req: AuthRequest, res: Response, next: NextFunction): Promise<void> {
  try {
    if (req.user?.roleName !== 'admin') return sendError(res, 'Only administrators can create users', 403);
    const { email, password, first_name, last_name, role_id } = req.body;
    if (await User.exists({ email: String(email).toLowerCase() })) return sendError(res, 'Email already registered', 409);
    if (!await Role.exists({ id: Number(role_id) })) return sendError(res, 'Selected role does not exist', 400);
    const hashed = await bcrypt.hash(password, 10);
    const user = await User.create({ email: String(email).trim().toLowerCase(), password: hashed, first_name, last_name, role_id: Number(role_id), is_active: true, created_at: new Date(), updated_at: new Date() });
    sendSuccess(res, { id: user.id }, 'User created successfully', 201);
  } catch (err) { next(err); }
}

export async function getMe(req: AuthRequest, res: Response, next: NextFunction): Promise<void> {
  try {
    const user = await User.findOne({ id: req.user!.userId }).lean();
    if (!user) return sendError(res, 'User not found', 404);
    const role = await Role.findOne({ id: user.role_id }).lean();
    const { password: _password, ...safeUser } = user as any;
    sendSuccess(res, { ...safeUser, role_name: role?.name || 'unknown' });
  } catch (err) { next(err); }
}
