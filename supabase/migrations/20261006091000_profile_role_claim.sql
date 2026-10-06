create schema if not exists private;
revoke all on schema private from public;
grant usage on schema private to authenticated;

create or replace function private.is_admin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.profiles p
    where p.id = (select auth.uid())
      and p.role = 'admin'
  );
$$;

revoke all on function private.is_admin() from public, anon;
grant execute on function private.is_admin() to authenticated;

create or replace function public.custom_access_token_hook(event jsonb)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  profile_role text;
  claims jsonb;
begin
  if event ->> 'user_id' is null
     or jsonb_typeof(event -> 'claims') is distinct from 'object' then
    raise exception 'Custom access token hook received an invalid event';
  end if;

  select p.role::text
  into profile_role
  from public.profiles p
  where p.id = (event ->> 'user_id')::uuid;

  if profile_role is null then
    raise exception 'No profile role found for authenticated user';
  end if;

  claims := jsonb_set(
    event -> 'claims',
    '{user_role}',
    to_jsonb(profile_role),
    true
  );

  return jsonb_set(event, '{claims}', claims, true);
end;
$$;

revoke all on function public.custom_access_token_hook(jsonb)
  from public, anon, authenticated, service_role;
grant execute on function public.custom_access_token_hook(jsonb)
  to supabase_auth_admin;

alter policy profiles_select on public.profiles
  using (id = (select auth.uid()) or private.is_admin());

alter policy plans_select on public.plans
  using (is_active or private.is_admin());
alter policy plans_admin_write on public.plans
  using (private.is_admin())
  with check (private.is_admin());

alter policy subscriptions_select on public.subscriptions
  using (user_id = (select auth.uid()) or private.is_admin());
alter policy payments_select on public.payments
  using (user_id = (select auth.uid()) or private.is_admin());

alter policy courses_select on public.courses
  using (status = 'published' or private.is_admin());
alter policy courses_admin_write on public.courses
  using (private.is_admin())
  with check (private.is_admin());

alter policy sections_select on public.course_sections
  using (private.is_admin() or exists (
    select 1 from public.courses c
    where c.id = course_id and c.status = 'published'
  ));
alter policy sections_admin_write on public.course_sections
  using (private.is_admin())
  with check (private.is_admin());

alter policy lessons_select on public.lessons
  using (private.is_admin() or (status = 'published' and exists (
    select 1 from public.courses c
    where c.id = course_id and c.status = 'published'
  )));
alter policy lessons_admin_write on public.lessons
  using (private.is_admin())
  with check (private.is_admin());

alter policy lesson_videos_admin on public.lesson_videos
  using (private.is_admin())
  with check (private.is_admin());

alter policy resources_select on public.resources
  using (
    private.is_admin()
    or (status = 'published'
        and (not requires_subscription
             or public.has_active_subscription()))
  );
alter policy resources_admin_write on public.resources
  using (private.is_admin())
  with check (private.is_admin());

alter policy analysis_jobs_select on public.analysis_jobs
  using (user_id = (select auth.uid()) or private.is_admin());
alter policy analysis_results_select on public.analysis_results
  using (private.is_admin() or exists (
    select 1 from public.analysis_jobs j
    where j.id = job_id and j.user_id = (select auth.uid())
  ));

alter policy storage_resources_admin on storage.objects
  using (bucket_id = 'resources' and private.is_admin())
  with check (bucket_id = 'resources' and private.is_admin());

drop function public.is_admin();
