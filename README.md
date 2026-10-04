# Portal de Gestión de Proyectos y Licitaciones de Obra

Monorepo base para un portal de membresía de gestión de proyectos y licitaciones
de obra. Esta etapa establece el tooling y la arquitectura; no incluye lógica de
negocio, autenticación, pagos ni integración de proveedores de video o IA.

## Estructura

- `apps/web`: aplicación Next.js.
- `apps/api`: API FastAPI.
- `docs/`: documentación funcional y contrato OpenAPI.
- `docker-compose.yml`: PostgreSQL 16 para desarrollo local.

Consulta [docs/README.md](./docs/README.md) para el estado y la organización de
los módulos.
