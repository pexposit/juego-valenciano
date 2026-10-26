#!/bin/sh
# Aplica supabase/migrations/*.sql en ordre, una sola vegada cadascuna, igual
# que `supabase db push`. S'executa a cada `docker compose up`, després que
# GoTrue haja creat `auth.users` (les migracions hi afegixen un trigger).
set -eu

export PGHOST=db PGUSER=supabase_admin PGDATABASE=postgres PGPASSWORD="$POSTGRES_PASSWORD"
PSQL="psql -v ON_ERROR_STOP=1 -q"

$PSQL -c "create schema if not exists deploy;
  create table if not exists deploy.applied_migrations (
    name text primary key,
    applied_at timestamptz not null default now()
  );"

# Migracions agrupades (vegeu squash-map.txt): una base de dades que ja tinga TOTES les originals d'un grup en
# registra l'agrupada com a aplicada, perquè no es torne a executar.
if [ -f /squash-map.txt ]; then
  while IFS= read -r line; do
    case "$line" in ''|'#'*) continue ;; esac
    new=${line%%:*}
    olds=${line#*: }
    [ "$($PSQL -tAc "select 1 from deploy.applied_migrations where name = '$new'")" = "1" ] && continue
    all=1
    for old in $olds; do
      [ "$($PSQL -tAc "select 1 from deploy.applied_migrations where name = '$old'")" = "1" ] || { all=0; break; }
    done
    if [ "$all" = "1" ]; then
      echo "Registrant $new (les migracions originals ja estaven aplicades)"
      $PSQL -c "insert into deploy.applied_migrations (name) values ('$new')"
    fi
  done < /squash-map.txt
fi

for file in /migrations/*.sql; do
  name=$(basename "$file")
  if [ "$($PSQL -tAc "select 1 from deploy.applied_migrations where name = '$name'")" = "1" ]; then
    continue
  fi
  echo "Aplicant $name"
  # -1: la migració i el seu registre van en una sola transacció.
  $PSQL -1 -f "$file" -c "insert into deploy.applied_migrations (name) values ('$name')"
done

# Les migracions les crea supabase_admin: se donen als rols de l'API els mateixos
# permisos que tenen a Supabase Cloud. Les polítiques RLS continuen filtrant les files.
$PSQL -c "grant usage on schema public to anon, authenticated, service_role;
  grant all on all tables in schema public to anon, authenticated, service_role;
  grant all on all sequences in schema public to anon, authenticated, service_role;
  grant execute on all functions in schema public to anon, authenticated, service_role;"

echo "Base de dades al dia"
