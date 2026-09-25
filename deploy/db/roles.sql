-- S'executa una sola vegada, quan es crea el volum de dades de Postgres.
-- La imatge supabase/postgres crea els rols; ací se'ls posa contrasenya perquè
-- GoTrue (supabase_auth_admin) i PostgREST (authenticator) puguen connectar.
\set pgpass `echo "$POSTGRES_PASSWORD"`

ALTER USER authenticator WITH PASSWORD :'pgpass';
ALTER USER supabase_auth_admin WITH PASSWORD :'pgpass';
