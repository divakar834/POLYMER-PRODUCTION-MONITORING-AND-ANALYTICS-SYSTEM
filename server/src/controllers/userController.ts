import { Response, NextFunction } from 'express';
import bcrypt from 'bcrypt';
import { Role, User, plain } from '../models';
import { sendSuccess, sendPaginated, sendError } from '../utils/response';
import { AuthRequest } from '../middleware/auth';

export async function getUsers(req: AuthRequest, res: Response, next: NextFunction): Promise<void> {
  try {
    const page=Math.max(1,Number(req.query.page)||1),limit=Math.min(100,Math.max(1,Number(req.query.limit)||20));
    const [users,total,roles]=await Promise.all([User.find().sort({created_at:-1}).skip((page-1)*limit).limit(limit).lean(),User.countDocuments(),Role.find().lean()]);
    const names=new Map(roles.map((role:any)=>[role.id,role.name]));
    sendPaginated(res,users.map((u:any)=>{const{password:_password,...safe}=u;return{...plain(safe),role_name:names.get(u.role_id)||'unknown'};}),total,page,limit);
  } catch(err){next(err);}
}

export async function getUserById(req:AuthRequest,res:Response,next:NextFunction):Promise<void>{try{const user=await User.findOne({id:req.params.id}).lean();if(!user)return sendError(res,'User not found',404);const role=await Role.findOne({id:user.role_id}).lean();const{password:_password,...safe}=user as any;sendSuccess(res,{...plain(safe),role_name:role?.name||'unknown'});}catch(err){next(err);}}

export async function updateUser(req:AuthRequest,res:Response,next:NextFunction):Promise<void>{try{const patch:Record<string,unknown>={};for(const k of ['first_name','last_name','is_active'])if(req.body[k]!==undefined)patch[k]=req.body[k];if(req.body.role_id!==undefined){const roleId=Number(req.body.role_id);if(!await Role.exists({id:roleId}))return sendError(res,'Selected role does not exist',400);patch.role_id=roleId;}const user=await User.findOneAndUpdate({id:req.params.id},{$set:patch},{new:true}).lean();if(!user)return sendError(res,'User not found',404);const role=await Role.findOne({id:user.role_id}).lean();const{password:_password,...safe}=user as any;sendSuccess(res,{...plain(safe),role_name:role?.name||'unknown'},'User updated');}catch(err){next(err);}}

export async function deleteUser(req:AuthRequest,res:Response,next:NextFunction):Promise<void>{try{if(req.params.id===req.user?.userId)return sendError(res,'Cannot delete your own account',400);const result=await User.deleteOne({id:req.params.id});if(!result.deletedCount)return sendError(res,'User not found',404);sendSuccess(res,null,'User deleted');}catch(err){next(err);}}

export async function changePassword(req:AuthRequest,res:Response,next:NextFunction):Promise<void>{try{if(req.user?.roleName!=='admin'&&req.user?.userId!==req.params.id)return sendError(res,'Insufficient permissions',403);const password=await bcrypt.hash(req.body.newPassword,10),result=await User.updateOne({id:req.params.id},{$set:{password,updated_at:new Date()}});if(!result.matchedCount)return sendError(res,'User not found',404);sendSuccess(res,null,'Password changed successfully');}catch(err){next(err);}}
