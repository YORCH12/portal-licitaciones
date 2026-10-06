-- =====================================================================
-- Portal Licitaciones PM - Esquema inicial (Fase 1)
-- Reglas: RLS en TODAS las tablas; escrituras sensibles solo con
-- service_role (FastAPI / webhooks). Proveedor de pagos desacoplado.
-- =====================================================================

-- ---------- Tipos ----------
create type public.app_role            as enum ('admin', 'subscriber');
create type public.billing_interval    as enum ('month', 'year');
create type public.subscription_status as enum ('pending', 'active', 'past_due', 'paused', 'canceled', 'expired');
create type public.payment_status      as enum ('pending', 'approved', 'rejected', 'refunded', 'charged_back');
create type public.publish_status      as enum ('draft', 'published', 'archived');
create type public.resource_kind       as enum ('pdf', 'excel', 'bases_concurso', 'other');
create type public.analysis_type       as enum ('summary', 'risk_analysis', 'agent');
create type public.job_status          as enum ('queued', 'running', 'succeeded', 'failed');

-- ---------- Utilidades ----------
create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end $$;

-- ---------- Módulo 1: Identidad ----------
create table public.profiles (
  id          uuid primary key references auth.users(id) on delete cascade,
  email       text not null,
  full_name   text,
  role        public.app_role not null default 'subscriber',
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);
create trigger profiles_updated_at before update on public.profiles
  for each row execute function public.set_updated_at();

-- Crea el perfil al registrarse. El rol siempre inicia como 'subscriber';
-- promover a admin solo se hace con service_role (ver docs).
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  insert into public.profiles (id, email, full_name)
  values (new.id, new.email, new.raw_user_meta_data ->> 'full_name');
  return new;
end $$;

create trigger on_auth_user_created after insert on auth.users
  for each row execute function public.handle_new_user();

create or replace function public.is_admin()
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from public.profiles
    where id = (select auth.uid()) and role = 'admin'
  );
$$;

-- ---------- Módulo 2: Suscripciones y pagos ----------
create table public.plans (
  id               uuid primary key default gen_random_uuid(),
  slug             text not null unique,
  name             text not null,
  description      text,
  price            numeric(12,2) not null check (price >= 0),
  currency         char(3) not null default 'MXN',
  billing_interval public.billing_interval not null default 'month',
  interval_count   int not null default 1 check (interval_count > 0),
  ai_monthly_quota int not null default 0 check (ai_monthly_quota >= 0),
  features         jsonb not null default '[]'::jsonb,
  -- IDs del plan en cada pasarela: {"mercadopago": "<preapproval_plan_id>"}
  provider_refs    jsonb not null default '{}'::jsonb,
  is_active        boolean not null default true,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now()
);
create trigger plans_updated_at before update on public.plans
  for each row execute function public.set_updated_at();

create table public.subscriptions (
  id                       uuid primary key default gen_random_uuid(),
  user_id                  uuid not null references public.profiles(id) on delete cascade,
  plan_id                  uuid not null references public.plans(id),
  status                   public.subscription_status not null default 'pending',
  provider                 text not null default 'mercadopago',
  provider_subscription_id text,
  provider_customer_id     text,
  current_period_end       timestamptz,
  cancel_at_period_end     boolean not null default false,
  canceled_at              timestamptz,
  created_at               timestamptz not null default now(),
  updated_at               timestamptz not null default now(),
  unique (provider, provider_subscription_id)
);
create trigger subscriptions_updated_at before update on public.subscriptions
  for each row execute function public.set_updated_at();
create index subscriptions_user_idx on public.subscriptions(user_id);
-- Un usuario solo puede tener una suscripción "vigente" a la vez.
create unique index subscriptions_one_current_per_user
  on public.subscriptions(user_id)
  where status in ('pending', 'active', 'past_due', 'paused');

create or replace function public.has_active_subscription(uid uuid)
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from public.subscriptions s
    where s.user_id = uid
      and s.status = 'active'
      and (s.current_period_end is null or s.current_period_end > now())
  );
$$;

create table public.payments (
  id                  uuid primary key default gen_random_uuid(),
  subscription_id     uuid references public.subscriptions(id) on delete set null,
  user_id             uuid not null references public.profiles(id) on delete cascade,
  provider            text not null default 'mercadopago',
  provider_payment_id text not null,
  amount              numeric(12,2) not null,
  currency            char(3) not null,
  status              public.payment_status not null default 'pending',
  paid_at             timestamptz,
  created_at          timestamptz not null default now(),
  unique (provider, provider_payment_id)
);
create index payments_user_idx on public.payments(user_id);
create index payments_subscription_idx on public.payments(subscription_id);

