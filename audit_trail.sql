-- ============================================================
--  AUDIT TRAIL  — tamper-evident log of every change to visits.
--  Supports ISO 27001 A.8.15 (Logging) / NIST CSF DE.AE, PR.PT.
--  Run in: Supabase -> SQL Editor -> New query -> paste -> Run.
-- ============================================================

create table if not exists public.audit_log (
  id           bigint generated always as identity primary key,
  user_id      uuid,
  action       text not null,                 -- INSERT | UPDATE | DELETE
  table_name   text not null,
  row_id       text,
  patient_name text,
  changed_at   timestamptz not null default now(),
  old_data     jsonb,
  new_data     jsonb
);

create index if not exists audit_log_user_time_idx on public.audit_log (user_id, changed_at desc);

-- Row Level Security: a user may READ their own audit entries, and nothing else.
-- There are deliberately NO insert/update/delete policies for users, so the log
-- is append-only and cannot be edited or erased from the app (tamper-evidence).
-- Only the trigger below (SECURITY DEFINER) can write to it.
alter table public.audit_log enable row level security;

drop policy if exists "own audit - select" on public.audit_log;
create policy "own audit - select" on public.audit_log
  for select using (auth.uid() = user_id);

-- Trigger function: records who changed what, when, with before/after snapshots.
create or replace function public.log_visit_change()
returns trigger language plpgsql security definer set search_path = public as $$
declare
  v_uid uuid;
begin
  v_uid := coalesce(auth.uid(),
                    case when TG_OP = 'DELETE' then OLD.user_id else NEW.user_id end);
  insert into public.audit_log (user_id, action, table_name, row_id, patient_name, old_data, new_data)
  values (
    v_uid,
    TG_OP,
    TG_TABLE_NAME,
    case when TG_OP = 'DELETE' then OLD.id           else NEW.id           end,
    case when TG_OP = 'DELETE' then OLD.patient_name else NEW.patient_name end,
    case when TG_OP in ('UPDATE','DELETE') then to_jsonb(OLD) else null end,
    case when TG_OP in ('INSERT','UPDATE') then to_jsonb(NEW) else null end
  );
  return case when TG_OP = 'DELETE' then OLD else NEW end;
end $$;

drop trigger if exists visits_audit on public.visits;
create trigger visits_audit
  after insert or update or delete on public.visits
  for each row execute function public.log_visit_change();
