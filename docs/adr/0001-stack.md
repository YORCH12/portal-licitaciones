# ADR 0001: Stack tecnológico

- **Estado:** Aceptado
- **Fecha:** 2026-10-03

## Contexto

Se necesita una base modular para evolucionar un portal de membresía orientado a
la gestión de proyectos y licitaciones de obra. La web y la API deben poder
desarrollarse y validarse de forma independiente, con un contrato tipado entre
ambas.

## Decisiones

- Usar pnpm workspaces para el monorepo, con aplicaciones separadas en `apps/`.
- Usar Next.js 15 App Router con TypeScript strict para la web. Tailwind CSS v4
  se configura desde CSS; shadcn/ui y lucide-react facilitan la creación y
  migración de componentes.
- Mantener las páginas y layouts como Server Components por defecto, y reservar
  Client Components para interacciones que los necesiten.
- Usar Python 3.12 con uv, FastAPI y Pydantic v2 en la API.
- Usar SQLAlchemy 2 en modo asíncrono y asyncpg para la conexión desde la API;
  el pooler requiere `statement_cache_size=0`.
- Usar Supabase PostgreSQL y mantener `supabase/migrations` como fuente única
  del esquema.
- Publicar OpenAPI desde FastAPI y generar `schema.d.ts` en la web con
  `openapi-typescript`; usar `openapi-fetch` para el cliente tipado cuando se
  implemente su consumo.
- Dejar las decisiones de Supabase Auth, roles y almacenamiento registradas en
  [ADR 0002](./0002-supabase.md).
- Usar Vitest y Testing Library en la web; pytest, Ruff y mypy strict en la API.
- Ejecutar los servicios locales con Supabase CLI y Docker. Mantener
  integraciones de pagos y proveedores de video e IA fuera del alcance hasta
  decidirlas.

## Consecuencias

- Los contratos HTTP tienen una única fuente de verdad y deben regenerarse en
  ambos lados después de cambiar la API.
- La infraestructura asíncrona queda preparada; el endpoint de salud no
  requiere una conexión a base de datos.
- Los módulos pueden implementarse por fases sin acoplar las reglas de negocio
  a componentes globales.
