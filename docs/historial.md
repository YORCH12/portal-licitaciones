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

## 2026-10-03: Base de datos desplegada en Supabase (dev)
- Hecho: migración inicial aplicada con db push; pruebas de RLS (A-D) superadas.
- Variables de entorno reunidas; JWKS verificada.
- Pendientes: crear proyecto prod, SMTP propio, proveedor de video.

## 2026-10-06: Auditoría técnica del portal
- Contexto: revisión de solo lectura del monorepo y cambios locales pendientes.
- Decisión o entregable: estado por fase y módulo, riesgos de seguridad, divergencias de contratos y decisiones de proveedores.
- Motivo: establecer prioridades antes de implementar funcionalidades.
- Pendientes: revisar permisos de `has_active_subscription`, unificar roles, confirmar y versionar migración, alinear OpenAPI y proteger rutas privadas.

## 2026-10-06: Decisión de proveedores de pagos y video
- Contexto: tras la auditoría, se resolvieron las dos decisiones pendientes con criterio de escalabilidad.
- Decisión o entregable: Mercado Pago como pasarela inicial y Bunny Stream como video. Ambos tras interfaces (PaymentProvider, VideoProvider) y columnas provider con CHECK, para poder sumar Stripe u otro proveedor de video sin reescribir.
- Motivo: Mercado Pago encaja con el mercado LATAM; Bunny es capa de video pura, no compite con la gestión de membresías propia y tiene URLs firmadas y DRM opcional.
- Pendientes: verificar cobertura de suscripciones recurrentes de Mercado Pago por país y método de pago; revisar si el esquema cumple el diseño agnóstico (paso 4 del prompt del agente).