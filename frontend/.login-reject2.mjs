import { createClient } from '@supabase/supabase-js';
const ANON = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiYW5vbiIsImlzcyI6InN1cGFiYXNlIiwiaWF0IjoxNzkwMjYyNDE0LCJleHAiOjIxMDU2MjI0MTR9.Et2Utux1m_FcWLxUr_4YCqavaTeKhlVboELKauP-xjI';
const c = createClient('http://localhost:8000', ANON);
const { data, error } = await c.auth.signInWithPassword({ email: 'noprofile2-REPLACE@example.com', password: 'test123456' });
