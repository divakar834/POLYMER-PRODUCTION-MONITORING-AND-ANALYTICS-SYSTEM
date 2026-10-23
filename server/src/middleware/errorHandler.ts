import { ErrorRequestHandler } from 'express';
export const errorHandler: ErrorRequestHandler = (error, _req, res, _next) => {
  console.error(error);
  const status = error?.status || (error?.code === 11000 ? 409 : error?.name === 'ValidationError' ? 400 : error?.code === '23505' ? 409 : error?.code === '23503' ? 400 : 500);
  const message = status === 500 ? 'An unexpected server error occurred' : error.message;
  res.status(status).json({ success: false, message });
};
