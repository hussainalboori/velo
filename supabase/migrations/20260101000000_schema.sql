-- ==========================================
-- Supabase Database Schema for Velo To-Do App
-- ==========================================

-- Enable UUID extension if not enabled
create extension if not exists "uuid-ossp";

-- 1. Create PROFILES Table
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  tier text not null default 'free',
  tokens_used bigint not null default 0,
  ads_watched_today bigint default 0,
  last_ad_date timestamptz
);

-- Enable RLS for Profiles
alter table public.profiles enable row level security;

-- Profiles Policies
create policy "Users can view their own profile"
  on public.profiles for select
  using (auth.uid() = id);

create policy "Users can update their own profile"
  on public.profiles for update
  using (auth.uid() = id);

-- Trigger to automatically create profile for new auth users
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, tier, tokens_used, ads_watched_today)
  values (new.id, 'free', 0, 0)
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();


-- 2. Create TASKS Table
create table if not exists public.tasks (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  title text not null,
  description text,
  category text default 'personal',
  is_completed boolean not null default false,
  priority_level bigint not null default 1,
  parent_id uuid references public.tasks(id) on delete cascade,
  due_date timestamptz,
  created_at timestamptz not null default now()
);

-- Enable RLS for Tasks
alter table public.tasks enable row level security;

-- Tasks Policies
create policy "Users can view their own tasks"
  on public.tasks for select
  using (auth.uid() = user_id);

create policy "Users can insert their own tasks"
  on public.tasks for insert
  with check (auth.uid() = user_id);

create policy "Users can update their own tasks"
  on public.tasks for update
  using (auth.uid() = user_id);

create policy "Users can delete their own tasks"
  on public.tasks for delete
  using (auth.uid() = user_id);

-- Indexes for performance
create index if not exists tasks_user_id_idx on public.tasks(user_id);
create index if not exists tasks_parent_id_idx on public.tasks(parent_id);


-- 3. Create AI USAGE LOGS Table
create table if not exists public.ai_usage_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  task_id uuid references public.tasks(id) on delete cascade,
  model text,
  prompt_tokens bigint,
  completion_tokens bigint,
  total_tokens bigint,
  created_at timestamptz default now()
);

-- Enable RLS for AI Usage Logs
alter table public.ai_usage_logs enable row level security;

-- AI Usage Logs Policies
create policy "Users can view their own AI usage logs"
  on public.ai_usage_logs for select
  using (auth.uid() = user_id);

create index if not exists ai_usage_logs_user_id_idx on public.ai_usage_logs(user_id);


-- 4. RPC Functions for Rewarded Ads and Token Management

-- Decrement token usage / reward token via watching ads
create or replace function public.decrement_user_tokens()
returns void
language plpgsql
security definer set search_path = public
as $$
begin
  update public.profiles
  set tokens_used = greatest(0, tokens_used - 1),
      ads_watched_today = coalesce(ads_watched_today, 0) + 1,
      last_ad_date = now()
  where id = auth.uid();
end;
$$;

-- Reset daily ad counter on day boundary rollover
create or replace function public.reset_daily_ad_limit()
returns void
language plpgsql
security definer set search_path = public
as $$
begin
  update public.profiles
  set ads_watched_today = 0,
      last_ad_date = null
  where id = auth.uid();
end;
$$;
