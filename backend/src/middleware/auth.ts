import type { NextFunction,Request,Response } from 'express'; import { createClient } from '@supabase/supabase-js';
const admin=createClient(process.env.SUPABASE_URL!,process.env.SUPABASE_SERVICE_ROLE_KEY!); export { admin };
export interface AuthRequest extends Request { userId?:string }
export async function requireAuth(req:AuthRequest,res:Response,next:NextFunction){const token=req.headers.authorization?.replace('Bearer ','');if(!token)return res.status(401).json({error:'No autoritzat'});const {data:{user},error}=await admin.auth.getUser(token);if(error||!user)return res.status(401).json({error:'JWT invàlid'});req.userId=user.id;next()}
