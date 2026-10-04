# Contexto del proyecto

Este repositorio construye la base de un portal de membresía sobre Gestión de
Proyectos y Licitaciones de Obra. La plataforma se organizará en nueve módulos
documentados en `docs/modulos/`. Por ahora solo existe infraestructura,
placeholders y el endpoint técnico de salud: no agregues lógica de negocio,
flujos de autenticación, pagos ni integraciones de proveedores de video o IA
sin una decisión explícita.

## Stack

- Monorepo: pnpm workspaces.
- Web: Next.js 15 App Router, React, TypeScript strict, Tailwind CSS v4,
  shadcn/ui y lucide-react.
- API: Python 3.12, uv, FastAPI, Pydantic v2, SQLAlchemy 2 async, asyncpg y
  Alembic.
- Persistencia local: PostgreSQL 16 con Docker Compose.
- Contrato: OpenAPI exportado desde FastAPI y tipos TypeScript generados con
  `openapi-typescript`; `openapi-fetch` es el cliente previsto.

## Fases del producto

1. **Fundación técnica:** monorepo, infraestructura, plataforma mínima y calidad.
2. **Identidad y administración:** delimitar identidad, roles y operación
   administrativa; los proveedores de autenticación siguen pendientes.
3. **Oferta y membresía:** catálogo, suscripciones y presencia pública; no
   integrar pagos hasta decidir proveedor y alcance.
4. **Contenidos y recursos:** organizar video y recursos; no elegir ni integrar
   proveedores todavía.
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
- No introduzcas credenciales reales, proveedores externos no aprobados ni
  lógica de negocio ajena al alcance acordado.
- Cada vez que cambie un módulo, actualiza su archivo correspondiente en
  `docs/modulos/` con el alcance, decisiones y registro de avances pertinentes.
- Cuando cambie un endpoint, vuelve a exportar `docs/contrato/openapi.json` y a
  generar `apps/web/src/lib/api/schema.d.ts`.
- Ejecuta las comprobaciones relevantes de lint, tipos y pruebas antes de cerrar
  un cambio.
