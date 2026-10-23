import {Router} from 'express';import {authenticate,allowRoles} from '../middleware/auth';import {dashboard,analytics} from '../controllers/operationalController';const r=Router();r.use(authenticate);r.get('/dashboard',allowRoles('admin','production_manager'),dashboard);r.get('/:kind',allowRoles('admin'),analytics);export default r;

