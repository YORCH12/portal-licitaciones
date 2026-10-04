# Portal de Gestión de Proyectos y Licitaciones de Obra

Monorepo base para un portal de membresía sobre gestión de proyectos y
licitaciones de obra. Esta etapa establece la arquitectura, el contrato entre
web y API, y el tooling; no implementa lógica de negocio ni integra proveedores
de autenticación, pagos, video o IA.

## Estructura del repositorio

- `apps/web`: Next.js 15, App Router, TypeScript strict, Tailwind CSS v4 y
  shadcn/ui.
- `apps/api`: FastAPI sobre Python 3.12, uv, Pydantic v2 y SQLAlchemy async.
- `docs/`: módulos, ADR, historial y contrato OpenAPI.
- `.github/`: CI y plantillas de colaboración.
- `docker-compose.yml`: PostgreSQL 16 para desarrollo local.

Consulta [docs/README.md](./docs/README.md) para el estado y organización de
los nueve módulos y [CLAUDE.md](./CLAUDE.md) para las reglas de trabajo.

## Requisitos

- Node.js 20.9 o superior y pnpm 9 (se puede habilitar con `corepack enable pnpm`).
- Python 3.12 y [uv](https://docs.astral.sh/uv/).
- Docker con Docker Compose v2 para PostgreSQL local.

## Desarrollo local

Desde la raíz del repositorio:

```sh
cp .env.example .env
corepack enable pnpm
pnpm install --frozen-lockfile
docker compose up -d db
```

Inicia la web en una terminal:

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

Para detener PostgreSQL sin borrar el volumen de datos:

```sh
docker compose down
```

## Calidad y contrato API

```sh
pnpm --filter web lint
pnpm --filter web typecheck
pnpm --filter web test
pnpm --filter web build
```

Desde `apps/api`:

```sh
uv run ruff check app tests scripts alembic
uv run mypy
uv run pytest
```

Después de cambiar el contrato de la API, desde la raíz exporta y regenera sus
tipos:

```sh
cd apps/api && uv run python scripts/export_openapi.py
cd ../.. && pnpm --filter web generate:api
```
