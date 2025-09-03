-- Updated Krushak App Database Schema
-- This schema matches the implemented Supabase service methods and application requirements

-- Enable necessary extensions
create extension if not exists "uuid-ossp";

-- Users table
create table if not exists public.users (
  id uuid references auth.users on delete cascade not null primary key,
  email text unique not null,
  full_name text,
  phone text,
  avatar_url text,
  farmer_type text, -- 'small', 'medium', 'large'
  farm_size numeric, -- in acres/hectares
  location jsonb, -- {state, district, village, coordinates}
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Farms table
create table if not exists public.farms (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references public.users(id) on delete cascade not null,
  name text not null,
  size numeric not null, -- in acres/hectares
  location jsonb, -- {latitude, longitude, address}
  soil_type text,
  irrigation_type text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Crops table
create table if not exists public.crops (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references public.users(id) on delete cascade not null,
  farm_id uuid references public.farms(id) on delete cascade,
  name text not null,
  variety text,
  planted_date date,
  expected_harvest_date date,
  actual_harvest_date date,
  area numeric, -- area under this crop
  yield_expected numeric,
  yield_actual numeric,
  status text default 'planted', -- 'planted', 'growing', 'harvested', 'sold'
  notes text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Crop diagnosis table
create table if not exists public.crop_diagnoses (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references public.users(id) on delete cascade not null,
  crop_name text not null,
  symptoms text not null,
  image_url text,
  diagnosis jsonb, -- AI diagnosis result
  confidence_score numeric, -- 0-1
  recommendations jsonb, -- array of recommendations
  treatments jsonb, -- array of treatment options
  expert_tips jsonb, -- array of expert tips
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Financial records table
create table if not exists public.financial_records (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references public.users(id) on delete cascade not null,
  farm_id uuid references public.farms(id) on delete cascade,
  crop_id uuid references public.crops(id) on delete cascade,
  type text not null, -- 'income', 'expense'
  category text not null, -- 'seeds', 'fertilizer', 'labor', 'equipment', 'sale', etc.
  amount numeric not null,
  description text,
  date date not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Market prices table
create table if not exists public.market_prices (
  id uuid default uuid_generate_v4() primary key,
  commodity text not null,
  market_name text not null,
  location text,
  price numeric not null,
  unit text not null, -- 'kg', 'quintal', 'ton'
  date date not null,
  source text, -- data source
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Orders table (for marketplace)
create table if not exists public.orders (
  id uuid default uuid_generate_v4() primary key,
  buyer_id uuid references public.users(id) on delete cascade not null,
  seller_id uuid references public.users(id) on delete cascade,
  product_name text not null,
  quantity numeric not null,
  unit text not null,
  price_per_unit numeric not null,
  total_amount numeric not null,
  status text default 'pending', -- 'pending', 'confirmed', 'shipped', 'delivered', 'cancelled'
  delivery_address jsonb,
  notes text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Notifications table
create table if not exists public.notifications (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references public.users(id) on delete cascade not null,
  title text not null,
  message text not null,
  type text not null, -- 'info', 'warning', 'success', 'error'
  read boolean default false,
  data jsonb, -- additional data for the notification
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Announcements table (for community/admin announcements)
create table if not exists public.announcements (
  id uuid default uuid_generate_v4() primary key,
  title text not null,
  content text not null,
  type text not null, -- 'general', 'weather', 'market', 'scheme', 'alert'
  priority text default 'normal', -- 'low', 'normal', 'high', 'urgent'
  target_audience jsonb, -- filters like location, farm_size, etc.
  is_active boolean default true,
  expires_at timestamp with time zone,
  created_by uuid references public.users(id),
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Weather data table
create table if not exists public.weather_data (
  id uuid default uuid_generate_v4() primary key,
  location jsonb not null, -- {latitude, longitude, place_name}
  date date not null,
  temperature_max numeric,
  temperature_min numeric,
  humidity numeric,
  rainfall numeric,
  wind_speed numeric,
  weather_condition text,
  forecast_data jsonb, -- 7-day forecast
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Learning content table
create table if not exists public.learning_content (
  id uuid default uuid_generate_v4() primary key,
  title text not null,
  content text not null,
  type text not null, -- 'article', 'video', 'pdf', 'course'
  category text not null, -- 'crop_management', 'pest_control', 'irrigation', etc.
  tags text[], -- array of tags
  difficulty_level text, -- 'beginner', 'intermediate', 'advanced'
  estimated_duration integer, -- in minutes
  thumbnail_url text,
  content_url text, -- for videos/pdfs
  is_featured boolean default false,
  view_count integer default 0,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Community posts table
create table if not exists public.community_posts (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references public.users(id) on delete cascade not null,
  title text,
  content text not null,
  images text[], -- array of image URLs
  tags text[], -- array of tags
  likes_count integer default 0,
  comments_count integer default 0,
  is_question boolean default false,
  is_answered boolean default false,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Community comments table
create table if not exists public.community_comments (
  id uuid default uuid_generate_v4() primary key,
  post_id uuid references public.community_posts(id) on delete cascade not null,
  user_id uuid references public.users(id) on delete cascade not null,
  content text not null,
  is_answer boolean default false,
  likes_count integer default 0,
  parent_comment_id uuid references public.community_comments(id),
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Bank loan applications table
create table if not exists public.loan_applications (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references public.users(id) on delete cascade not null,
  bank_name text not null,
  loan_type text not null, -- 'crop_loan', 'equipment_loan', 'land_loan', etc.
  amount_requested numeric not null,
  amount_approved numeric,
  interest_rate numeric,
  tenure_months integer,
  purpose text not null,
  status text default 'draft', -- 'draft', 'submitted', 'under_review', 'approved', 'rejected', 'disbursed'
  application_data jsonb, -- form data
  documents jsonb, -- document URLs and metadata
  bank_response jsonb, -- bank's response and comments
  submitted_at timestamp with time zone,
  approved_at timestamp with time zone,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Government schemes table
create table if not exists public.government_schemes (
  id uuid default uuid_generate_v4() primary key,
  name text not null,
  description text not null,
  eligibility_criteria jsonb,
  benefits jsonb,
  application_process jsonb,
  required_documents text[],
  deadline date,
  contact_info jsonb,
  state text,
  district text,
  is_active boolean default true,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Create indexes for better performance
create index if not exists idx_users_email on public.users(email);
create index if not exists idx_farms_user_id on public.farms(user_id);
create index if not exists idx_crops_user_id on public.crops(user_id);
create index if not exists idx_crops_farm_id on public.crops(farm_id);
create index if not exists idx_financial_records_user_id on public.financial_records(user_id);
create index if not exists idx_financial_records_date on public.financial_records(date);
create index if not exists idx_market_prices_commodity on public.market_prices(commodity);
create index if not exists idx_market_prices_date on public.market_prices(date);
create index if not exists idx_orders_buyer_id on public.orders(buyer_id);
create index if not exists idx_orders_seller_id on public.orders(seller_id);
create index if not exists idx_notifications_user_id on public.notifications(user_id);
create index if not exists idx_announcements_created_at on public.announcements(created_at);
create index if not exists idx_community_posts_user_id on public.community_posts(user_id);
create index if not exists idx_community_comments_post_id on public.community_comments(post_id);
create index if not exists idx_loan_applications_user_id on public.loan_applications(user_id);

-- Row Level Security (RLS) policies

-- Enable RLS on all tables
alter table public.users enable row level security;
alter table public.farms enable row level security;
alter table public.crops enable row level security;
alter table public.crop_diagnoses enable row level security;
alter table public.financial_records enable row level security;
alter table public.orders enable row level security;
alter table public.notifications enable row level security;
alter table public.community_posts enable row level security;
alter table public.community_comments enable row level security;
alter table public.loan_applications enable row level security;

-- Users can read their own data
create policy "Users can view own profile" on public.users
  for select using (auth.uid() = id);

create policy "Users can update own profile" on public.users
  for update using (auth.uid() = id);

-- Farms policies
create policy "Users can view own farms" on public.farms
  for select using (auth.uid() = user_id);

create policy "Users can insert own farms" on public.farms
  for insert with check (auth.uid() = user_id);

create policy "Users can update own farms" on public.farms
  for update using (auth.uid() = user_id);

create policy "Users can delete own farms" on public.farms
  for delete using (auth.uid() = user_id);

-- Crops policies
create policy "Users can view own crops" on public.crops
  for select using (auth.uid() = user_id);

create policy "Users can insert own crops" on public.crops
  for insert with check (auth.uid() = user_id);

create policy "Users can update own crops" on public.crops
  for update using (auth.uid() = user_id);

create policy "Users can delete own crops" on public.crops
  for delete using (auth.uid() = user_id);

-- Crop diagnoses policies
create policy "Users can view own diagnoses" on public.crop_diagnoses
  for select using (auth.uid() = user_id);

create policy "Users can insert own diagnoses" on public.crop_diagnoses
  for insert with check (auth.uid() = user_id);

-- Financial records policies
create policy "Users can view own financial records" on public.financial_records
  for select using (auth.uid() = user_id);

create policy "Users can insert own financial records" on public.financial_records
  for insert with check (auth.uid() = user_id);

create policy "Users can update own financial records" on public.financial_records
  for update using (auth.uid() = user_id);

create policy "Users can delete own financial records" on public.financial_records
  for delete using (auth.uid() = user_id);

-- Market prices are publicly readable
create policy "Market prices are publicly readable" on public.market_prices
  for select using (true);

-- Orders policies
create policy "Users can view orders where they are buyer or seller" on public.orders
  for select using (auth.uid() = buyer_id or auth.uid() = seller_id);

create policy "Users can insert orders as buyer" on public.orders
  for insert with check (auth.uid() = buyer_id);

create policy "Users can update orders where they are buyer or seller" on public.orders
  for update using (auth.uid() = buyer_id or auth.uid() = seller_id);

-- Notifications policies
create policy "Users can view own notifications" on public.notifications
  for select using (auth.uid() = user_id);

create policy "Users can update own notifications" on public.notifications
  for update using (auth.uid() = user_id);

-- Announcements are publicly readable
create policy "Announcements are publicly readable" on public.announcements
  for select using (is_active = true);

-- Weather data is publicly readable
create policy "Weather data is publicly readable" on public.weather_data
  for select using (true);

-- Learning content is publicly readable
create policy "Learning content is publicly readable" on public.learning_content
  for select using (true);

-- Community posts are publicly readable
create policy "Community posts are publicly readable" on public.community_posts
  for select using (true);

create policy "Users can insert own posts" on public.community_posts
  for insert with check (auth.uid() = user_id);

create policy "Users can update own posts" on public.community_posts
  for update using (auth.uid() = user_id);

create policy "Users can delete own posts" on public.community_posts
  for delete using (auth.uid() = user_id);

-- Community comments are publicly readable
create policy "Community comments are publicly readable" on public.community_comments
  for select using (true);

create policy "Users can insert own comments" on public.community_comments
  for insert with check (auth.uid() = user_id);

create policy "Users can update own comments" on public.community_comments
  for update using (auth.uid() = user_id);

create policy "Users can delete own comments" on public.community_comments
  for delete using (auth.uid() = user_id);

-- Loan applications policies
create policy "Users can view own loan applications" on public.loan_applications
  for select using (auth.uid() = user_id);

create policy "Users can insert own loan applications" on public.loan_applications
  for insert with check (auth.uid() = user_id);

create policy "Users can update own loan applications" on public.loan_applications
  for update using (auth.uid() = user_id);

-- Government schemes are publicly readable
create policy "Government schemes are publicly readable" on public.government_schemes
  for select using (is_active = true);

-- Functions for updated_at timestamps
create or replace function public.handle_updated_at()
returns trigger as $$
begin
  new.updated_at = timezone('utc'::text, now());
  return new;
end;
$$ language plpgsql security definer;

-- Create triggers for updated_at
create trigger users_updated_at before update on public.users
  for each row execute procedure public.handle_updated_at();

create trigger farms_updated_at before update on public.farms
  for each row execute procedure public.handle_updated_at();

create trigger crops_updated_at before update on public.crops
  for each row execute procedure public.handle_updated_at();

create trigger financial_records_updated_at before update on public.financial_records
  for each row execute procedure public.handle_updated_at();

create trigger orders_updated_at before update on public.orders
  for each row execute procedure public.handle_updated_at();

create trigger announcements_updated_at before update on public.announcements
  for each row execute procedure public.handle_updated_at();

create trigger learning_content_updated_at before update on public.learning_content
  for each row execute procedure public.handle_updated_at();

create trigger community_posts_updated_at before update on public.community_posts
  for each row execute procedure public.handle_updated_at();

create trigger community_comments_updated_at before update on public.community_comments
  for each row execute procedure public.handle_updated_at();

create trigger loan_applications_updated_at before update on public.loan_applications
  for each row execute procedure public.handle_updated_at();

create trigger government_schemes_updated_at before update on public.government_schemes
  for each row execute procedure public.handle_updated_at();

-- Sample data for testing (optional)
-- Insert some sample market prices
insert into public.market_prices (commodity, market_name, location, price, unit, date, source) values
  ('Rice', 'Mandya APMC', 'Mandya, Karnataka', 2800, 'quintal', current_date, 'APMC'),
  ('Wheat', 'Mandya APMC', 'Mandya, Karnataka', 2200, 'quintal', current_date, 'APMC'),
  ('Cotton', 'Raichur APMC', 'Raichur, Karnataka', 6500, 'quintal', current_date, 'APMC'),
  ('Sugarcane', 'Belgaum APMC', 'Belgaum, Karnataka', 3200, 'ton', current_date, 'APMC'),
  ('Tomato', 'KR Market', 'Bangalore, Karnataka', 45, 'kg', current_date, 'Market Survey'),
  ('Onion', 'KR Market', 'Bangalore, Karnataka', 35, 'kg', current_date, 'Market Survey'),
  ('Potato', 'KR Market', 'Bangalore, Karnataka', 28, 'kg', current_date, 'Market Survey')
on conflict do nothing;

-- Insert sample government schemes
insert into public.government_schemes (name, description, eligibility_criteria, benefits, application_process, required_documents, state, is_active) values
  (
    'PM-KISAN Scheme',
    'Direct income support to farmers providing ₹6000 per year in three equal installments',
    '{"landholding": "up to 2 hectares", "citizenship": "Indian", "age": "18+"}',
    '{"amount": "₹6000 per year", "installments": "3 equal payments", "direct_transfer": true}',
    '{"step1": "Register online", "step2": "Submit documents", "step3": "Verification", "step4": "Approval"}',
    '["Aadhaar Card", "Land Records", "Bank Account Details", "Mobile Number"]',
    'All States',
    true
  ),
  (
    'Crop Insurance Scheme',
    'Comprehensive risk cover for crops against natural calamities, pests and diseases',
    '{"farmer_type": "all categories", "land_ownership": "owned or leased"}',
    '{"coverage": "comprehensive", "premium_subsidy": "up to 90%", "claim_settlement": "quick"}',
    '{"step1": "Apply through bank", "step2": "Pay premium", "step3": "Crop cutting experiment", "step4": "Claim settlement"}',
    '["Land Records", "Sowing Certificate", "Bank Account", "Aadhaar Card"]',
    'Karnataka',
    true
  )
on conflict do nothing;

-- Insert sample learning content
insert into public.learning_content (title, content, type, category, tags, difficulty_level, estimated_duration, is_featured) values
  (
    'Organic Farming Basics',
    'Learn the fundamentals of organic farming, soil preparation, and natural pest control methods.',
    'article',
    'crop_management',
    '["organic", "sustainable", "soil health"]',
    'beginner',
    30,
    true
  ),
  (
    'Integrated Pest Management',
    'Comprehensive guide to managing pests using biological, cultural, and chemical methods.',
    'article',
    'pest_control',
    '["IPM", "pest control", "sustainable"]',
    'intermediate',
    45,
    true
  ),
  (
    'Water-Saving Irrigation Techniques',
    'Modern irrigation methods including drip irrigation, sprinkler systems, and water management.',
    'video',
    'irrigation',
    '["irrigation", "water saving", "efficiency"]',
    'intermediate',
    60,
    false
  )
on conflict do nothing;
