# Historial de avances

## 2026-10-03 — Arranque de la base del portal

- Se creó el monorepo pnpm con aplicaciones web Next.js 15 y API FastAPI en
  Python 3.12.
- Se prepararon Tailwind CSS v4, shadcn/ui, tooling de calidad, módulos vacíos y
  placeholders de App Router.
- Se configuraron PostgreSQL 16 para desarrollo, SQLAlchemy asíncrono y
  Alembic.
- Se añadió `GET /health`, su prueba y la exportación del contrato OpenAPI con
  tipos TypeScript generados para la web.
- Se documentaron los nueve módulos, el stack y las reglas de contribución.
- No se implementó lógica de negocio ni se eligieron proveedores de
  autenticación, pagos, video o IA.

## 2026-10-03 — Adopción de Supabase

- Se reemplazaron Docker Compose y Alembic por Supabase CLI y su directorio
  `supabase/migrations`, con una migración inicial vacía.
- Se añadió la configuración de Supabase Auth y validación de access tokens por
  JWKS con caché y control de roles desde `app_metadata`.
- Se agregaron clientes SSR de navegador y servidor y middleware de refresco de
  sesión, sin pantallas de acceso.
- Se documentaron RLS obligatorio, Storage para documentos y proveedor externo
  de video pendiente.
