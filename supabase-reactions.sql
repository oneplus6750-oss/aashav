-- Run this once in Supabase Dashboard → SQL Editor.
-- It stores only the reaction type and time; no names, phone numbers, or text.
create table public.reactions (
  id bigint generated always as identity primary key,
  kind text not null check (kind in ('hug', 'kiss')),
  created_at timestamptz not null default now()
);

alter table public.reactions enable row level security;

grant select, insert on table public.reactions to anon;
grant usage, select on sequence public.reactions_id_seq to anon;

create policy "Anyone with the private site link can read reactions"
on public.reactions for select to anon using (true);

create policy "Anyone with the private site link can send reactions"
on public.reactions for insert to anon with check (kind in ('hug', 'kiss'));

alter publication supabase_realtime add table public.reactions;
