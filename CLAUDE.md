# Contexto del proyecto

Este repositorio construye la base de un portal de membresía sobre Gestión de
Proyectos y Licitaciones de Obra. La plataforma se organizará en nueve módulos
documentados en `docs/modulos/`. Por ahora solo existe infraestructura,
placeholders y el endpoint técnico de salud: no agregues lógica de negocio,
pantallas de acceso, pagos ni integraciones de proveedores de video o IA sin
una decisión explícita.

## Stack

- Monorepo: pnpm workspaces.
- Web: Next.js 15 App Router, React, TypeScript strict, Tailwind CSS v4,
  shadcn/ui y lucide-react.
- API: Python 3.12, uv, FastAPI, Pydantic v2, SQLAlchemy 2 async y asyncpg.
- Supabase como plataforma de PostgreSQL, Auth y Storage.
- Desarrollo local: Supabase CLI con `supabase start` (requiere Docker).
- Migraciones: `supabase/migrations` es la única fuente del esquema; no se usa
  Alembic. Todas las tablas deben protegerse con RLS y políticas explícitas.
- La API se conecta al pooler de Supabase con asyncpg y `statement_cache_size=0`.
- Supabase Auth valida tokens contra JWKS; los roles de autorización de la app
  se leen de `app_metadata`, no del claim Postgres `role`.
- Contrato: OpenAPI exportado desde FastAPI y tipos TypeScript generados con
  `openapi-typescript`; `openapi-fetch` es el cliente previsto.

## Fases del producto

1. **Fundación técnica:** monorepo, infraestructura, plataforma mínima y calidad.
2. **Identidad y administración:** configurar Supabase Auth, roles en
   `app_metadata` y operación administrativa; todavía no hay pantallas de login.
3. **Oferta y membresía:** catálogo, suscripciones y presencia pública; no
   integrar pagos hasta decidir proveedor y alcance.
4. **Contenidos y recursos:** organizar video y recursos; Supabase Storage se
   usará para documentos y el proveedor de video sigue pendiente.
5. **Asistencia con IA:** definir casos de uso y límites antes de conectar
   proveedores de modelos.

Las fases expresan el orden de planificación, no autorizan por sí solas
integraciones externas.

## Reglas de código

- Mantén TypeScript en modo strict. Valida datos externos en límites definidos y
  conserva el tipado de los esquemas OpenAPI generados.
- Usa Python 3.12, type hints en código propio y Pydantic v2 para contratos de
  entrada/salida.
- Páginas y layouts de App Router son Server Components por defecto. Usa
  `'use client'` solo en componentes que requieran interactividad del navegador.
- Mantén la lógica organizada por módulo en `apps/web/src/features/<modulo>` y
  `apps/api/app/modules/<modulo>`.
- No introduzcas credenciales reales ni lógica de negocio ajena al alcance
  acordado. `SUPABASE_SERVICE_ROLE_KEY` solo puede usarse en código de servidor,
  nunca en módulos cliente ni variables `NEXT_PUBLIC_*`.
- Las migraciones de esquema se crean con Supabase CLI dentro de
  `supabase/migrations`; no agregues ni restaures Alembic.
- Habilita RLS y define políticas explícitas en cada nueva tabla.
- Cada vez que cambie un módulo, actualiza su archivo correspondiente en
  `docs/modulos/` con el alcance, decisiones y registro de avances pertinentes.
- Cuando cambie un endpoint, vuelve a exportar `docs/contrato/openapi.json` y a
  generar `apps/web/src/lib/api/schema.d.ts`.
- Ejecuta las comprobaciones relevantes de lint, tipos y pruebas antes de cerrar
  un cambio.
