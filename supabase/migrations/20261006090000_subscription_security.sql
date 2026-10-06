drop policy resources_select on public.resources;

drop function public.has_active_subscription(uuid);

create function public.has_active_subscription()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.subscriptions s
    where s.user_id = (select auth.uid())
      and s.status = 'active'
      and (s.current_period_end is null or s.current_period_end > now())
  );
$$;

revoke all on function public.has_active_subscription() from public, anon;
grant execute on function public.has_active_subscription() to authenticated;

create policy resources_select on public.resources for select to authenticated
  using (
    public.is_admin()
    or (status = 'published'
        and (not requires_subscription
             or public.has_active_subscription()))
  );
