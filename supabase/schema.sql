-- ================================================================
-- Where Am I? — Supabase Schema
-- Run this in: Supabase Dashboard → SQL Editor → New Query
-- ================================================================

-- ── Cases table ──────────────────────────────────────────────────
create table if not exists public.cases (
  id             uuid primary key default gen_random_uuid(),
  name           text not null,
  nationality    text,
  birth_date     date,
  last_seen_date date,
  last_seen_location text,
  sex            char(1) default 'U' check (sex in ('M', 'F', 'U')),
  height_cm      int check (height_cm > 0 and height_cm < 300),
  photo_urls     text[] default '{}',
  facts          text[] default '{}',
  contacts       jsonb default '[]',
  source         text default 'user' check (source in ('user', 'admin')),
  status         text default 'pending'
                   check (status in ('pending', 'approved', 'resolved', 'rejected')),
  reported_by    uuid references auth.users(id) on delete set null,
  created_at     timestamptz default now(),
  updated_at     timestamptz default now()
);

-- ── Indexes ───────────────────────────────────────────────────────
create index if not exists cases_status_created
  on public.cases (status, created_at desc);

create index if not exists cases_nationality
  on public.cases (nationality);

-- ── Auto-update updated_at ────────────────────────────────────────
create or replace function public.handle_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger cases_updated_at
  before update on public.cases
  for each row execute procedure public.handle_updated_at();

-- ── Row Level Security ────────────────────────────────────────────
alter table public.cases enable row level security;

-- Anyone (including unauthenticated) can read approved cases
create policy "Public read approved cases"
  on public.cases for select
  using (status = 'approved');

-- Authenticated users can submit new cases
create policy "Authenticated users can insert"
  on public.cases for insert
  with check (auth.uid() = reported_by);

-- Users can update their own pending cases
create policy "Reporter can update own case"
  on public.cases for update
  using (auth.uid() = reported_by);

-- ── Storage bucket for case photos ───────────────────────────────
-- Run this separately in: Supabase Dashboard → Storage → New bucket
-- Bucket name: case-photos
-- Public: true (so photo URLs work without auth)

-- Storage policy (run after creating the bucket):
-- insert into storage.buckets (id, name, public) values ('case-photos', 'case-photos', true);

create policy "Anyone can view case photos"
  on storage.objects for select
  using (bucket_id = 'case-photos');

create policy "Authenticated users can upload photos"
  on storage.objects for insert
  with check (
    bucket_id = 'case-photos' and
    auth.uid() is not null
  );

-- ── Admin: allow updating status (add your user ID) ──────────────
-- Replace 'YOUR-ADMIN-UUID' with your Supabase Auth user ID
-- create policy "Admin can update any case"
--   on public.cases for update
--   using (auth.uid() = 'YOUR-ADMIN-UUID');
