# Plataforma

## Estado

Base técnica creada; endpoint `GET /health` implementado y Supabase CLI
inicializada.

## Fase

1. Fundación técnica.

## Depende de

- No tiene dependencias de módulos de negocio.

## Objetivo

Proveer convenciones e infraestructura compartidas para la web y la API.

## Alcance

- Configuración por entorno, CORS y conexión asíncrona por pooler a Supabase
  PostgreSQL.
- Migraciones con Supabase CLI en `supabase/migrations`.
- Contrato OpenAPI y herramientas de desarrollo.
- El endpoint de salud comprueba que la API responde; no consulta PostgreSQL.

## Entidades y endpoints

- Entidades de dominio: ninguna definida.
- `GET /health`: respuesta técnica con estado `ok`.

## Decisiones

- Supabase CLI administra la base local y Supabase remoto es la plataforma de
  persistencia.
- `supabase/migrations` es la única fuente del esquema; no se usa Alembic.
- SQLAlchemy 2 async usa asyncpg; `statement_cache_size=0` es necesario para el
  pooler.
- `CORS_ORIGINS` configura los orígenes permitidos.
- RLS y políticas explícitas son obligatorias para cada tabla nueva.

## Checklist

- [x] Crear la base de API y el endpoint de salud.
- [x] Inicializar Supabase local y crear la primera migración vacía.
- [x] Preparar conexión pooler, configuración y autenticación JWKS.
- [x] Exportar OpenAPI y generar tipos de cliente.
- [ ] Definir necesidades operativas adicionales según avance el producto.

## Registro de avances

- 2026-10-03: se creó la base técnica y la prueba asíncrona del endpoint.
