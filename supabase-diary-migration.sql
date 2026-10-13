-- Run this migration after the original reactions setup already exists.
-- It is safe to run again if the diary tables or bucket were created partially.

create table if not exists public.daily_answers (
  id bigint generated always as identity primary key,
  task_date date not null,
  participant text not null check (participant in ('keshav', 'aastha')),
  answer text not null check (char_length(answer) between 1 and 1000),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (task_date, participant)
);

alter table public.daily_answers enable row level security;
grant select, insert, update on table public.daily_answers to anon;
grant usage, select on sequence public.daily_answers_id_seq to anon;

drop policy if exists "Anyone with the private site link can read daily answers" on public.daily_answers;
create policy "Anyone with the private site link can read daily answers"
on public.daily_answers for select to anon using (true);

drop policy if exists "Anyone with the private site link can save daily answers" on public.daily_answers;
create policy "Anyone with the private site link can save daily answers"
on public.daily_answers for insert to anon
with check (participant in ('keshav', 'aastha') and char_length(answer) between 1 and 1000);

drop policy if exists "Anyone with the private site link can update daily answers" on public.daily_answers;
create policy "Anyone with the private site link can update daily answers"
on public.daily_answers for update to anon
using (participant in ('keshav', 'aastha'))
with check (participant in ('keshav', 'aastha') and char_length(answer) between 1 and 1000);

create or replace function public.set_daily_answer_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists daily_answers_updated_at on public.daily_answers;
create trigger daily_answers_updated_at
before update on public.daily_answers
for each row execute function public.set_daily_answer_updated_at();

create table if not exists public.daily_diary (
  id bigint generated always as identity primary key,
  task_date date not null,
  participant text not null check (participant in ('keshav', 'aastha')),
  photo_url text not null,
  caption text not null default '' check (char_length(caption) <= 240),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (task_date, participant)
);

alter table public.daily_diary enable row level security;
grant select, insert, update on table public.daily_diary to anon;
grant usage, select on sequence public.daily_diary_id_seq to anon;

drop policy if exists "Anyone with the private site link can read diary pages" on public.daily_diary;
create policy "Anyone with the private site link can read diary pages"
on public.daily_diary for select to anon using (true);

drop policy if exists "Anyone with the private site link can save diary pages" on public.daily_diary;
create policy "Anyone with the private site link can save diary pages"
on public.daily_diary for insert to anon
with check (participant in ('keshav', 'aastha') and char_length(caption) <= 240);

drop policy if exists "Anyone with the private site link can update diary pages" on public.daily_diary;
create policy "Anyone with the private site link can update diary pages"
on public.daily_diary for update to anon
using (participant in ('keshav', 'aastha'))
with check (participant in ('keshav', 'aastha') and char_length(caption) <= 240);

drop trigger if exists daily_diary_updated_at on public.daily_diary;
create trigger daily_diary_updated_at
before update on public.daily_diary
for each row execute function public.set_daily_answer_updated_at();

do $$
begin
  if not exists (select 1 from pg_publication_rel pr join pg_class c on c.oid = pr.prrelid join pg_publication p on p.oid = pr.prpubid where p.pubname = 'supabase_realtime' and c.relname = 'daily_answers') then
    alter publication supabase_realtime add table public.daily_answers;
  end if;
  if not exists (select 1 from pg_publication_rel pr join pg_class c on c.oid = pr.prrelid join pg_publication p on p.oid = pr.prpubid where p.pubname = 'supabase_realtime' and c.relname = 'daily_diary') then
    alter publication supabase_realtime add table public.daily_diary;
  end if;
end $$;

insert into storage.buckets (id, name, public)
values ('diary-photos', 'diary-photos', true)
on conflict (id) do update set public = true;

drop policy if exists "Anyone with the private site link can read diary photos" on storage.objects;
create policy "Anyone with the private site link can read diary photos"
on storage.objects for select to anon using (bucket_id = 'diary-photos');

drop policy if exists "Anyone with the private site link can upload diary photos" on storage.objects;
create policy "Anyone with the private site link can upload diary photos"
on storage.objects for insert to anon with check (bucket_id = 'diary-photos');

drop policy if exists "Anyone with the private site link can update diary photos" on storage.objects;
create policy "Anyone with the private site link can update diary photos"
on storage.objects for update to anon
using (bucket_id = 'diary-photos') with check (bucket_id = 'diary-photos');
