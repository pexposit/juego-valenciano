// Genera els secrets de Supabase autoallotjat i els escriu per pantalla en
// format .env. Sense dependències: només `node:crypto`.
//   node deploy/generate-secrets.mjs >> .env
// ANON_KEY i SERVICE_ROLE_KEY són JWT HS256 signats amb JWT_SECRET: si canvies
// JWT_SECRET, cal tornar a generar-les (i reconstruir la web, que porta ANON_KEY).
import { createHmac, randomBytes } from 'node:crypto';

const b64url = (input) => Buffer.from(input).toString('base64url');

function sign(payload, secret) {
  const data = `${b64url(JSON.stringify({ alg: 'HS256', typ: 'JWT' }))}.${b64url(JSON.stringify(payload))}`;
  return `${data}.${createHmac('sha256', secret).update(data).digest('base64url')}`;
}

// Hex: sense caràcters que calga escapar dins de les URL de connexió a Postgres.
const postgresPassword = randomBytes(24).toString('hex');
const jwtSecret = randomBytes(32).toString('hex');
const iat = Math.floor(Date.now() / 1000);
const exp = iat + 10 * 365 * 24 * 3600;

console.log(`POSTGRES_PASSWORD=${postgresPassword}`);
console.log(`JWT_SECRET=${jwtSecret}`);
console.log(`ANON_KEY=${sign({ role: 'anon', iss: 'supabase', iat, exp }, jwtSecret)}`);
console.log(`SERVICE_ROLE_KEY=${sign({ role: 'service_role', iss: 'supabase', iat, exp }, jwtSecret)}`);
