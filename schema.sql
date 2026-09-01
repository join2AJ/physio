-- ============================================================
--  Dr. Vikas Patient Monitoring System — Supabase schema
--  Run this ONCE in your Supabase project:
--    Dashboard  ->  SQL Editor  ->  New query  ->  paste ALL  ->  Run
-- ============================================================

-- ============================================================
--  1) VISITS  — every patient row in the app.
-- ============================================================
create table if not exists public.visits (
  id               text primary key,              -- app-generated id
  user_id          uuid not null references auth.users (id) on delete cascade,
  date             date not null,
  patient_name     text,
  status           text,                           -- 'Completed' | 'Not completed' | null
  amount           numeric,
  diagnosis        text,
  reason           text,
  updated_at_label text,                           -- human label shown in the UI
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now()
);

create index if not exists visits_user_date_idx on public.visits (user_id, date);

create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end $$;

drop trigger if exists visits_set_updated_at on public.visits;
create trigger visits_set_updated_at
  before update on public.visits
  for each row execute function public.set_updated_at();

-- ROW LEVEL SECURITY — each account only ever sees its own rows.
alter table public.visits enable row level security;

drop policy if exists "own rows - select" on public.visits;
create policy "own rows - select" on public.visits
  for select using (auth.uid() = user_id);

drop policy if exists "own rows - insert" on public.visits;
create policy "own rows - insert" on public.visits
  for insert with check (auth.uid() = user_id);

drop policy if exists "own rows - update" on public.visits;
create policy "own rows - update" on public.visits
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "own rows - delete" on public.visits;
create policy "own rows - delete" on public.visits
  for delete using (auth.uid() = user_id);


-- ============================================================
--  2) PROFILES  — one row per user, holds their display name.
--     Powers the personalised greeting ("Welcome, Dr. ...").
-- ============================================================
create table if not exists public.profiles (
  id         uuid primary key references auth.users (id) on delete cascade,
  full_name  text,
  updated_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

drop policy if exists "own profile - select" on public.profiles;
create policy "own profile - select" on public.profiles
  for select using (auth.uid() = id);

drop policy if exists "own profile - insert" on public.profiles;
create policy "own profile - insert" on public.profiles
  for insert with check (auth.uid() = id);

drop policy if exists "own profile - update" on public.profiles;
create policy "own profile - update" on public.profiles
  for update using (auth.uid() = id) with check (auth.uid() = id);

-- When a new user is created (by you in the dashboard, or via sign-up),
-- automatically create their profile row. If you set a "Display name"
-- or full_name in the user's metadata, it is copied in.
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, full_name)
  values (new.id, coalesce(new.raw_user_meta_data->>'full_name',
                           new.raw_user_meta_data->>'name', ''))
  on conflict (id) do nothing;
  return new;
end $$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- Backfill profiles for any users that already exist.
insert into public.profiles (id, full_name)
select id, coalesce(raw_user_meta_data->>'full_name', raw_user_meta_data->>'name', '')
from auth.users
on conflict (id) do nothing;