-- Bitácora de webhooks: garantiza idempotencia y permite reprocesar.
create table public.payment_events (
  id           uuid primary key default gen_random_uuid(),
  provider     text not null,
  event_id     text not null,
  event_type   text not null,
  payload      jsonb not null,
  status       text not null default 'received' check (status in ('received', 'processed', 'failed')),
  error        text,
  received_at  timestamptz not null default now(),
  processed_at timestamptz,
  unique (provider, event_id)
);

-- ---------- Módulo 3: Catálogo académico ----------
create table public.courses (
  id          uuid primary key default gen_random_uuid(),
  slug        text not null unique,
  title       text not null,
  description text,
  cover_path  text,
  status      public.publish_status not null default 'draft',
  position    int not null default 0,
  created_by  uuid references public.profiles(id) on delete set null,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);
create trigger courses_updated_at before update on public.courses
  for each row execute function public.set_updated_at();

create table public.course_sections (
  id         uuid primary key default gen_random_uuid(),
  course_id  uuid not null references public.courses(id) on delete cascade,
  title      text not null,
  position   int not null default 0
);
create index course_sections_course_idx on public.course_sections(course_id);

create table public.lessons (
  id               uuid primary key default gen_random_uuid(),
  course_id        uuid not null references public.courses(id) on delete cascade,
  section_id       uuid references public.course_sections(id) on delete set null,
  title            text not null,
  description      text,
  position         int not null default 0,
  duration_seconds int check (duration_seconds >= 0),
  is_free_preview  boolean not null default false,
  status           public.publish_status not null default 'draft',
  published_at     timestamptz,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now()
);
create trigger lessons_updated_at before update on public.lessons
  for each row execute function public.set_updated_at();
create index lessons_course_idx on public.lessons(course_id);
create index lessons_section_idx on public.lessons(section_id);

create table public.lesson_progress (
  user_id          uuid not null references public.profiles(id) on delete cascade,
  lesson_id        uuid not null references public.lessons(id) on delete cascade,
  progress_seconds int not null default 0 check (progress_seconds >= 0),
  completed        boolean not null default false,
  updated_at       timestamptz not null default now(),
  primary key (user_id, lesson_id)
);
create trigger lesson_progress_updated_at before update on public.lesson_progress
  for each row execute function public.set_updated_at();

-- ---------- Módulo 4: Video seguro ----------
-- El ID del video vive aparte y NO es legible por suscriptores: solo el
-- backend lo usa para firmar URLs de reproducción con expiración.
create table public.lesson_videos (
  lesson_id   uuid primary key references public.lessons(id) on delete cascade,
  provider    text not null default 'bunny',
  external_id text not null,
  created_at  timestamptz not null default now()
);

-- ---------- Módulo 5: Biblioteca de recursos ----------
create table public.resources (
  id                    uuid primary key default gen_random_uuid(),
  title                 text not null,
  description           text,
  kind                  public.resource_kind not null default 'other',
  storage_path          text not null unique,   -- bucket 'resources'
  mime_type             text,
  size_bytes            bigint check (size_bytes >= 0),
  course_id             uuid references public.courses(id) on delete set null,
  lesson_id             uuid references public.lessons(id) on delete set null,
  requires_subscription boolean not null default true,
  status                public.publish_status not null default 'draft',
  created_by            uuid references public.profiles(id) on delete set null,
  created_at            timestamptz not null default now()
);
create index resources_course_idx on public.resources(course_id);
create index resources_lesson_idx on public.resources(lesson_id);

-- ---------- Módulo 6: Herramientas IA ----------
create table public.analysis_jobs (
  id                 uuid primary key default gen_random_uuid(),
  user_id            uuid not null references public.profiles(id) on delete cascade,
  type               public.analysis_type not null,
  source_resource_id uuid references public.resources(id) on delete set null,
  source_path        text,                       -- bucket 'analysis-inputs'
  params             jsonb not null default '{}'::jsonb,
  status             public.job_status not null default 'queued',
  error              text,
  created_at         timestamptz not null default now(),
  started_at         timestamptz,
  finished_at        timestamptz
);
create index analysis_jobs_user_idx on public.analysis_jobs(user_id, created_at desc);

create table public.analysis_results (
  id         uuid primary key default gen_random_uuid(),
  job_id     uuid not null unique references public.analysis_jobs(id) on delete cascade,
  summary    text,
  output     jsonb not null,
  model      text,
  tokens_in  int,
  tokens_out int,
  created_at timestamptz not null default now()
);

