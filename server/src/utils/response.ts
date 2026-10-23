import { Response } from 'express';
export function sendSuccess(res: Response, data: unknown, message = 'Success', status = 200): void {
  res.status(status).json({ success: true, message, data });
}
export function sendError(res: Response, message: string, status = 400): void {
  res.status(status).json({ success: false, message });
}
export function sendPaginated(res: Response, data: unknown[], total: number, page: number, limit: number): void {
  res.json({ success: true, data, pagination: { total, page, limit, pages: Math.ceil(total / limit) } });
}
