import { Router } from 'express';
import { authenticate, allowRoles } from '../middleware/auth';
import { listQuality, listQualityParameters, createQuality, updateQuality } from '../controllers/operationalController';

const r = Router();
r.use(authenticate, allowRoles('admin', 'quality_manager'));
r.get('/', listQuality);
r.get('/parameters', listQualityParameters);
r.post('/', allowRoles('admin', 'quality_manager'), createQuality);
r.put('/:id', allowRoles('admin', 'quality_manager'), updateQuality);
export default r;

