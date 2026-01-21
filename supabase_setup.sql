-- Supabase Setup Script for Glasscast
-- Run this in the Supabase SQL Editor

-- 1. Create the favorite_cities table
create table favorite_cities (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users not null,
  city_name text not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 2. Enable Row Level Security (RLS)
alter table favorite_cities enable row level security;

-- 3. Create RLS Policies
-- Allow users to view their own favorites
create policy "Users can view their own favorites"
on favorite_cities for select
using (auth.uid() = user_id);

-- Allow users to insert their own favorites
create policy "Users can insert their own favorites"
on favorite_cities for insert
with check (auth.uid() = user_id);

-- Allow users to delete their own favorites
create policy "Users can delete their own favorites"
on favorite_cities for delete
using (auth.uid() = user_id);

-- 4. Create Index for performance
create index idx_favorite_cities_user_id on favorite_cities(user_id);
