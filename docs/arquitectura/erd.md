# Diagrama de entidades (Fase 1)

```mermaid
erDiagram
    AUTH_USERS ||--|| PROFILES : "crea (trigger)"
    PROFILES ||--o{ SUBSCRIPTIONS : tiene
    PLANS ||--o{ SUBSCRIPTIONS : define
    SUBSCRIPTIONS ||--o{ PAYMENTS : genera
    PROFILES ||--o{ PAYMENTS : paga
    COURSES ||--o{ COURSE_SECTIONS : contiene
    COURSES ||--o{ LESSONS : contiene
    COURSE_SECTIONS ||--o{ LESSONS : agrupa
    LESSONS ||--o| LESSON_VIDEOS : "video (solo backend)"
    PROFILES ||--o{ LESSON_PROGRESS : avanza
    LESSONS ||--o{ LESSON_PROGRESS : registra
    COURSES ||--o{ RESOURCES : adjunta
    LESSONS ||--o{ RESOURCES : adjunta
    PROFILES ||--o{ ANALYSIS_JOBS : solicita
    RESOURCES ||--o{ ANALYSIS_JOBS : "fuente opcional"
    ANALYSIS_JOBS ||--o| ANALYSIS_RESULTS : produce

    PROFILES { uuid id PK "= auth.users.id"  text email  text full_name  app_role role }
    PLANS { uuid id PK  text slug  numeric price  char currency  billing_interval interval  int ai_monthly_quota  jsonb provider_refs }
    SUBSCRIPTIONS { uuid id PK  uuid user_id FK  uuid plan_id FK  subscription_status status  text provider  text provider_subscription_id  timestamptz current_period_end  bool cancel_at_period_end }
    PAYMENTS { uuid id PK  uuid subscription_id FK  text provider_payment_id  numeric amount  payment_status status }
    PAYMENT_EVENTS { uuid id PK  text provider  text event_id  jsonb payload  text status }
    COURSES { uuid id PK  text slug  text title  publish_status status }
    COURSE_SECTIONS { uuid id PK  uuid course_id FK  text title  int position }
    LESSONS { uuid id PK  uuid course_id FK  uuid section_id FK  bool is_free_preview  publish_status status }
    LESSON_VIDEOS { uuid lesson_id PK  text provider  text external_id }
    LESSON_PROGRESS { uuid user_id PK  uuid lesson_id PK  int progress_seconds  bool completed }
    RESOURCES { uuid id PK  resource_kind kind  text storage_path  bool requires_subscription  publish_status status }
    ANALYSIS_JOBS { uuid id PK  uuid user_id FK  analysis_type type  job_status status  jsonb params }
    ANALYSIS_RESULTS { uuid id PK  uuid job_id FK  text summary  jsonb output }
```

## Quién escribe qué

| Tabla | Lectura | Escritura |
|-------|---------|-----------|
| profiles | propio / admin | solo `full_name` (propio) |
| plans | público (activos) | admin |
| subscriptions, payments | propio / admin | **solo service_role** (webhooks/FastAPI) |
| payment_events | nadie | **solo service_role** |
| courses, sections, lessons | público si está publicado | admin |
| lesson_videos | admin | admin / service_role |
| lesson_progress | propio | propio |
| resources | suscriptor activo / admin | admin |
| analysis_jobs, analysis_results | propio / admin | **solo service_role** (cuotas) |
