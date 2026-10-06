# Identidad

## Estado

Base de Supabase Auth y validación de tokens creada; pantallas y flujos de
acceso pendientes.

## Fase

2. Identidad y administración.

## Depende de

- Plataforma: configuración transversal y persistencia.

## Objetivo

Definir la identidad de las personas usuarias y sus permisos de acceso al
portal.

## Alcance

- Pendiente de diseño funcional.
- Supabase Auth es el proveedor de identidad elegido.
- No incluye pantallas de login, registro ni recuperación de cuenta.
- La API valida tokens con JWKS; los permisos de aplicación se basan en
  `profiles.role`, emitido como claim JWT `user_role` por el Custom Access
  Token Hook.

## Entidades y endpoints

- Entidades: por definir.
- Endpoints: por definir.

## Decisiones

- Las políticas RLS de PostgreSQL son obligatorias y complementan la
  autorización de la API.
- `profiles.role` es la fuente única del rol; las políticas RLS usan
  `private.is_admin()`.

## Checklist

- [ ] Acordar actores, roles y permisos.
- [x] Elegir Supabase Auth y validación de JWT con JWKS.
- [x] Acordar `profiles.role` como fuente única y `user_role` como claim del JWT.
- [ ] Definir los flujos de login y gestión de cuenta.
- [ ] Definir contratos, persistencia y pruebas.

## Registro de avances

- 2026-10-03: se creó la estructura vacía del módulo.
- 2026-10-06: se añadió el Custom Access Token Hook y se centralizó la
  autorización de admin en `private.is_admin()`.
