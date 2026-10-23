import { Request, Response, NextFunction } from 'express';
import { validationResult } from 'express-validator';
export function validateRequest(req: Request, res: Response, next: NextFunction): void {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    res.status(400).json({ success: false, message: 'Please check the submitted fields', errors: errors.array().map((error) => ({ field: 'path' in error ? error.path : 'request', message: error.msg })) });
    return;
  }
  next();
}
