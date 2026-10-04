# ADR 0002: Supabase para identidad, persistencia y documentos

- **Estado:** Aceptado
- **Decusión** PostgreSQL y Auth en Supabase; Storage privado para documentos;
migraciones con la CLI de Supabase; FastAPI valida JWT vía JWKS.
Consecuencias: RLS obligatorio; roles en app_metadata; escrituras sensibles
solo desde backend; video en proveedor externo; sin Alembic.
- **Fecha:** 2026-10-03

## Contexto

El proyecto necesita identidad gestionada, PostgreSQL administrado, una forma
reproducible de evolucionar el esquema y almacenamiento de documentos, sin
incorporar ahora pantallas de acceso ni elegir un proveedor de video.

## Decisiones

- Usar **Supabase Auth** como proveedor de identidad. El portal aún no incluye
  pantallas de login ni flujos de autenticación.
- Guardar los roles de aplicación en el claim `app_metadata.role`, administrado
  desde servidor. No usar el claim Postgres `role` para decisiones de permisos
  del portal.
- Validar access tokens en la API contra `SUPABASE_JWKS_URL`, verificando firma,
  issuer, audience y expiración con PyJWT y claves JWKS cacheadas. La API solo
  acepta algoritmos asimétricos ES256 y RS256.
- Habilitar **RLS en todas las tablas** y crear políticas explícitas en la misma
  migración que crea cada tabla.
- Usar Supabase CLI para desarrollo local (`supabase start`), vinculación remota
  (`supabase link`) y migraciones. `supabase/migrations` es la única fuente del
  esquema; no se usa Alembic.
- Conectar SQLAlchemy 2 async al pooler de PostgreSQL mediante asyncpg y
  `statement_cache_size=0`, requisito para el modo transaccional del pooler.
- Usar Supabase Storage para documentos, con políticas de acceso acordes a sus
  requisitos de visibilidad.
- Mantener el video en un proveedor externo aún no elegido. No añadir una
  integración de video en esta etapa.
- Mantener `SUPABASE_SERVICE_ROLE_KEY` exclusivamente en el servidor; nunca
  exponerla en el bundle web ni en variables `NEXT_PUBLIC_*`.

## Consecuencias

- La API confía en claves públicas publicadas por Supabase y distingue tokens
  inválidos (401), roles insuficientes (403) y fallas al obtener JWKS (503).
- Toda creación de tablas debe venir acompañada de RLS, políticas y pruebas de
  autorización.
- El archivo `.env.example` contiene solo marcadores de posición. El project ref,
  contraseñas, claves de API y secretos remotos se configuran localmente o en el
  gestor de secretos del despliegue, nunca en Git.
- El desarrollo local requiere Docker para ejecutar los servicios de Supabase.
