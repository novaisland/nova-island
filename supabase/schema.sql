-- NOVA ISLAND online foundation
-- Supabase PostgreSQL schema. Apply in Supabase SQL Editor.
-- Provides authenticated profiles and private cloud-save storage.
-- Gameplay currency/items remain client-side until server-authoritative Edge Functions
-- are implemented. Never treat a client-submitted save as a trusted economy ledger.

create extension if not exists pgcrypto;

create table if not exists public.player_profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null default 'Island Explorer'
    check (char_length(display_name) between 2 and 24),
  avatar_key text not null default 'starter',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.player_saves (
  user_id uuid primary key references auth.users(id) on delete cascade,
  save_version integer not null default 1 check (save_version > 0),
  save_data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now(),
  constraint player_saves_size_limit check (pg_column_size(save_data) < 1048576)
);

create index if not exists player_saves_updated_at_idx
  on public.player_saves (updated_at desc);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists player_profiles_set_updated_at on public.player_profiles;
create trigger player_profiles_set_updated_at
before update on public.player_profiles
for each row execute function public.set_updated_at();

drop trigger if exists player_saves_set_updated_at on public.player_saves;
create trigger player_saves_set_updated_at
before update on public.player_saves
for each row execute function public.set_updated_at();

create or replace function public.handle_new_player()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  chosen_name text;
begin
  chosen_name := coalesce(
    nullif(left(trim(new.raw_user_meta_data ->> 'display_name'), 24), ''),
    'Explorer-' || left(new.id::text, 6)
  );

  insert into public.player_profiles (user_id, display_name)
  values (new.id, chosen_name)
  on conflict (user_id) do nothing;

  insert into public.player_saves (user_id, save_version, save_data)
  values (new.id, 1, '{}'::jsonb)
  on conflict (user_id) do nothing;

  return new;
end;
$$;

drop trigger if exists on_auth_user_created_nova on auth.users;
create trigger on_auth_user_created_nova
after insert on auth.users
for each row execute function public.handle_new_player();

alter table public.player_profiles enable row level security;
alter table public.player_saves enable row level security;

drop policy if exists "Profiles are viewable by everyone" on public.player_profiles;
create policy "Profiles are viewable by everyone"
  on public.player_profiles for select
  using (true);

drop policy if exists "Players can update their own profile" on public.player_profiles;
create policy "Players can update their own profile"
  on public.player_profiles for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "Players can read their own cloud save" on public.player_saves;
create policy "Players can read their own cloud save"
  on public.player_saves for select
  using (auth.uid() = user_id);

drop policy if exists "Players can create their own cloud save" on public.player_saves;
create policy "Players can create their own cloud save"
  on public.player_saves for insert
  with check (auth.uid() = user_id);

drop policy if exists "Players can update their own cloud save" on public.player_saves;
create policy "Players can update their own cloud save"
  on public.player_saves for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

grant select on public.player_profiles to anon, authenticated;
grant update (display_name, avatar_key) on public.player_profiles to authenticated;
grant select, insert, update on public.player_saves to authenticated;
revoke all on public.player_saves from anon;
