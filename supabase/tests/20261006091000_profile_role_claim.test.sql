begin;

select plan(8);

insert into auth.users (
  id,
  aud,
  role,
  email,
  encrypted_password,
  raw_app_meta_data,
  raw_user_meta_data
)
values (
  '00000000-0000-4000-8000-000000000091',
  'authenticated',
  'authenticated',
  'profile-role-hook@example.invalid',
  '',
  '{"role":"subscriber"}'::jsonb,
  '{}'::jsonb
);

update public.profiles
set role = 'admin'
where id = '00000000-0000-4000-8000-000000000091';

select is(
  public.custom_access_token_hook(
    jsonb_build_object(
      'user_id', '00000000-0000-4000-8000-000000000091',
      'claims', jsonb_build_object(
        'sub', '00000000-0000-4000-8000-000000000091',
        'app_metadata', jsonb_build_object('role', 'subscriber')
      )
    )
  ) #>> '{claims,user_role}',
  'admin',
  'token role is read from profiles.role, not app_metadata'
);

select set_config(
  'request.jwt.claim.sub',
  '00000000-0000-4000-8000-000000000091',
  true
);
select ok(private.is_admin(), 'private.is_admin recognizes profile admins');

update public.profiles
set role = 'subscriber'
where id = '00000000-0000-4000-8000-000000000091';
select ok(not private.is_admin(), 'private.is_admin rejects subscribers');

select ok(
  to_regprocedure('private.is_admin()') is not null
    and to_regprocedure('public.is_admin()') is null,
  'only the private is_admin function remains'
);
select ok(
  has_function_privilege(
    'supabase_auth_admin',
    'public.custom_access_token_hook(jsonb)',
    'EXECUTE'
  ),
  'Supabase Auth can execute the custom access token hook'
);
select ok(
  not has_function_privilege(
    'authenticated',
    'public.custom_access_token_hook(jsonb)',
    'EXECUTE'
  ),
  'authenticated users cannot execute the custom access token hook'
);
select ok(
  has_function_privilege(
    'authenticated',
    'private.is_admin()',
    'EXECUTE'
  ),
  'authenticated users can evaluate RLS admin policies'
);
select ok(
  not has_function_privilege('anon', 'private.is_admin()', 'EXECUTE'),
  'anonymous users cannot execute the private admin check'
);

select * from finish();

rollback;
