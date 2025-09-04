-- KRUSHAK COMPLETE DATABASE SCHEMA
-- Real-time Farming Application with AI Integration
-- Created: September 4, 2025

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";

-- ============================================
-- 1. USERS AND AUTHENTICATION
-- ============================================

-- Users profile table (extends Supabase auth.users)
CREATE TABLE public.users (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  full_name TEXT NOT NULL,
  phone TEXT,
  date_of_birth DATE,
  gender TEXT CHECK (gender IN ('male', 'female', 'other')),
  profile_image_url TEXT,
  
  -- Farmer specific information
  farm_location TEXT,
  total_acres DECIMAL(10,2) DEFAULT 0,
  farming_experience_years INTEGER DEFAULT 0,
  primary_crop TEXT,
  farming_type TEXT CHECK (farming_type IN ('organic', 'conventional', 'mixed')),
  
  -- Location data
  latitude DECIMAL(10,8),
  longitude DECIMAL(11,8),
  address TEXT,
  city TEXT,
  state TEXT,
  pincode TEXT,
  
  -- App preferences
  language TEXT DEFAULT 'english' CHECK (language IN ('english', 'hindi', 'marathi')),
  theme_mode TEXT DEFAULT 'light' CHECK (theme_mode IN ('light', 'dark', 'system')),
  notification_enabled BOOLEAN DEFAULT true,
  
  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- 2. FARM MANAGEMENT
-- ============================================

-- Farms table
CREATE TABLE public.farms (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  location TEXT,
  total_area DECIMAL(10,2),
  area_unit TEXT DEFAULT 'acres' CHECK (area_unit IN ('acres', 'hectares', 'square_meters')),
  soil_type TEXT,
  irrigation_type TEXT,
  latitude DECIMAL(10,8),
  longitude DECIMAL(11,8),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Crops table
CREATE TABLE public.crops (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  farm_id UUID REFERENCES public.farms(id) ON DELETE CASCADE,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  variety TEXT,
  planted_date DATE,
  expected_harvest_date DATE,
  actual_harvest_date DATE,
  area_planted DECIMAL(10,2),
  status TEXT DEFAULT 'growing' CHECK (status IN ('growing', 'harvested', 'failed', 'sold')),
  yield_expected DECIMAL(10,2),
  yield_actual DECIMAL(10,2),
  yield_unit TEXT DEFAULT 'quintal',
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- 3. WEATHER DATA & MONITORING
-- ============================================

-- Weather data table
CREATE TABLE public.weather_data (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id),
  location TEXT NOT NULL,
  latitude DECIMAL(10,8),
  longitude DECIMAL(11,8),
  
  -- Current weather
  temperature DECIMAL(5,2),
  feels_like DECIMAL(5,2),
  humidity INTEGER,
  pressure DECIMAL(7,2),
  wind_speed DECIMAL(5,2),
  wind_direction INTEGER,
  visibility DECIMAL(5,2),
  uv_index DECIMAL(3,1),
  
  -- Weather condition
  condition TEXT,
  description TEXT,
  icon TEXT,
  
  -- AI Analysis
  ai_recommendation TEXT,
  farming_advice TEXT,
  
  -- Timestamps
  recorded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Weather forecasts table
CREATE TABLE public.weather_forecasts (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id),
  location TEXT NOT NULL,
  forecast_date DATE,
  min_temp DECIMAL(5,2),
  max_temp DECIMAL(5,2),
  condition TEXT,
  description TEXT,
  precipitation_chance INTEGER,
  humidity INTEGER,
  wind_speed DECIMAL(5,2),
  ai_farming_advice TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- 4. MARKET DATA & PRICES
-- ============================================

-- Market prices table
CREATE TABLE public.market_prices (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  crop_name TEXT NOT NULL,
  variety TEXT,
  price DECIMAL(10,2) NOT NULL,
  previous_price DECIMAL(10,2),
  unit TEXT DEFAULT 'quintal',
  market_name TEXT,
  state TEXT,
  city TEXT,
  
  -- Price analysis
  change_percentage DECIMAL(5,2),
  trend TEXT CHECK (trend IN ('up', 'down', 'stable')),
  ai_analysis TEXT,
  
  -- Data source
  source TEXT DEFAULT 'api',
  
  -- Timestamps
  price_date DATE DEFAULT CURRENT_DATE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Market analysis table
CREATE TABLE public.market_analysis (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  analysis_type TEXT CHECK (analysis_type IN ('daily', 'weekly', 'monthly')),
  content TEXT NOT NULL,
  trends JSONB,
  recommendations TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User products for selling
CREATE TABLE public.user_products (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  crop_id UUID REFERENCES public.crops(id),
  name TEXT NOT NULL,
  variety TEXT,
  quantity DECIMAL(10,2) NOT NULL,
  unit TEXT DEFAULT 'quintal',
  price_per_unit DECIMAL(10,2) NOT NULL,
  total_price DECIMAL(10,2) GENERATED ALWAYS AS (quantity * price_per_unit) STORED,
  description TEXT,
  quality_grade TEXT,
  harvest_date DATE,
  images JSONB DEFAULT '[]',
  status TEXT DEFAULT 'available' CHECK (status IN ('available', 'sold', 'reserved', 'expired')),
  location TEXT,
  contact_info JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- 5. COMMUNITY & MESSAGING
-- ============================================

-- Chat rooms table
CREATE TABLE public.chat_rooms (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  type TEXT DEFAULT 'general' CHECK (type IN ('general', 'crop_specific', 'regional', 'weather_alert')),
  crop_focus TEXT,
  region TEXT,
  is_active BOOLEAN DEFAULT true,
  member_count INTEGER DEFAULT 0,
  created_by UUID REFERENCES public.users(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Chat messages table
CREATE TABLE public.chat_messages (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  room_id UUID REFERENCES public.chat_rooms(id) ON DELETE CASCADE,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  message_type TEXT DEFAULT 'text' CHECK (message_type IN ('text', 'image', 'voice', 'location', 'weather', 'price_alert')),
  reply_to UUID REFERENCES public.chat_messages(id),
  attachments JSONB DEFAULT '[]',
  is_ai_generated BOOLEAN DEFAULT false,
  ai_context TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Room members table
CREATE TABLE public.room_members (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  room_id UUID REFERENCES public.chat_rooms(id) ON DELETE CASCADE,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  role TEXT DEFAULT 'member' CHECK (role IN ('member', 'moderator', 'admin')),
  joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  last_read_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(room_id, user_id)
);

-- ============================================
-- 6. NOTIFICATIONS SYSTEM
-- ============================================

-- Notifications table
CREATE TABLE public.notifications (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  type TEXT CHECK (type IN ('weather_alert', 'price_update', 'crop_advice', 'community', 'system', 'ai_insight')),
  priority TEXT DEFAULT 'normal' CHECK (priority IN ('low', 'normal', 'high', 'urgent')),
  data JSONB DEFAULT '{}',
  read BOOLEAN DEFAULT false,
  action_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- 7. AI INSIGHTS & ANALYSIS
-- ============================================

-- AI insights table
CREATE TABLE public.ai_insights (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id),
  insight_type TEXT CHECK (insight_type IN ('crop_health', 'weather_forecast', 'market_prediction', 'farming_tip', 'disease_alert')),
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  confidence_score DECIMAL(3,2) CHECK (confidence_score >= 0 AND confidence_score <= 1),
  related_crop TEXT,
  data_sources JSONB DEFAULT '[]',
  actionable_items JSONB DEFAULT '[]',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- 8. LEARNING & COURSES
-- ============================================

-- Learning courses table
CREATE TABLE public.learning_courses (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  category TEXT CHECK (category IN ('crop_management', 'weather', 'market', 'technology', 'sustainable_farming')),
  difficulty_level TEXT CHECK (difficulty_level IN ('beginner', 'intermediate', 'advanced')),
  duration_minutes INTEGER,
  video_url TEXT,
  youtube_video_id TEXT,
  content_text TEXT,
  thumbnail_url TEXT,
  language TEXT DEFAULT 'english',
  tags JSONB DEFAULT '[]',
  is_active BOOLEAN DEFAULT true,
  view_count INTEGER DEFAULT 0,
  rating DECIMAL(2,1) DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User course progress
CREATE TABLE public.user_course_progress (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  course_id UUID REFERENCES public.learning_courses(id) ON DELETE CASCADE,
  progress_percentage INTEGER DEFAULT 0 CHECK (progress_percentage >= 0 AND progress_percentage <= 100),
  completed BOOLEAN DEFAULT false,
  last_watched_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, course_id)
);

-- ============================================
-- 9. FINANCIAL & LOAN MANAGEMENT
-- ============================================

-- Financial records table
CREATE TABLE public.financial_records (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  type TEXT CHECK (type IN ('income', 'expense', 'loan', 'subsidy', 'insurance')),
  category TEXT,
  amount DECIMAL(10,2) NOT NULL,
  description TEXT,
  date DATE DEFAULT CURRENT_DATE,
  crop_id UUID REFERENCES public.crops(id),
  payment_method TEXT,
  receipt_url TEXT,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Loan schemes table
CREATE TABLE public.loan_schemes (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  bank_name TEXT,
  loan_type TEXT CHECK (loan_type IN ('crop_loan', 'equipment_loan', 'land_loan', 'personal_loan')),
  min_amount DECIMAL(10,2),
  max_amount DECIMAL(10,2),
  interest_rate DECIMAL(5,2),
  tenure_months INTEGER,
  eligibility_criteria TEXT,
  required_documents JSONB DEFAULT '[]',
  application_process TEXT,
  contact_info JSONB,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User loan applications
CREATE TABLE public.loan_applications (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  loan_scheme_id UUID REFERENCES public.loan_schemes(id),
  amount_requested DECIMAL(10,2) NOT NULL,
  purpose TEXT,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected', 'processing')),
  application_data JSONB DEFAULT '{}',
  documents JSONB DEFAULT '[]',
  bank_reference TEXT,
  notes TEXT,
  applied_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  processed_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- 10. ANNOUNCEMENTS & GOVERNMENT SCHEMES
-- ============================================

-- Announcements table
CREATE TABLE public.announcements (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  type TEXT CHECK (type IN ('government_scheme', 'weather_alert', 'market_update', 'technology_update', 'general')),
  priority INTEGER DEFAULT 1 CHECK (priority >= 1 AND priority <= 5),
  target_audience TEXT,
  region TEXT,
  valid_from DATE DEFAULT CURRENT_DATE,
  valid_until DATE,
  active BOOLEAN DEFAULT true,
  image_url TEXT,
  document_url TEXT,
  created_by TEXT DEFAULT 'system',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- INDEXES FOR PERFORMANCE
-- ============================================

-- User indexes
CREATE INDEX idx_users_location ON public.users(latitude, longitude);
CREATE INDEX idx_users_city_state ON public.users(city, state);

-- Weather indexes
CREATE INDEX idx_weather_data_location_date ON public.weather_data(latitude, longitude, recorded_at DESC);
CREATE INDEX idx_weather_forecasts_date ON public.weather_forecasts(forecast_date DESC);

-- Market indexes
CREATE INDEX idx_market_prices_crop_date ON public.market_prices(crop_name, price_date DESC);
CREATE INDEX idx_market_prices_trend ON public.market_prices(trend, updated_at DESC);

-- Chat indexes
CREATE INDEX idx_chat_messages_room_created ON public.chat_messages(room_id, created_at DESC);
CREATE INDEX idx_chat_messages_user ON public.chat_messages(user_id, created_at DESC);

-- Notification indexes
CREATE INDEX idx_notifications_user_unread ON public.notifications(user_id, read, created_at DESC);

-- ============================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================

-- Enable RLS
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.farms ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.crops ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.weather_data ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.weather_forecasts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.room_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ai_insights ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_course_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.financial_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.loan_applications ENABLE ROW LEVEL SECURITY;

-- Users policies
CREATE POLICY "Users can view own profile" ON public.users FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON public.users FOR UPDATE USING (auth.uid() = id);

-- Farms policies
CREATE POLICY "Users can manage own farms" ON public.farms FOR ALL USING (auth.uid() = user_id);

-- Crops policies
CREATE POLICY "Users can manage own crops" ON public.crops FOR ALL USING (auth.uid() = user_id);

-- Weather policies
CREATE POLICY "Users can view weather data" ON public.weather_data FOR SELECT USING (auth.uid() = user_id OR user_id IS NULL);
CREATE POLICY "Users can view weather forecasts" ON public.weather_forecasts FOR SELECT USING (auth.uid() = user_id OR user_id IS NULL);

-- User products policies
CREATE POLICY "Users can manage own products" ON public.user_products FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Anyone can view available products" ON public.user_products FOR SELECT USING (status = 'available');

-- Chat policies
CREATE POLICY "Users can view messages in joined rooms" ON public.chat_messages FOR SELECT USING (
  room_id IN (SELECT room_id FROM public.room_members WHERE user_id = auth.uid())
);
CREATE POLICY "Users can send messages to joined rooms" ON public.chat_messages FOR INSERT WITH CHECK (
  auth.uid() = user_id AND room_id IN (SELECT room_id FROM public.room_members WHERE user_id = auth.uid())
);

-- Room members policies
CREATE POLICY "Users can view room memberships" ON public.room_members FOR SELECT USING (auth.uid() = user_id);

-- Notifications policies
CREATE POLICY "Users can view own notifications" ON public.notifications FOR ALL USING (auth.uid() = user_id);

-- AI insights policies
CREATE POLICY "Users can view own insights" ON public.ai_insights FOR SELECT USING (auth.uid() = user_id OR user_id IS NULL);

-- Course progress policies
CREATE POLICY "Users can manage own course progress" ON public.user_course_progress FOR ALL USING (auth.uid() = user_id);

-- Financial records policies
CREATE POLICY "Users can manage own financial records" ON public.financial_records FOR ALL USING (auth.uid() = user_id);

-- Loan applications policies
CREATE POLICY "Users can manage own loan applications" ON public.loan_applications FOR ALL USING (auth.uid() = user_id);

-- ============================================
-- REAL-TIME SUBSCRIPTIONS
-- ============================================

-- Enable real-time for tables that need live updates
ALTER PUBLICATION supabase_realtime ADD TABLE public.chat_messages;
ALTER PUBLICATION supabase_realtime ADD TABLE public.chat_rooms;
ALTER PUBLICATION supabase_realtime ADD TABLE public.notifications;
ALTER PUBLICATION supabase_realtime ADD TABLE public.weather_data;
ALTER PUBLICATION supabase_realtime ADD TABLE public.market_prices;
ALTER PUBLICATION supabase_realtime ADD TABLE public.ai_insights;
ALTER PUBLICATION supabase_realtime ADD TABLE public.user_products;

-- ============================================
-- FUNCTIONS AND TRIGGERS
-- ============================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers for updated_at
CREATE TRIGGER trigger_users_updated_at BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
CREATE TRIGGER trigger_farms_updated_at BEFORE UPDATE ON public.farms FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
CREATE TRIGGER trigger_crops_updated_at BEFORE UPDATE ON public.crops FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
CREATE TRIGGER trigger_market_prices_updated_at BEFORE UPDATE ON public.market_prices FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
CREATE TRIGGER trigger_user_products_updated_at BEFORE UPDATE ON public.user_products FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
CREATE TRIGGER trigger_chat_rooms_updated_at BEFORE UPDATE ON public.chat_rooms FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
CREATE TRIGGER trigger_learning_courses_updated_at BEFORE UPDATE ON public.learning_courses FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
CREATE TRIGGER trigger_financial_records_updated_at BEFORE UPDATE ON public.financial_records FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
CREATE TRIGGER trigger_loan_schemes_updated_at BEFORE UPDATE ON public.loan_schemes FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
CREATE TRIGGER trigger_loan_applications_updated_at BEFORE UPDATE ON public.loan_applications FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
CREATE TRIGGER trigger_announcements_updated_at BEFORE UPDATE ON public.announcements FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- Function to update room member count
CREATE OR REPLACE FUNCTION public.update_room_member_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE public.chat_rooms SET member_count = member_count + 1 WHERE id = NEW.room_id;
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE public.chat_rooms SET member_count = member_count - 1 WHERE id = OLD.room_id;
    RETURN OLD;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for room member count
CREATE TRIGGER trigger_update_room_member_count
  AFTER INSERT OR DELETE ON public.room_members
  FOR EACH ROW EXECUTE FUNCTION public.update_room_member_count();

-- ============================================
-- SAMPLE DATA INSERTION
-- ============================================

-- Insert sample learning courses
INSERT INTO public.learning_courses (title, description, category, difficulty_level, duration_minutes, language, tags) VALUES
('Organic Farming Basics', 'Learn the fundamentals of organic farming practices', 'sustainable_farming', 'beginner', 45, 'english', '["organic", "sustainable", "basics"]'),
('Weather Pattern Analysis', 'Understanding weather patterns for better crop planning', 'weather', 'intermediate', 60, 'english', '["weather", "planning", "analysis"]'),
('Market Price Analysis', 'How to analyze market trends and prices', 'market', 'intermediate', 40, 'english', '["market", "prices", "analysis"]'),
('Crop Disease Management', 'Identifying and managing common crop diseases', 'crop_management', 'advanced', 75, 'english', '["disease", "management", "crops"]'),
('Modern Farming Technology', 'Introduction to modern farming tools and techniques', 'technology', 'beginner', 50, 'english', '["technology", "modern", "tools"]');

-- Insert sample loan schemes
INSERT INTO public.loan_schemes (name, description, bank_name, loan_type, min_amount, max_amount, interest_rate, tenure_months, eligibility_criteria) VALUES
('Kisan Credit Card', 'Short term credit for crop production and farming activities', 'Various Banks', 'crop_loan', 50000, 300000, 7.5, 12, 'Must be a farmer with land documents'),
('PM-KISAN Equipment Loan', 'Loan for purchasing farming equipment and machinery', 'SBI', 'equipment_loan', 100000, 1000000, 8.5, 60, 'Farmer with minimum 2 acres land'),
('Agriculture Term Loan', 'Long term loan for land purchase and development', 'HDFC Bank', 'land_loan', 500000, 5000000, 9.5, 120, 'Farmers and agricultural entrepreneurs');

-- Insert sample announcements
INSERT INTO public.announcements (title, content, type, priority, region, valid_until) VALUES
('New Government Subsidy Scheme', 'Government announces new subsidy scheme for organic farming. Apply before 31st December.', 'government_scheme', 5, 'All India', '2025-12-31'),
('Weather Alert: Heavy Rainfall Expected', 'Heavy rainfall expected in Northern states. Farmers advised to take precautionary measures.', 'weather_alert', 4, 'North India', '2025-09-10'),
('Market Update: Cotton Prices Rise', 'Cotton prices have increased by 15% in major markets. Good time for cotton farmers to sell.', 'market_update', 3, 'All India', '2025-09-15');

-- ============================================
-- FUNCTIONS FOR API INTEGRATION
-- ============================================

-- Function to get market prices with AI analysis
CREATE OR REPLACE FUNCTION public.get_market_prices_with_analysis(crop_filter TEXT DEFAULT NULL)
RETURNS TABLE (
  id UUID,
  crop_name TEXT,
  price DECIMAL(10,2),
  trend TEXT,
  ai_analysis TEXT,
  updated_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    mp.id,
    mp.crop_name,
    mp.price,
    mp.trend,
    mp.ai_analysis,
    mp.updated_at
  FROM public.market_prices mp
  WHERE (crop_filter IS NULL OR mp.crop_name ILIKE '%' || crop_filter || '%')
  ORDER BY mp.updated_at DESC
  LIMIT 50;
END;
$$ LANGUAGE plpgsql;

-- Function to get user dashboard data
CREATE OR REPLACE FUNCTION public.get_user_dashboard_data(user_uuid UUID)
RETURNS JSON AS $$
DECLARE
  result JSON;
BEGIN
  SELECT json_build_object(
    'user_info', (
      SELECT json_build_object(
        'full_name', full_name,
        'total_acres', total_acres,
        'primary_crop', primary_crop,
        'city', city,
        'state', state
      )
      FROM public.users WHERE id = user_uuid
    ),
    'farm_summary', (
      SELECT json_build_object(
        'total_farms', COUNT(*),
        'total_area', SUM(total_area)
      )
      FROM public.farms WHERE user_id = user_uuid
    ),
    'crop_summary', (
      SELECT json_build_object(
        'total_crops', COUNT(*),
        'growing_crops', COUNT(*) FILTER (WHERE status = 'growing'),
        'ready_to_harvest', COUNT(*) FILTER (WHERE expected_harvest_date <= CURRENT_DATE + INTERVAL '7 days')
      )
      FROM public.crops WHERE user_id = user_uuid
    ),
    'recent_weather', (
      SELECT json_build_object(
        'temperature', temperature,
        'condition', condition,
        'humidity', humidity,
        'ai_recommendation', ai_recommendation
      )
      FROM public.weather_data 
      WHERE user_id = user_uuid 
      ORDER BY recorded_at DESC 
      LIMIT 1
    ),
    'unread_notifications', (
      SELECT COUNT(*) FROM public.notifications WHERE user_id = user_uuid AND read = false
    )
  ) INTO result;
  
  RETURN result;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- DATABASE SCHEMA COMPLETE
-- ============================================

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT ALL ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO authenticated;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO authenticated;

-- Create indexes for better performance
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_users_created_at ON public.users(created_at DESC);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_market_prices_created_at ON public.market_prices(created_at DESC);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_notifications_created_at ON public.notifications(created_at DESC);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_chat_messages_created_at ON public.chat_messages(created_at DESC);

-- Enable JSONB GIN indexes for better performance
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_user_products_images_gin ON public.user_products USING GIN (images);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_learning_courses_tags_gin ON public.learning_courses USING GIN (tags);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_announcements_gin ON public.announcements USING GIN (to_tsvector('english', title || ' ' || content));

COMMENT ON DATABASE postgres IS 'Krushak - Complete Real-time Farming Application Database with AI Integration';
