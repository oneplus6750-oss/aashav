-- Run this standalone file in Supabase SQL Editor.
-- It does not recreate or modify the existing reactions table.

create table if not exists public.diwali_wishes (
  id bigint generated always as identity primary key,
  diwali_date date not null,
  participant text not null check (participant in ('keshav', 'aastha')),
  wish text not null check (char_length(wish) between 1 and 180),
  created_at timestamptz not null default now(),
  unique (diwali_date, participant)
);

alter table public.diwali_wishes enable row level security;
grant select, insert, update on public.diwali_wishes to anon;
grant usage, select on sequence public.diwali_wishes_id_seq to anon;

drop policy if exists "diwali wishes read" on public.diwali_wishes;
create policy "diwali wishes read" on public.diwali_wishes for select to anon using (true);

drop policy if exists "diwali wishes insert" on public.diwali_wishes;
create policy "diwali wishes insert" on public.diwali_wishes for insert to anon
with check (participant in ('keshav', 'aastha') and char_length(wish) between 1 and 180);

drop policy if exists "diwali wishes update" on public.diwali_wishes;
create policy "diwali wishes update" on public.diwali_wishes for update to anon
using (participant in ('keshav', 'aastha'))
with check (participant in ('keshav', 'aastha') and char_length(wish) between 1 and 180);

create table if not exists public.diwali_diyas (
  id bigint generated always as identity primary key,
  diwali_date date not null,
  participant text not null check (participant in ('keshav', 'aastha')),
  lit_at timestamptz not null default now(),
  unique (diwali_date, participant)
);

alter table public.diwali_diyas enable row level security;
grant select, insert, update on public.diwali_diyas to anon;
grant usage, select on sequence public.diwali_diyas_id_seq to anon;

drop policy if exists "diwali diyas read" on public.diwali_diyas;
create policy "diwali diyas read" on public.diwali_diyas for select to anon using (true);

drop policy if exists "diwali diyas insert" on public.diwali_diyas;
create policy "diwali diyas insert" on public.diwali_diyas for insert to anon
with check (participant in ('keshav', 'aastha'));

drop policy if exists "diwali diyas update" on public.diwali_diyas;
create policy "diwali diyas update" on public.diwali_diyas for update to anon
using (participant in ('keshav', 'aastha'))
with check (participant in ('keshav', 'aastha'));
