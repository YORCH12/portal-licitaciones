# Módulos del portal

El proyecto se divide en nueve módulos con responsabilidades y dependencias
documentadas. Todos están en fase de base: todavía no contienen lógica de
negocio.

| Módulo         | Estado                                        | Fase                          | Enlace                                                 |
| -------------- | --------------------------------------------- | ----------------------------- | ------------------------------------------------------ |
| Identidad      | Base técnica creada; funcionalidad pendiente  | 2. Identidad y administración | [01-identidad.md](./modulos/01-identidad.md)           |
| Suscripciones  | Base técnica creada; funcionalidad pendiente  | 3. Oferta y membresía         | [02-suscripciones.md](./modulos/02-suscripciones.md)   |
| Catálogo       | Base técnica creada; funcionalidad pendiente  | 3. Oferta y membresía         | [03-catalogo.md](./modulos/03-catalogo.md)             |
| Video          | Base técnica creada; funcionalidad pendiente  | 4. Contenidos y recursos      | [04-video.md](./modulos/04-video.md)                   |
| Recursos       | Base técnica creada; funcionalidad pendiente  | 4. Contenidos y recursos      | [05-recursos.md](./modulos/05-recursos.md)             |
| IA             | Base técnica creada; funcionalidad pendiente  | 5. Asistencia con IA          | [06-ia.md](./modulos/06-ia.md)                         |
| Administración | Base técnica creada; funcionalidad pendiente  | 2. Identidad y administración | [07-administracion.md](./modulos/07-administracion.md) |
| Landing        | Base técnica creada; funcionalidad pendiente  | 3. Oferta y membresía         | [08-landing.md](./modulos/08-landing.md)               |
| Plataforma     | Endpoint técnico `/health`; dominio pendiente | 1. Fundación técnica          | [09-plataforma.md](./modulos/09-plataforma.md)         |

Decisiones transversales: [ADR 0001 — Stack](./adr/0001-stack.md) y
[ADR 0002 — Supabase](./adr/0002-supabase.md). Los avances están en el
[historial](./historial.md). El contrato inicial de la API está en
[OpenAPI](./contrato/openapi.json).
