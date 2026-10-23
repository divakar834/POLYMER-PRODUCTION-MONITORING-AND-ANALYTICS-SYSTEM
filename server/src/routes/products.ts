import {Router} from 'express';import {authenticate,allowRoles} from '../middleware/auth';import {listProducts} from '../controllers/operationalController';const r=Router();r.use(authenticate,allowRoles('admin','production_manager'));r.get('/',listProducts);export default r;


