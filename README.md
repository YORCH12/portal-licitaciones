# Portal de Gestión de Proyectos y Licitaciones de Obra

Monorepo base para un portal de membresía sobre gestión de proyectos y
licitaciones de obra. Esta etapa establece la arquitectura, el contrato entre
web y API, y el tooling; no implementa lógica de negocio ni pantallas de
autenticación, pagos o integración de video e IA.

## Estructura del repositorio

- `apps/web`: Next.js 15, App Router, TypeScript strict, Tailwind CSS v4 y
  shadcn/ui.
- `apps/api`: FastAPI sobre Python 3.12, uv, Pydantic v2, SQLAlchemy async y
  validación Supabase Auth vía JWKS.
- `docs/`: módulos, ADR, historial y contrato OpenAPI.
- `.github/`: CI y plantillas de colaboración.
- `supabase/`: configuración local y migraciones, fuente única del esquema.

Consulta [docs/README.md](./docs/README.md) para el estado y organización de
los nueve módulos y [CLAUDE.md](./CLAUDE.md) para las reglas de trabajo.

## Requisitos

- Node.js 22 o superior y pnpm 9 (se puede habilitar con `corepack enable pnpm`).
- Python 3.12 y [uv](https://docs.astral.sh/uv/).
- [Supabase CLI](https://supabase.com/docs/guides/cli) y Docker para los
  servicios locales de Supabase.

## Desarrollo local

Desde la raíz del repositorio:

```sh
cp .env.example .env
corepack enable pnpm
pnpm install --frozen-lockfile
supabase start
supabase status
```

Completa `.env` con la URL local, la clave anon y la clave service role que
muestra `supabase status`. Configura `DATABASE_URL` con la cadena local para
desarrollo; conserva la cadena del pooler de Supabase para entornos remotos. No
uses ni compartas la clave service role en el navegador.

Para desarrollo local, `DATABASE_URL` puede ser
`postgresql+asyncpg://postgres:postgres@127.0.0.1:54322/postgres`. La cadena de
pooler transaccional se usa en entornos remotos.

Inicia la web en una terminal desde la raíz:

```sh
pnpm --filter web dev
```

Inicia la API en otra terminal:

```sh
cd apps/api
uv sync
uv run uvicorn app.main:app --reload
```

La web queda disponible en `http://localhost:3000`, la API en
`http://localhost:8000` y su documentación interactiva en `/docs`. El endpoint
`GET /health` devuelve el estado de la API.

Para detener los servicios locales de Supabase:

```sh
supabase stop
```

## Supabase y migraciones

`supabase/migrations` es la única fuente del esquema; no se usa Alembic. Crea
una migración con `supabase migration new <nombre>` y aplícala localmente con
`supabase db reset`.

Para vincular un proyecto remoto desde la raíz:

```sh
supabase login
supabase link --project-ref <project-ref>
```

La CLI puede solicitar la contraseña de base de datos de forma interactiva. No
la pases en comandos ni la guardes en el repositorio. Usa `.env` local, el
Dashboard de Supabase y los secretos protegidos del entorno de despliegue.
Para un proyecto remoto, usa la URL `https://<project-ref>.supabase.co` en
`NEXT_PUBLIC_SUPABASE_URL`, su endpoint
`https://<project-ref>.supabase.co/auth/v1/.well-known/jwks.json` en
`SUPABASE_JWKS_URL` y la cadena de conexión del pooler transaccional en
`DATABASE_URL`.
Activa RLS y añade políticas explícitas para cada tabla nueva. Usa Supabase
Storage para documentos; la decisión de proveedor de video queda pendiente.

## Calidad y contrato API

```sh
pnpm --filter web lint
pnpm --filter web typecheck
pnpm --filter web test
pnpm --filter web build
```

Desde `apps/api`:

```sh
uv run ruff check app tests scripts
uv run mypy
uv run pytest
```

Después de cambiar el contrato de la API, desde la raíz exporta y regenera sus
tipos:

```sh
cd apps/api && uv run python scripts/export_openapi.py
cd ../.. && pnpm --filter web generate:api
```
