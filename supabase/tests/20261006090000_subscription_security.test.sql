begin;

select plan(5);

select ok(
  to_regprocedure('public.has_active_subscription()') is not null,
  'subscription check has no caller-provided user ID'
);
select ok(
  to_regprocedure('public.has_active_subscription(uuid)') is null,
  'UUID-accepting subscription check is removed'
);
select ok(
  position(
    'auth.uid()' in pg_get_functiondef(
      to_regprocedure('public.has_active_subscription()')
    )
  ) > 0,
  'subscription check scopes its query to the JWT user'
);
select ok(
  not has_function_privilege(
    'anon',
    'public.has_active_subscription()',
    'EXECUTE'
  ),
  'anonymous users cannot execute the subscription check'
);
select ok(
  has_function_privilege(
    'authenticated',
    'public.has_active_subscription()',
    'EXECUTE'
  ),
  'authenticated users can execute the subscription check for RLS'
);

select * from finish();

rollback;
