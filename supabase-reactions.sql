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

-- Shared daily task answers. The date is the user's local calendar date;
-- one answer per participant is kept for each day so older answers remain archived.
create table public.daily_answers (
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

create policy "Anyone with the private site link can read daily answers"
on public.daily_answers for select to anon using (true);

create policy "Anyone with the private site link can save daily answers"
on public.daily_answers for insert to anon
with check (participant in ('keshav', 'aastha') and char_length(answer) between 1 and 1000);

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

create trigger daily_answers_updated_at
before update on public.daily_answers
for each row execute function public.set_daily_answer_updated_at();

alter publication supabase_realtime add table public.daily_answers;

create or replace function public.reaction_counts()
returns table(kind text, count bigint)
language sql security definer set search_path = public
as $$
  select kind, count(*) from public.reactions group by kind;
$$;

grant execute on function public.reaction_counts() to anon;

-- Shared two-page daily photo diary.
create table public.daily_diary (
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

create policy "Anyone with the private site link can read diary pages"
on public.daily_diary for select to anon using (true);

create policy "Anyone with the private site link can save diary pages"
on public.daily_diary for insert to anon
with check (participant in ('keshav', 'aastha') and char_length(caption) <= 240);

create policy "Anyone with the private site link can update diary pages"
on public.daily_diary for update to anon
using (participant in ('keshav', 'aastha'))
with check (participant in ('keshav', 'aastha') and char_length(caption) <= 240);

create trigger daily_diary_updated_at
before update on public.daily_diary
for each row execute function public.set_daily_answer_updated_at();

alter publication supabase_realtime add table public.daily_diary;

insert into storage.buckets (id, name, public)
values ('diary-photos', 'diary-photos', true)
on conflict (id) do update set public = true;

create policy "Anyone with the private site link can read diary photos"
on storage.objects for select to anon
using (bucket_id = 'diary-photos');

create policy "Anyone with the private site link can upload diary photos"
on storage.objects for insert to anon
with check (bucket_id = 'diary-photos');

create policy "Anyone with the private site link can update diary photos"
on storage.objects for update to anon
using (bucket_id = 'diary-photos')
with check (bucket_id = 'diary-photos');
