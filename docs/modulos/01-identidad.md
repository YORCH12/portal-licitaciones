# Identidad

## Estado

Base técnica creada; funcionalidad pendiente.

## Fase

2. Identidad y administración.

## Depende de

- Plataforma: configuración transversal y persistencia.

## Objetivo

Definir la identidad de las personas usuarias y sus permisos de acceso al
portal.

## Alcance

- Pendiente de diseño funcional.
- No incluye integración de autenticación en esta base.
- No se ha elegido proveedor ni estrategia de sesiones o tokens.

## Entidades y endpoints

- Entidades: por definir.
- Endpoints: por definir.

## Decisiones

- PyJWT queda disponible únicamente para validar JWT cuando se apruebe el
  contrato y la estrategia de emisión.
- Los flujos de autenticación y autorización no forman parte del arranque.

## Checklist

- [ ] Acordar actores, roles y permisos.
- [ ] Elegir estrategia y proveedor de autenticación.
- [ ] Definir contratos, persistencia y pruebas.

## Registro de avances

- 2026-10-03: se creó la estructura vacía del módulo.
