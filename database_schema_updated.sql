-- Krushak App - Complete SQL Schema for Real-time Features
-- This schema supports all real-time features with Supabase integration

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";

-- User profiles with farming details
CREATE TABLE public.users (
    id UUID REFERENCES auth.users(id) PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Basic Information
    full_name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    phone TEXT,
    
    -- Farming Details
    location TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    land_acres DOUBLE PRECISION DEFAULT 0,
    primary_crop TEXT,
    
    -- Preferences
    language VARCHAR(10) DEFAULT 'en',
    theme_mode VARCHAR(10) DEFAULT 'system',
    notifications_enabled BOOLEAN DEFAULT true,
    
    -- Profile Status
    is_verified BOOLEAN DEFAULT false,
    profile_completed BOOLEAN DEFAULT false
);

-- Weather data and AI recommendations
CREATE TABLE public.weather_data (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Location Info
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    location_name TEXT NOT NULL,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    
    -- Weather Data
    temperature DOUBLE PRECISION,
    humidity DOUBLE PRECISION,
    rainfall DOUBLE PRECISION DEFAULT 0,
    wind_speed DOUBLE PRECISION,
    pressure DOUBLE PRECISION,
    weather_condition TEXT,
    weather_description TEXT,
    
    -- AI Analysis
    ai_recommendation TEXT,
    farming_advice TEXT,
    irrigation_advice TEXT,
    pest_warning TEXT,
    
    -- Forecast (5-day)
    forecast_data JSONB,
    
    -- Status
    is_current BOOLEAN DEFAULT true,
    data_source TEXT DEFAULT 'openweather'
);

-- Real-time market prices with AI analysis
CREATE TABLE public.market_prices (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Crop Information
    crop_name TEXT NOT NULL,
    variety TEXT,
    state TEXT,
    district TEXT,
    market_name TEXT,
    
    -- Price Data
    min_price DOUBLE PRECISION,
    max_price DOUBLE PRECISION,
    avg_price DOUBLE PRECISION,
    current_price DOUBLE PRECISION NOT NULL,
    price_unit TEXT DEFAULT 'per quintal',
    
    -- AI Analysis
    ai_analysis TEXT,
    selling_recommendation TEXT,
    price_trend VARCHAR(20), -- 'rising', 'falling', 'stable'
    trend_percentage DOUBLE PRECISION,
    
    -- Predictions
    predicted_price_1week DOUBLE PRECISION,
    predicted_price_1month DOUBLE PRECISION,
    best_selling_time TEXT,
    
    -- Status
    is_current BOOLEAN DEFAULT true,
    data_source TEXT DEFAULT 'agmarknet'
);

-- Notifications system with AI-powered alerts
CREATE TABLE public.notifications (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- User and Type
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    notification_type VARCHAR(50) NOT NULL, -- 'weather', 'market', 'ai_insight', 'community', 'loan'
    category VARCHAR(50), -- 'alert', 'info', 'warning', 'success'
    
    -- Content
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    action_url TEXT,
    action_type VARCHAR(50), -- 'navigate', 'external_link', 'none'
    
    -- AI Generated
    ai_generated BOOLEAN DEFAULT false,
    ai_confidence DOUBLE PRECISION,
    
    -- Status
    is_read BOOLEAN DEFAULT false,
    is_important BOOLEAN DEFAULT false,
    expires_at TIMESTAMP WITH TIME ZONE,
    
    -- Metadata
    data JSONB
);

