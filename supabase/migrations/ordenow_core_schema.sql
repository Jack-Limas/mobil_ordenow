create extension if not exists pgcrypto;

alter table if exists public.users
  add column if not exists role text not null default 'client';

update public.users
set role = 'admin'
where email = 'admin@ordenow.com' or id = 'admin';

create table if not exists public.restaurant_tables (
  id text primary key,
  number integer not null unique,
  occupied boolean not null default false,
  needs_payment boolean not null default false
);

create table if not exists public.menu_items (
  id text primary key,
  name text not null,
  description text not null default '',
  price numeric(10,2) not null default 0,
  category text not null default 'Plato',
  available boolean not null default true,
  recommended boolean not null default false,
  tags jsonb not null default '[]'::jsonb
);

alter table if exists public.menu_items
  add column if not exists image_url text not null default '';

create table if not exists public.orders (
  id text primary key,
  user_id text references public.users(id) on delete set null,
  table_id text references public.restaurant_tables(id) on delete set null,
  items jsonb not null default '[]'::jsonb,
  status text not null default 'pending',
  paid boolean not null default false,
  payment_method text not null default 'cash',
  total_amount numeric(10,2) not null default 0,
  notes text not null default '',
  synced boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.cash_requests (
  id text primary key,
  order_id text references public.orders(id) on delete set null,
  table_id text references public.restaurant_tables(id) on delete set null,
  amount numeric(10,2) not null default 0,
  method text not null default 'cash',
  status text not null default 'pending',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

insert into public.users (
  id,
  email,
  full_name,
  password,
  role,
  allergies,
  preferences,
  created_at,
  updated_at
)
values (
  'admin',
  'admin@ordenow.com',
  'Administrador',
  '12345678',
  'admin',
  '[]'::jsonb,
  '[]'::jsonb,
  now(),
  now()
)
on conflict (email) do update set
  password = excluded.password,
  role = 'admin',
  updated_at = now();

insert into public.restaurant_tables (id, number, occupied, needs_payment)
select gen_random_uuid()::text, number, false, false
from generate_series(1, 20) as number
on conflict (number) do nothing;
