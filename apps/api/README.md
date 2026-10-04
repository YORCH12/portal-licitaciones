# API

API FastAPI del portal. Usa Python 3.12, uv y Supabase como servicio de
persistencia y autenticación. Las migraciones en la raíz del repositorio bajo
`supabase/migrations` son la única fuente del esquema; Alembic no se usa.

Desde la raíz del repositorio, inicia Supabase localmente:

```sh
supabase start
supabase status
```

Configura `.env` con la URL local, la clave anon y la clave service role
mostradas por `supabase status`. La clave service role es solo para el servidor
y no debe enviarse al navegador.

Para vincular un proyecto remoto, desde la raíz:

```sh
supabase login
supabase link --project-ref <project-ref>
```

La CLI solicitará la contraseña de base de datos cuando corresponda. No la
incluyas en el repositorio; usa `.env` local o el almacén seguro de secretos del
entorno de despliegue. Supabase Dashboard puede usarse para recuperar el
project ref y la cadena del pooler. Para la API, `DATABASE_URL` debe ser la
cadena del pooler en modo transacción y usar `postgresql+asyncpg://`.
`SUPABASE_JWKS_URL` debe apuntar a
`https://<project-ref>.supabase.co/auth/v1/.well-known/jwks.json`.

Para ejecutar API y pruebas desde este directorio:

```sh
uv sync
uv run uvicorn app.main:app --reload
```

Las tablas nuevas deben habilitar RLS y definir políticas explícitas en una
migración de `supabase/migrations`.