-- Community chat rooms
CREATE TABLE public.chat_rooms (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Room Details
    name TEXT NOT NULL,
    description TEXT,
    room_type VARCHAR(50) DEFAULT 'public', -- 'public', 'private', 'crop_specific'
    topic VARCHAR(100), -- 'general', 'crops', 'weather', 'market', 'loans'
    
    -- Settings
    max_members INTEGER DEFAULT 1000,
    is_active BOOLEAN DEFAULT true,
    requires_approval BOOLEAN DEFAULT false,
    
    -- Moderation
    created_by UUID REFERENCES public.users(id),
    moderators UUID[] DEFAULT '{}',
    
    -- Stats
    member_count INTEGER DEFAULT 0,
    message_count INTEGER DEFAULT 0,
    last_activity TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Real-time chat messages
CREATE TABLE public.chat_messages (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Message Details
    room_id UUID REFERENCES public.chat_rooms(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    message_type VARCHAR(50) DEFAULT 'text', -- 'text', 'image', 'crop_query', 'market_update'
    
    -- Rich Content
    image_url TEXT,
    crop_name TEXT,
    location TEXT,
    
    -- Thread Support
    reply_to UUID REFERENCES public.chat_messages(id),
    thread_count INTEGER DEFAULT 0,
    
    -- AI Analysis (for crop queries)
    ai_response TEXT,
    ai_confidence DOUBLE PRECISION,
    
    -- Status
    is_edited BOOLEAN DEFAULT false,
    edited_at TIMESTAMP WITH TIME ZONE,
    is_deleted BOOLEAN DEFAULT false,
    
    -- Metadata
    metadata JSONB
);

-- Chat room memberships
CREATE TABLE public.chat_room_members (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    room_id UUID REFERENCES public.chat_rooms(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    
    -- Member Status
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    is_active BOOLEAN DEFAULT true,
    is_muted BOOLEAN DEFAULT false,
    role VARCHAR(20) DEFAULT 'member', -- 'member', 'moderator', 'admin'
    
    -- Activity
    last_read_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    message_count INTEGER DEFAULT 0,
    
    UNIQUE(room_id, user_id)
);

-- Bank loan schemes and applications
CREATE TABLE public.loan_schemes (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Scheme Details
    scheme_name TEXT NOT NULL,
    bank_name TEXT NOT NULL,
    scheme_type VARCHAR(50), -- 'agriculture', 'equipment', 'land_purchase', 'working_capital'
    
    -- Loan Terms
    min_amount DOUBLE PRECISION,
    max_amount DOUBLE PRECISION,
    interest_rate DOUBLE PRECISION,
    loan_tenure_months INTEGER,
    
    -- Eligibility
    min_income DOUBLE PRECISION,
    min_land_acres DOUBLE PRECISION,
    eligible_crops TEXT[],
    age_criteria TEXT,
    
    -- Requirements
    required_documents TEXT[],
    collateral_required BOOLEAN DEFAULT false,
    guarantor_required BOOLEAN DEFAULT false,
    
    -- Application
    application_url TEXT,
    contact_info JSONB,
    
    -- Status
    is_active BOOLEAN DEFAULT true,
    application_deadline DATE
);

-- User loan applications
CREATE TABLE public.loan_applications (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Application Details
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    scheme_id UUID REFERENCES public.loan_schemes(id),
    
    -- Loan Details
    requested_amount DOUBLE PRECISION NOT NULL,
    loan_purpose TEXT,
    
    -- User Financial Info
    annual_income DOUBLE PRECISION,
    existing_loans DOUBLE PRECISION DEFAULT 0,
    credit_score INTEGER,
    
    -- AI Assessment
    ai_eligibility_score DOUBLE PRECISION,
    ai_recommendation TEXT,
    suggested_amount DOUBLE PRECISION,
    
    -- Application Status
    status VARCHAR(50) DEFAULT 'draft', -- 'draft', 'submitted', 'under_review', 'approved', 'rejected'
    bank_reference_number TEXT,
    
    -- Documents
    documents_uploaded JSONB,
    verification_status VARCHAR(50) DEFAULT 'pending',
    
    -- Timeline
    submitted_at TIMESTAMP WITH TIME ZONE,
    processed_at TIMESTAMP WITH TIME ZONE,
    
    -- Bank Response
    bank_response JSONB,
    rejection_reason TEXT
);

-- AI insights and analysis results
CREATE TABLE public.ai_insights (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- User and Context
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    insight_type VARCHAR(50) NOT NULL, -- 'crop_health', 'market_analysis', 'weather_advice', 'financial_planning'
    
    -- Input Data
    input_data JSONB,
    
    -- AI Analysis
    analysis_result TEXT NOT NULL,
    confidence_score DOUBLE PRECISION,
    
    -- Recommendations
    recommendations TEXT[],
    action_items TEXT[],
    
    -- Context
    weather_conditions JSONB,
    market_conditions JSONB,
    seasonal_factors TEXT[],
    
    -- Status
    is_current BOOLEAN DEFAULT true,
    expires_at TIMESTAMP WITH TIME ZONE
);

-- User app usage analytics
CREATE TABLE public.user_analytics (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- User Info
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    
    -- Usage Data
    screen_name TEXT,
    action_type TEXT,
    session_duration INTEGER, -- in seconds
    
    -- Features Used
    features_used TEXT[],
    ai_queries_count INTEGER DEFAULT 0,
    notifications_received INTEGER DEFAULT 0,
    chat_messages_sent INTEGER DEFAULT 0,
    
    -- Performance
    app_version TEXT,
    device_info JSONB,
    
    -- Engagement
    daily_active BOOLEAN DEFAULT true,
    feature_engagement JSONB
);

-- Crop disease diagnosis results
CREATE TABLE public.crop_diagnoses (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- User and Crop Info
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    crop_name TEXT NOT NULL,
    crop_variety TEXT,
    
    -- Image Data
    image_url TEXT NOT NULL,
    image_metadata JSONB,
    
    -- AI Diagnosis
    diagnosed_disease TEXT,
    confidence_score DOUBLE PRECISION,
    severity_level VARCHAR(20), -- 'low', 'medium', 'high', 'critical'
    
    -- Treatment
    treatment_recommendations TEXT[],
    preventive_measures TEXT[],
    recommended_products TEXT[],
    
    -- Follow-up
    follow_up_required BOOLEAN DEFAULT false,
    follow_up_date DATE,
    treatment_effectiveness VARCHAR(20), -- 'effective', 'partial', 'ineffective', 'unknown'
    
    -- Location
    location TEXT,
    weather_conditions JSONB
);

-- Create indexes for performance
CREATE INDEX idx_users_location ON public.users USING GIST (ST_Point(longitude, latitude));
CREATE INDEX idx_weather_data_location ON public.weather_data (latitude, longitude);
CREATE INDEX idx_weather_data_current ON public.weather_data (is_current, created_at DESC);
CREATE INDEX idx_market_prices_crop ON public.market_prices (crop_name, state, is_current);
CREATE INDEX idx_market_prices_current ON public.market_prices (is_current, created_at DESC);
CREATE INDEX idx_notifications_user ON public.notifications (user_id, is_read, created_at DESC);
CREATE INDEX idx_chat_messages_room ON public.chat_messages (room_id, created_at DESC);
CREATE INDEX idx_chat_messages_user ON public.chat_messages (user_id, created_at DESC);
CREATE INDEX idx_loan_applications_user ON public.loan_applications (user_id, status);
CREATE INDEX idx_ai_insights_user ON public.ai_insights (user_id, insight_type, created_at DESC);

-- Enable Row Level Security
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.weather_data ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.market_prices ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_room_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.loan_schemes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.loan_applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ai_insights ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_analytics ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.crop_diagnoses ENABLE ROW LEVEL SECURITY;

-- RLS Policies

-- Users can only see and edit their own data
CREATE POLICY "Users can view own profile" ON public.users FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON public.users FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile" ON public.users FOR INSERT WITH CHECK (auth.uid() = id);

-- Weather data - users can see data for their location
CREATE POLICY "Users can view weather data" ON public.weather_data FOR SELECT USING (true);
CREATE POLICY "Service can insert weather data" ON public.weather_data FOR INSERT WITH CHECK (true);
CREATE POLICY "Service can update weather data" ON public.weather_data FOR UPDATE USING (true);

-- Market prices - public read access
CREATE POLICY "Public read access to market prices" ON public.market_prices FOR SELECT USING (true);
CREATE POLICY "Service can manage market prices" ON public.market_prices FOR ALL USING (true);

-- Notifications - users can see their own notifications
CREATE POLICY "Users can view own notifications" ON public.notifications FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can update own notifications" ON public.notifications FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Service can insert notifications" ON public.notifications FOR INSERT WITH CHECK (true);

-- Chat rooms - public read access for public rooms
CREATE POLICY "Public read access to chat rooms" ON public.chat_rooms FOR SELECT USING (room_type = 'public' OR room_type = 'crop_specific');
CREATE POLICY "Users can create rooms" ON public.chat_rooms FOR INSERT WITH CHECK (auth.uid() = created_by);
CREATE POLICY "Creators can update rooms" ON public.chat_rooms FOR UPDATE USING (auth.uid() = created_by);

-- Chat messages - members can see messages in their rooms
CREATE POLICY "Members can view room messages" ON public.chat_messages 
FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM public.chat_room_members 
        WHERE room_id = chat_messages.room_id 
        AND user_id = auth.uid() 
        AND is_active = true
    )
);
CREATE POLICY "Users can insert messages" ON public.chat_messages FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own messages" ON public.chat_messages FOR UPDATE USING (auth.uid() = user_id);

-- Chat room members
CREATE POLICY "Members can view room membership" ON public.chat_room_members FOR SELECT USING (auth.uid() = user_id OR room_id IN (SELECT id FROM public.chat_rooms WHERE room_type = 'public'));
CREATE POLICY "Users can join rooms" ON public.chat_room_members FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own membership" ON public.chat_room_members FOR UPDATE USING (auth.uid() = user_id);

-- Loan schemes - public read access
CREATE POLICY "Public read access to loan schemes" ON public.loan_schemes FOR SELECT USING (is_active = true);

-- Loan applications - users can see their own applications
CREATE POLICY "Users can view own applications" ON public.loan_applications FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can manage own applications" ON public.loan_applications FOR ALL USING (auth.uid() = user_id);

-- AI insights - users can see their own insights
CREATE POLICY "Users can view own insights" ON public.ai_insights FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Service can insert insights" ON public.ai_insights FOR INSERT WITH CHECK (true);

-- User analytics - users can see their own analytics
CREATE POLICY "Users can view own analytics" ON public.user_analytics FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own analytics" ON public.user_analytics FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Crop diagnoses - users can see their own diagnoses
CREATE POLICY "Users can view own diagnoses" ON public.crop_diagnoses FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can manage own diagnoses" ON public.crop_diagnoses FOR ALL USING (auth.uid() = user_id);

-- Create functions for real-time updates
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers for updated_at
CREATE TRIGGER users_updated_at BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
CREATE TRIGGER weather_data_updated_at BEFORE UPDATE ON public.weather_data FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
CREATE TRIGGER market_prices_updated_at BEFORE UPDATE ON public.market_prices FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
CREATE TRIGGER notifications_updated_at BEFORE UPDATE ON public.notifications FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
CREATE TRIGGER chat_rooms_updated_at BEFORE UPDATE ON public.chat_rooms FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
CREATE TRIGGER chat_messages_updated_at BEFORE UPDATE ON public.chat_messages FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
CREATE TRIGGER loan_schemes_updated_at BEFORE UPDATE ON public.loan_schemes FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
CREATE TRIGGER loan_applications_updated_at BEFORE UPDATE ON public.loan_applications FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- Insert default chat rooms
INSERT INTO public.chat_rooms (name, description, topic) VALUES
('General Discussion', 'General farming discussions and community chat', 'general'),
('Crop Management', 'Discuss crop cultivation, diseases, and best practices', 'crops'),
('Weather Updates', 'Weather discussions and farming advice', 'weather'),
('Market Prices', 'Market trends and selling strategies', 'market'),
('Loan & Finance', 'Bank loans and financial planning discussions', 'loans');

-- Insert sample loan schemes
INSERT INTO public.loan_schemes (scheme_name, bank_name, scheme_type, min_amount, max_amount, interest_rate, loan_tenure_months, is_active) VALUES
('Kisan Credit Card', 'State Bank of India', 'working_capital', 25000, 300000, 7.0, 12, true),
('Agriculture Equipment Loan', 'HDFC Bank', 'equipment', 50000, 2500000, 8.5, 84, true),
('Farm Land Purchase Loan', 'ICICI Bank', 'land_purchase', 100000, 5000000, 9.0, 240, true),
('Crop Cultivation Loan', 'Punjab National Bank', 'agriculture', 10000, 1000000, 7.5, 24, true);

-- Enable real-time subscriptions
ALTER PUBLICATION supabase_realtime ADD TABLE public.chat_messages;
ALTER PUBLICATION supabase_realtime ADD TABLE public.chat_rooms;
ALTER PUBLICATION supabase_realtime ADD TABLE public.chat_room_members;
ALTER PUBLICATION supabase_realtime ADD TABLE public.notifications;
ALTER PUBLICATION supabase_realtime ADD TABLE public.weather_data;
ALTER PUBLICATION supabase_realtime ADD TABLE public.market_prices;
ALTER PUBLICATION supabase_realtime ADD TABLE public.ai_insights;
