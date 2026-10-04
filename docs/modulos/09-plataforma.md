# Plataforma

## Estado

Base técnica creada; endpoint `GET /health` implementado.

## Fase

1. Fundación técnica.

## Depende de

- No tiene dependencias de módulos de negocio.

## Objetivo

Proveer convenciones e infraestructura compartidas para la web y la API.

## Alcance

- Configuración por entorno, CORS, conexión asíncrona a PostgreSQL y migraciones
  con Alembic.
- Contrato OpenAPI y herramientas de desarrollo.
- El endpoint de salud comprueba que la API responde; no consulta PostgreSQL.

## Entidades y endpoints

- Entidades de dominio: ninguna definida.
- `GET /health`: respuesta técnica con estado `ok`.

## Decisiones

- PostgreSQL 16 es la base local de desarrollo.
- SQLAlchemy 2 async usa asyncpg; Alembic comparte `Base.metadata`.
- `API_CORS_ORIGINS` configura los orígenes permitidos.

## Checklist

- [x] Crear la base de API y el endpoint de salud.
- [x] Preparar PostgreSQL, configuración y migraciones.
- [x] Exportar OpenAPI y generar tipos de cliente.
- [ ] Definir necesidades operativas adicionales según avance el producto.

## Registro de avances

- 2026-10-03: se creó la base técnica y la prueba asíncrona del endpoint.
