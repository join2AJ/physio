-- ============================================================
--  Dr. Vikas Patient Monitoring System — Supabase schema
--  Run this ONCE in your Supabase project:
--    Dashboard  ->  SQL Editor  ->  New query  ->  paste  ->  Run
-- ============================================================

-- 1) The table that holds every visit / row in the app.
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

-- Helpful indexes for the reports / date grouping.
create index if not exists visits_user_date_idx on public.visits (user_id, date);

-- Keep updated_at fresh automatically.
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

-- 2) ROW LEVEL SECURITY — this is what actually protects the data.
--    Without these policies, ANY logged-in user could read/write
--    everyone's records. With them, each account only ever sees its own.
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
