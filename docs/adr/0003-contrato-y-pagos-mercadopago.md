# ADR 0003: Reparto de responsabilidades, contrato API y pagos con Mercado Pago
Estado: Aceptada (2026-10-03). La parte de pagos es **evolutiva** (se afina en Fase 4 y después del despliegue).

## 1. Qué hace cada capa
- **Supabase directo desde Next.js (con RLS):** lecturas del catálogo, recursos, progreso, planes y CRUD de admin. Tipos con `supabase gen types typescript`.
- **FastAPI (contrato OpenAPI):** todo lo que requiere secretos, cuotas o cálculo pesado: checkout, webhooks de pago, URLs firmadas de video y descargas, subida de recursos por admin, trabajos de IA. Tipos con `openapi-typescript`.
- Resultado: dos fuentes de tipos, cada una generada, ninguna escrita a mano.

## 2. Pagos desacoplados
- El esquema es agnóstico a la pasarela: `subscriptions.provider`, `provider_subscription_id`, `plans.provider_refs`.
- En FastAPI: `modules/subscriptions/providers/{base.py, mercadopago.py}`. `base.py` define un Protocol `PaymentProvider` (crear checkout, consultar suscripción, cancelar, verificar firma de webhook, mapear estado). Cambiar o añadir Stripe después = nueva clase, sin tocar el resto.
- El acceso al contenido depende **solo** de `has_active_subscription()`, no de la pasarela.

## 3. Mercado Pago (a validar con su documentación vigente en Fase 4)
- Producto: Suscripciones (`preapproval_plan` + `preapproval`).
- Webhooks esperados: `subscription_preapproval`, `subscription_authorized_payment`, `payment`.
- Reglas del webhook: (1) verificar la firma `x-signature` con el secreto, (2) registrar el evento en `payment_events` (idempotencia por `event_id`), (3) **consultar el recurso en la API de Mercado Pago** para leer el estado real en vez de confiar en el cuerpo, (4) actualizar `subscriptions`/`payments`, (5) responder 200 rápido; reintentos seguros.
- Mapeo de estados propuesto: `pending→pending`, `authorized→active`, `paused→paused`, `cancelled→canceled`; cobros fallidos → `past_due`.

## 4. Mientras llegan los pagos (Fases 1-3)
Se desarrolla con suscripciones manuales (`provider = 'manual'`, ver `supabase/seed.sql`). Así el resto del producto no depende de la pasarela.

## 5. Pendientes de pagos
- Definir periodo de gracia para `past_due`.
- Cancelación: inmediata vs al cierre del periodo.
- Facturación (CFDI) si aplica en México.
- Pruebas en sandbox y manejo de reembolsos/contracargos.
