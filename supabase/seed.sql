-- Datos de desarrollo. Los IDs de pasarela se completan en la Fase 4.
insert into public.plans (slug, name, description, price, currency, billing_interval, ai_monthly_quota, features)
values
  ('mensual', 'Plan Mensual', 'Acceso completo a clases, recursos y herramientas IA.', 499.00, 'MXN', 'month', 30,
   '["Clases grabadas","Recursos descargables","Herramientas IA"]'),
  ('anual', 'Plan Anual', 'Igual que el mensual con ahorro anual.', 4990.00, 'MXN', 'year', 40,
   '["Clases grabadas","Recursos descargables","Herramientas IA","2 meses gratis"]')
on conflict (slug) do nothing;

-- Para desarrollar sin pasarela de pago, activa una suscripción manualmente:
-- insert into public.subscriptions (user_id, plan_id, status, provider, current_period_end)
-- select '<USER_UUID>', id, 'active', 'manual', now() + interval '30 days'
-- from public.plans where slug = 'mensual';
--
-- Para promover a admin (solo con service_role / SQL editor):
-- update public.profiles set role = 'admin' where email = 'tu@correo.com';
-- y en Auth > Users, añade {"role":"admin"} en app_metadata.