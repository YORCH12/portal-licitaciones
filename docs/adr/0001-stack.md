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
- Usar SQLAlchemy 2 en modo asíncrono, asyncpg y Alembic para persistencia y
  migraciones hacia PostgreSQL 16.
- Publicar OpenAPI desde FastAPI y generar `schema.d.ts` en la web con
  `openapi-typescript`; usar `openapi-fetch` para el cliente tipado cuando se
  implemente su consumo.
- Validar JWT con PyJWT sin construir todavía flujos de autenticación.
- Usar Vitest y Testing Library en la web; pytest, Ruff y mypy strict en la API.
- Ejecutar PostgreSQL local con Docker Compose. Mantener proveedores externos
  de autenticación, pagos, video e IA fuera del alcance hasta decidirlos.

## Consecuencias

- Los contratos HTTP tienen una única fuente de verdad y deben regenerarse en
  ambos lados después de cambiar la API.
- La infraestructura asíncrona y el sistema de migraciones quedan preparados,
  pero el endpoint de salud no requiere una conexión a base de datos.
- Los módulos pueden implementarse por fases sin acoplar las reglas de negocio
  a componentes globales.