-- =====================================================================
-- Row Level Security
-- =====================================================================
alter table public.profiles          enable row level security;
alter table public.plans             enable row level security;
alter table public.subscriptions     enable row level security;
alter table public.payments          enable row level security;
alter table public.payment_events    enable row level security;
alter table public.courses           enable row level security;
alter table public.course_sections   enable row level security;
alter table public.lessons           enable row level security;
alter table public.lesson_progress   enable row level security;
alter table public.lesson_videos     enable row level security;
alter table public.resources         enable row level security;
alter table public.analysis_jobs     enable row level security;
alter table public.analysis_results  enable row level security;

-- profiles: cada quien ve lo suyo; solo puede editar su nombre (no el rol).
create policy profiles_select on public.profiles for select to authenticated
  using (id = (select auth.uid()) or public.is_admin());
create policy profiles_update_own on public.profiles for update to authenticated
  using (id = (select auth.uid())) with check (id = (select auth.uid()));
revoke update on public.profiles from authenticated;
grant update (full_name) on public.profiles to authenticated;

-- plans: lectura pública de planes activos; admin gestiona.
create policy plans_select on public.plans for select to anon, authenticated
  using (is_active or public.is_admin());
create policy plans_admin_write on public.plans for all to authenticated
  using (public.is_admin()) with check (public.is_admin());

-- subscriptions / payments: lectura propia. Escritura SOLO service_role.
create policy subscriptions_select on public.subscriptions for select to authenticated
  using (user_id = (select auth.uid()) or public.is_admin());
create policy payments_select on public.payments for select to authenticated
  using (user_id = (select auth.uid()) or public.is_admin());

-- payment_events: sin políticas = inaccesible salvo service_role.

-- catálogo: temario público si está publicado; admin gestiona todo.
create policy courses_select on public.courses for select to anon, authenticated
  using (status = 'published' or public.is_admin());
create policy courses_admin_write on public.courses for all to authenticated
  using (public.is_admin()) with check (public.is_admin());

create policy sections_select on public.course_sections for select to anon, authenticated
  using (public.is_admin() or exists (
    select 1 from public.courses c where c.id = course_id and c.status = 'published'));
create policy sections_admin_write on public.course_sections for all to authenticated
  using (public.is_admin()) with check (public.is_admin());

create policy lessons_select on public.lessons for select to anon, authenticated
  using (public.is_admin() or (status = 'published' and exists (
    select 1 from public.courses c where c.id = course_id and c.status = 'published')));
create policy lessons_admin_write on public.lessons for all to authenticated
  using (public.is_admin()) with check (public.is_admin());

create policy progress_own on public.lesson_progress for all to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));

-- lesson_videos: solo admin (el backend usa service_role para firmar URLs).
create policy lesson_videos_admin on public.lesson_videos for all to authenticated
  using (public.is_admin()) with check (public.is_admin());

-- resources: suscriptores activos ven los publicados; admin todo.
create policy resources_select on public.resources for select to authenticated
  using (
    public.is_admin()
    or (status = 'published'
        and (not requires_subscription
             or public.has_active_subscription((select auth.uid()))))
  );
create policy resources_admin_write on public.resources for all to authenticated
  using (public.is_admin()) with check (public.is_admin());

-- análisis IA: lectura propia. Crear jobs SOLO desde backend (cuotas).
create policy analysis_jobs_select on public.analysis_jobs for select to authenticated
  using (user_id = (select auth.uid()) or public.is_admin());
create policy analysis_results_select on public.analysis_results for select to authenticated
  using (public.is_admin() or exists (
    select 1 from public.analysis_jobs j
    where j.id = job_id and j.user_id = (select auth.uid())));

-- =====================================================================
-- Storage (buckets privados; las descargas usan URLs firmadas)
-- =====================================================================
insert into storage.buckets (id, name, public)
values ('resources', 'resources', false), ('analysis-inputs', 'analysis-inputs', false)
on conflict (id) do nothing;

create policy storage_resources_admin on storage.objects for all to authenticated
  using (bucket_id = 'resources' and public.is_admin())
  with check (bucket_id = 'resources' and public.is_admin());

-- Cada usuario sube/lee solo dentro de su carpeta: <user_id>/archivo.pdf
create policy storage_analysis_owner on storage.objects for all to authenticated
  using (bucket_id = 'analysis-inputs'
         and (storage.foldername(name))[1] = (select auth.uid())::text)
  with check (bucket_id = 'analysis-inputs'
         and (storage.foldername(name))[1] = (select auth.uid())::text);
