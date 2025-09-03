-- Krushak FarmerOS Supabase Database Schema
-- Complete SQL Schema for the Farmer Operating System
-- Created: September 2025

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";

-- ============================================
-- CORE USER & IDENTITY TABLES
-- ============================================

-- Farmer Profiles (extends Supabase auth.users)
CREATE TABLE profiles (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    full_name TEXT NOT NULL,
    phone_number TEXT UNIQUE,
    address TEXT,
    state TEXT,
    district TEXT,
    village TEXT,
    pin_code TEXT,
    profile_picture_url TEXT,
    is_kyc_verified BOOLEAN DEFAULT FALSE,
    primary_language TEXT DEFAULT 'en',
    date_of_birth DATE,
    gender TEXT CHECK (gender IN ('male', 'female', 'other')),
    farmer_id TEXT UNIQUE, -- Government farmer ID if available
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User Settings
CREATE TABLE user_settings (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    profile_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    quick_action_preferences JSONB DEFAULT '[]',
    notification_preferences JSONB DEFAULT '{"push": true, "email": true, "sms": false}',
    privacy_consents JSONB DEFAULT '{"data_sharing": false, "analytics": true}',
    app_language TEXT DEFAULT 'en',
    theme_preference TEXT DEFAULT 'light' CHECK (theme_preference IN ('light', 'dark', 'auto')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- KYC Documents
CREATE TABLE kyc_documents (
    document_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    profile_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    document_type TEXT NOT NULL CHECK (document_type IN ('aadhaar', 'pancard', 'land_deed', 'ration_card', 'bank_passbook', 'voter_id')),
    file_url TEXT NOT NULL,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'verified', 'rejected')),
    submission_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    verified_by_admin_id UUID REFERENCES profiles(id),
    verification_date TIMESTAMP WITH TIME ZONE,
    rejection_reason TEXT,
    metadata JSONB -- Additional document info like expiry date, document number etc.
);

-- MRV (Measurement, Reporting, Verification) Credentials
CREATE TABLE mr_credentials (
    credential_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    profile_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    type TEXT NOT NULL CHECK (type IN ('organic_certified', 'water_efficient', 'low_carbon_footprint', 'soil_health_improvement', 'biodiversity_conservation')),
    title TEXT NOT NULL,
    description TEXT,
    details TEXT,
    issue_date DATE NOT NULL,
    expiry_date DATE,
    verifier_name TEXT NOT NULL,
    verifier_details TEXT,
    blockchain_hash TEXT, -- Placeholder for blockchain verification
    certificate_url TEXT, -- Link to certificate document
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'expired', 'revoked')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- FARM & AGRICULTURE TABLES
-- ============================================

-- Crops Master Data
CREATE TABLE crops (
    crop_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name_en TEXT NOT NULL,
    name_local JSONB DEFAULT '{}', -- Multilingual names
    category TEXT NOT NULL CHECK (category IN ('cereal', 'pulse', 'oilseed', 'vegetable', 'fruit', 'cash_crop', 'spice', 'other')),
    scientific_name TEXT,
    characteristics TEXT,
    common_diseases JSONB DEFAULT '[]',
    suitable_soil_types JSONB DEFAULT '[]',
    water_requirements TEXT,
    growth_duration_days INTEGER,
    ideal_temperature_range JSONB, -- {"min": 20, "max": 35}
    harvest_season TEXT,
    market_demand_level TEXT CHECK (market_demand_level IN ('low', 'medium', 'high')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Farms
CREATE TABLE farms (
    farm_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    profile_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    location_geojson JSONB, -- GeoJSON point for farm location
    address TEXT,
    total_area_acres NUMERIC(10,2),
    soil_type TEXT CHECK (soil_type IN ('clay', 'sandy', 'loam', 'silt', 'black_cotton', 'red', 'alluvial')),
    irrigation_type TEXT CHECK (irrigation_type IN ('rainfed', 'drip', 'sprinkler', 'flood', 'mixed')),
    primary_crop_id UUID REFERENCES crops(crop_id),
    farm_registration_number TEXT,
    ownership_type TEXT CHECK (ownership_type IN ('owned', 'leased', 'sharecropping')),
    is_organic_certified BOOLEAN DEFAULT FALSE,
    last_irrigation_date DATE,
    iot_sensor_id TEXT, -- Reference to IoT sensor if connected
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Farm Diagnoses (AI-powered analysis)
CREATE TABLE farm_diagnoses (
    diagnosis_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    profile_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    farm_id UUID REFERENCES farms(farm_id),
    image_url TEXT, -- Supabase storage URL
    analysis_type TEXT NOT NULL CHECK (analysis_type IN ('crop_health', 'soil_analysis', 'pest_detection', 'disease_detection')),
    detected_issues JSONB DEFAULT '[]', -- Array of detected problems
    recommendations JSONB DEFAULT '[]', -- Array of recommended actions
    confidence_score NUMERIC(3,2), -- AI confidence level (0.00 to 1.00)
    crop_id UUID REFERENCES crops(crop_id),
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'complete', 'failed')),
    ai_model_version TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE
);

-- ============================================
-- CLIMATE & SUSTAINABILITY TABLES
-- ============================================

-- Sustainable Practices
CREATE TABLE sustainable_practices (
    practice_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    profile_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    farm_id UUID REFERENCES farms(farm_id),
    practice_type TEXT NOT NULL CHECK (practice_type IN ('reduced_tillage', 'organic_inputs', 'water_conservation', 'crop_rotation', 'agroforestry', 'composting', 'integrated_pest_management', 'cover_cropping')),
    title TEXT NOT NULL,
    description TEXT,
    start_date DATE NOT NULL,
    end_date DATE,
    area_covered_acres NUMERIC(10,2),
    proof_image_urls JSONB DEFAULT '[]', -- Array of image URLs
    verification_status TEXT DEFAULT 'pending' CHECK (verification_status IN ('pending', 'verified', 'rejected')),
    verified_by_admin_id UUID REFERENCES profiles(id),
    verification_date TIMESTAMP WITH TIME ZONE,
    carbon_credits_generated NUMERIC(10,2) DEFAULT 0,
    environmental_impact_score INTEGER DEFAULT 0, -- 1-100 scale
    cost_saved_inr NUMERIC(10,2) DEFAULT 0,
    yield_improvement_percentage NUMERIC(5,2) DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Carbon Credits
CREATE TABLE carbon_credits (
    credit_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    profile_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    practice_id UUID REFERENCES sustainable_practices(practice_id),
    amount NUMERIC(10,2) NOT NULL, -- Number of carbon credits
    status TEXT DEFAULT 'available' CHECK (status IN ('available', 'listed', 'sold', 'retired')),
    listed_price_per_unit NUMERIC(10,2),
    listing_date TIMESTAMP WITH TIME ZONE,
    expiry_date DATE,
    verification_standard TEXT, -- e.g., 'VCS', 'Gold Standard'
    project_type TEXT,
    vintage_year INTEGER, -- Year the emission reduction occurred
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Carbon Credit Transactions
CREATE TABLE credit_transactions (
    transaction_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    seller_id UUID REFERENCES profiles(id),
    buyer_id UUID REFERENCES profiles(id),
    carbon_credit_id UUID REFERENCES carbon_credits(credit_id),
    amount NUMERIC(10,2) NOT NULL,
    agreed_price_per_unit NUMERIC(10,2) NOT NULL,
    total_transaction_value NUMERIC(12,2) NOT NULL,
    transaction_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'cancelled', 'disputed')),
    payment_method TEXT,
    transaction_hash TEXT, -- Blockchain transaction reference
    platform_fee_percentage NUMERIC(5,2) DEFAULT 2.5,
    platform_fee_amount NUMERIC(10,2)
);

-- ============================================
-- WEATHER & IRRIGATION TABLES
-- ============================================

-- Weather Forecasts
CREATE TABLE weather_forecasts (
    forecast_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    farm_id UUID REFERENCES farms(farm_id),
    forecast_date DATE NOT NULL,
    daily_data JSONB NOT NULL, -- Complete daily weather data
    hourly_data JSONB, -- Hourly breakdown if available
    source TEXT DEFAULT 'openweather', -- API source
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(farm_id, forecast_date)
);

-- Irrigation Recommendations
CREATE TABLE irrigation_recommendations (
    recommendation_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    farm_id UUID REFERENCES farms(farm_id),
    crop_id UUID REFERENCES crops(crop_id),
    advice_text TEXT NOT NULL,
    recommended_date DATE NOT NULL,
    duration_hours NUMERIC(4,2),
    water_amount_liters NUMERIC(10,2),
    priority_level TEXT CHECK (priority_level IN ('low', 'medium', 'high', 'critical')),
    confidence_score NUMERIC(3,2), -- AI confidence in recommendation
    weather_factor JSONB, -- Weather conditions influencing recommendation
    soil_moisture_level NUMERIC(5,2), -- If available from sensors
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'logged', 'ignored', 'completed')),
    farmer_feedback TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE
);

-- IoT Sensor Data
CREATE TABLE iot_sensor_data (
    data_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    sensor_id TEXT NOT NULL,
    farm_id UUID REFERENCES farms(farm_id),
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    moisture_level NUMERIC(5,2), -- Percentage
    temperature NUMERIC(5,2), -- Celsius
    ph_level NUMERIC(4,2),
    humidity NUMERIC(5,2), -- Percentage
    light_intensity NUMERIC(8,2), -- Lux
    nitrogen_level NUMERIC(8,2), -- ppm
    phosphorus_level NUMERIC(8,2), -- ppm
    potassium_level NUMERIC(8,2), -- ppm
    battery_level NUMERIC(5,2), -- Sensor battery percentage
    signal_strength INTEGER -- dBm
);

-- System Alerts
CREATE TABLE system_alerts (
    alert_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    profile_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    farm_id UUID REFERENCES farms(farm_id),
    type TEXT NOT NULL CHECK (type IN ('drought', 'flood', 'frost', 'pest_outbreak', 'disease_outbreak', 'market_price_drop', 'market_price_spike', 'weather_extreme', 'irrigation_needed')),
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    severity TEXT NOT NULL CHECK (severity IN ('info', 'warning', 'critical', 'emergency')),
    action_required BOOLEAN DEFAULT FALSE,
    action_url TEXT, -- Deep link to relevant screen
    is_read BOOLEAN DEFAULT FALSE,
    expires_at TIMESTAMP WITH TIME ZONE,
    metadata JSONB, -- Additional alert-specific data
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- MARKET & TRADE TABLES
-- ============================================

-- Produce Listings
CREATE TABLE produce_listings (
    listing_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    profile_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    farm_id UUID REFERENCES farms(farm_id),
    crop_id UUID REFERENCES crops(crop_id),
    title TEXT NOT NULL,
    description TEXT,
    quantity_kg NUMERIC(10,2) NOT NULL,
    expected_price_per_kg NUMERIC(8,2) NOT NULL,
    harvest_date DATE,
    expiry_date DATE,
    quality_grade TEXT CHECK (quality_grade IN ('premium', 'grade_a', 'grade_b', 'grade_c')),
    organic_certified BOOLEAN DEFAULT FALSE,
    listing_photos JSONB DEFAULT '[]', -- Array of image URLs
    location_geojson JSONB, -- Pickup location
    pickup_available BOOLEAN DEFAULT TRUE,
    delivery_available BOOLEAN DEFAULT FALSE,
    delivery_radius_km INTEGER DEFAULT 0,
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'sold', 'withdrawn', 'expired')),
    views_count INTEGER DEFAULT 0,
    inquiries_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Market Data Points (Mandi Prices)
CREATE TABLE market_data_points (
    data_point_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    market_name TEXT NOT NULL,
    market_type TEXT CHECK (market_type IN ('apmc', 'private', 'farmer_market', 'online')),
    crop_id UUID REFERENCES crops(crop_id),
    variety TEXT,
    price_per_kg_min NUMERIC(8,2),
    price_per_kg_max NUMERIC(8,2),
    price_per_kg_avg NUMERIC(8,2) NOT NULL,
    quantity_traded_kg NUMERIC(12,2),
    price_date DATE NOT NULL,
    location_geojson JSONB,
    state TEXT,
    district TEXT,
    source TEXT NOT NULL, -- API source or manual entry
    data_quality_score INTEGER DEFAULT 100, -- 1-100 reliability score
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(market_name, crop_id, price_date)
);

-- Trade Inquiries
CREATE TABLE trade_inquiries (
    inquiry_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    listing_id UUID REFERENCES produce_listings(listing_id) ON DELETE CASCADE,
    buyer_profile_id UUID REFERENCES profiles(id),
    quantity_requested_kg NUMERIC(10,2) NOT NULL,
    offered_price_per_kg NUMERIC(8,2) NOT NULL,
    total_offered_amount NUMERIC(12,2) NOT NULL,
    message TEXT,
    preferred_pickup_date DATE,
    payment_terms TEXT,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected', 'negotiating', 'expired')),
    seller_response TEXT,
    inquiry_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    response_date TIMESTAMP WITH TIME ZONE,
    expires_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() + INTERVAL '7 days')
);

-- Trade Contracts
CREATE TABLE trade_contracts (
    contract_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    inquiry_id UUID REFERENCES trade_inquiries(inquiry_id),
    listing_id UUID REFERENCES produce_listings(listing_id),
    buyer_profile_id UUID REFERENCES profiles(id),
    seller_profile_id UUID REFERENCES profiles(id),
    final_quantity_kg NUMERIC(10,2) NOT NULL,
    final_price_per_kg NUMERIC(8,2) NOT NULL,
    total_contract_value NUMERIC(12,2) NOT NULL,
    delivery_date DATE NOT NULL,
    delivery_address TEXT,
    payment_terms TEXT,
    payment_status TEXT DEFAULT 'pending' CHECK (payment_status IN ('pending', 'advance_paid', 'paid', 'failed', 'disputed')),
    contract_status TEXT DEFAULT 'active' CHECK (contract_status IN ('active', 'completed', 'cancelled', 'disputed')),
    quality_check_required BOOLEAN DEFAULT TRUE,
    quality_check_status TEXT CHECK (quality_check_status IN ('pending', 'passed', 'failed')),
    platform_fee_percentage NUMERIC(5,2) DEFAULT 3.0,
    platform_fee_amount NUMERIC(10,2),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE
);

-- ============================================
-- FINANCE & INSURANCE TABLES
-- ============================================

-- Loan Applications
CREATE TABLE loan_applications (
    application_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    profile_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    loan_type TEXT NOT NULL CHECK (loan_type IN ('crop_loan', 'equipment_loan', 'land_improvement', 'working_capital', 'emergency_loan')),
    requested_amount NUMERIC(12,2) NOT NULL,
    purpose TEXT NOT NULL,
    crop_details JSONB, -- If crop loan, details about crops
    collateral_details JSONB,
    annual_income NUMERIC(12,2),
    existing_loans_amount NUMERIC(12,2) DEFAULT 0,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'under_review', 'approved', 'rejected', 'disbursed')),
    eligibility_score NUMERIC(5,2), -- 0-100 calculated score
    risk_assessment JSONB,
    submitted_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    reviewed_by_admin_id UUID REFERENCES profiles(id),
    review_date TIMESTAMP WITH TIME ZONE,
    approval_date TIMESTAMP WITH TIME ZONE,
    rejection_reason TEXT,
    loan_product_id UUID, -- Reference to loan product if applicable
    documents_submitted JSONB DEFAULT '[]',
    verification_status TEXT DEFAULT 'pending' CHECK (verification_status IN ('pending', 'verified', 'rejected'))
);

-- Active Loans
CREATE TABLE loans (
    loan_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    application_id UUID REFERENCES loan_applications(application_id),
    profile_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    provider TEXT NOT NULL, -- Bank/NBFC name
    loan_account_number TEXT UNIQUE,
    principal_amount NUMERIC(12,2) NOT NULL,
    interest_rate NUMERIC(5,2) NOT NULL, -- Annual percentage
    tenure_months INTEGER NOT NULL,
    emi_amount NUMERIC(10,2) NOT NULL,
    outstanding_balance NUMERIC(12,2) NOT NULL,
    next_due_date DATE,
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'overdue', 'closed', 'written_off')),
    disbursement_date DATE NOT NULL,
    maturity_date DATE NOT NULL,
    processing_fee NUMERIC(10,2) DEFAULT 0,
    insurance_premium NUMERIC(10,2) DEFAULT 0,
    guarantor_details JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insurance Policies
CREATE TABLE insurance_policies (
    policy_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    profile_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    farm_id UUID REFERENCES farms(farm_id),
    crop_id UUID REFERENCES crops(crop_id),
    policy_number TEXT UNIQUE NOT NULL,
    provider TEXT NOT NULL, -- Insurance company name
    policy_type TEXT NOT NULL CHECK (policy_type IN ('crop_insurance', 'weather_insurance', 'livestock_insurance', 'equipment_insurance')),
    coverage_amount NUMERIC(12,2) NOT NULL,
    premium_amount NUMERIC(10,2) NOT NULL,
    sum_insured NUMERIC(12,2) NOT NULL,
    policy_start_date DATE NOT NULL,
    policy_end_date DATE NOT NULL,
    coverage_area_acres NUMERIC(10,2),
    weather_triggers JSONB, -- Conditions that trigger parametric claims
    policy_terms TEXT,
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'expired', 'claimed', 'cancelled')),
    renewal_date DATE,
    agent_details JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insurance Claims
CREATE TABLE insurance_claims (
    claim_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    policy_id UUID REFERENCES insurance_policies(policy_id),
    profile_id UUID REFERENCES profiles(id),
    claim_number TEXT UNIQUE NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('parametric_weather', 'manual_crop_loss', 'manual_equipment', 'manual_livestock')),
    cause TEXT NOT NULL, -- Drought, flood, pest attack, etc.
    loss_description TEXT NOT NULL,
    estimated_loss_amount NUMERIC(12,2),
    claim_amount NUMERIC(12,2) NOT NULL,
    trigger_event_details JSONB, -- Weather data or other triggers
    supporting_documents JSONB DEFAULT '[]', -- Array of document URLs
    status TEXT DEFAULT 'submitted' CHECK (status IN ('submitted', 'under_investigation', 'approved', 'rejected', 'settled')),
    claim_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    investigation_date TIMESTAMP WITH TIME ZONE,
    settlement_date TIMESTAMP WITH TIME ZONE,
    settlement_amount NUMERIC(12,2),
    rejection_reason TEXT,
    assessor_details JSONB
);

-- ============================================
-- FPO & COMMUNITY TABLES
-- ============================================

-- Farmer Producer Organizations
CREATE TABLE fpos (
    fpo_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name TEXT NOT NULL,
    registration_number TEXT UNIQUE,
    description TEXT,
    admin_profile_id UUID REFERENCES profiles(id),
    founder_profile_id UUID REFERENCES profiles(id),
    registration_date DATE,
    legal_status TEXT CHECK (legal_status IN ('registered', 'pending', 'dissolved')),
    fpo_type TEXT CHECK (fpo_type IN ('producer_company', 'cooperative', 'self_help_group')),
    primary_activity TEXT,
    region TEXT,
    state TEXT,
    district TEXT,
    headquarter_address TEXT,
    contact_phone TEXT,
    contact_email TEXT,
    website_url TEXT,
    logo_url TEXT,
    total_members INTEGER DEFAULT 0,
    total_land_area_acres NUMERIC(12,2) DEFAULT 0,
    annual_turnover NUMERIC(15,2),
    bank_account_details JSONB,
    certifications JSONB DEFAULT '[]',
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'suspended')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- FPO Memberships
CREATE TABLE fpo_members (
    member_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    fpo_id UUID REFERENCES fpos(fpo_id) ON DELETE CASCADE,
    profile_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    role TEXT DEFAULT 'member' CHECK (role IN ('admin', 'manager', 'member', 'treasurer', 'secretary')),
    membership_number TEXT,
    join_date DATE DEFAULT CURRENT_DATE,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'active', 'suspended', 'terminated')),
    shares_held INTEGER DEFAULT 0,
    share_value NUMERIC(10,2) DEFAULT 0,
    voting_rights BOOLEAN DEFAULT TRUE,
    contribution_amount NUMERIC(10,2) DEFAULT 0,
    invitation_code TEXT,
    invited_by_profile_id UUID REFERENCES profiles(id),
    approval_date DATE,
    termination_date DATE,
    termination_reason TEXT,
    UNIQUE(fpo_id, profile_id)
);

-- FPO Chat Messages
CREATE TABLE fpo_chats (
    message_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    fpo_id UUID REFERENCES fpos(fpo_id) ON DELETE CASCADE,
    sender_profile_id UUID REFERENCES profiles(id),
    message_content TEXT NOT NULL,
    message_type TEXT DEFAULT 'text' CHECK (message_type IN ('text', 'image', 'file', 'voice', 'location')),
    file_url TEXT, -- For image/file/voice messages
    reply_to_message_id UUID REFERENCES fpo_chats(message_id),
    is_announcement BOOLEAN DEFAULT FALSE,
    is_edited BOOLEAN DEFAULT FALSE,
    edited_at TIMESTAMP WITH TIME ZONE,
    is_deleted BOOLEAN DEFAULT FALSE,
    read_by JSONB DEFAULT '[]', -- Array of profile_ids who have read the message
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- FPO Forum Posts
CREATE TABLE fpo_forum_posts (
    post_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    fpo_id UUID REFERENCES fpos(fpo_id) ON DELETE CASCADE,
    author_profile_id UUID REFERENCES profiles(id),
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    post_type TEXT DEFAULT 'discussion' CHECK (post_type IN ('discussion', 'question', 'announcement', 'resource_sharing')),
    tags JSONB DEFAULT '[]',
    attachments JSONB DEFAULT '[]', -- Array of file URLs
    is_pinned BOOLEAN DEFAULT FALSE,
    views_count INTEGER DEFAULT 0,
    likes_count INTEGER DEFAULT 0,
    replies_count INTEGER DEFAULT 0,
    creation_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_edited_date TIMESTAMP WITH TIME ZONE,
    is_locked BOOLEAN DEFAULT FALSE,
    locked_by_profile_id UUID REFERENCES profiles(id),
    locked_reason TEXT
);

-- FPO Forum Comments
CREATE TABLE fpo_forum_comments (
    comment_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    post_id UUID REFERENCES fpo_forum_posts(post_id) ON DELETE CASCADE,
    author_profile_id UUID REFERENCES profiles(id),
    content TEXT NOT NULL,
    parent_comment_id UUID REFERENCES fpo_forum_comments(comment_id), -- For nested replies
    likes_count INTEGER DEFAULT 0,
    is_solution BOOLEAN DEFAULT FALSE, -- Mark as solution for questions
    creation_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_edited_date TIMESTAMP WITH TIME ZONE,
    is_deleted BOOLEAN DEFAULT FALSE
);

-- ============================================
-- LEARNING & GAMIFICATION TABLES
-- ============================================

-- Learning Modules
CREATE TABLE learning_modules (
    module_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    title_en TEXT NOT NULL,
    title_local JSONB DEFAULT '{}', -- Multilingual titles
    description_en TEXT,
    description_local JSONB DEFAULT '{}',
    category TEXT NOT NULL CHECK (category IN ('climate_smart_farming', 'pest_management', 'soil_health', 'water_management', 'crop_varieties', 'post_harvest', 'marketing', 'finance', 'government_schemes', 'technology')),
    sub_category TEXT,
    content_type TEXT NOT NULL CHECK (content_type IN ('video', 'article', 'interactive', 'quiz', 'infographic')),
    content_url TEXT, -- Video URL or external link
    text_content TEXT, -- For articles
    duration_minutes INTEGER,
    difficulty_level TEXT CHECK (difficulty_level IN ('beginner', 'intermediate', 'advanced')),
    thumbnail_url TEXT,
    language_available JSONB DEFAULT '["en"]', -- Array of language codes
    prerequisites JSONB DEFAULT '[]', -- Array of module_ids
    learning_objectives JSONB DEFAULT '[]',
    tags JSONB DEFAULT '[]',
    author_name TEXT,
    author_credentials TEXT,
    points_value INTEGER DEFAULT 10,
    is_premium BOOLEAN DEFAULT FALSE,
    view_count INTEGER DEFAULT 0,
    average_rating NUMERIC(3,2) DEFAULT 0,
    total_ratings INTEGER DEFAULT 0,
    status TEXT DEFAULT 'published' CHECK (status IN ('draft', 'published', 'archived')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User Learning Progress
CREATE TABLE user_learning_progress (
    progress_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    profile_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    module_id UUID REFERENCES learning_modules(module_id) ON DELETE CASCADE,
    status TEXT DEFAULT 'not_started' CHECK (status IN ('not_started', 'in_progress', 'completed', 'bookmarked')),
    progress_percentage INTEGER DEFAULT 0 CHECK (progress_percentage >= 0 AND progress_percentage <= 100),
    time_spent_minutes INTEGER DEFAULT 0,
    last_position_seconds INTEGER DEFAULT 0, -- For video content
    completed_at TIMESTAMP WITH TIME ZONE,
    last_viewed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    points_earned INTEGER DEFAULT 0,
    quiz_score INTEGER, -- If module has quiz
    attempts_count INTEGER DEFAULT 0,
    notes TEXT, -- User's personal notes
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    feedback TEXT,
    UNIQUE(profile_id, module_id)
);

-- Badges & Achievements
CREATE TABLE badges (
    badge_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name_en TEXT NOT NULL,
    name_local JSONB DEFAULT '{}',
    description_en TEXT NOT NULL,
    description_local JSONB DEFAULT '{}',
    icon_url TEXT NOT NULL,
    badge_type TEXT CHECK (badge_type IN ('learning', 'practice', 'community', 'trading', 'sustainability')),
    criteria JSONB NOT NULL, -- Conditions to earn the badge
    points_threshold INTEGER DEFAULT 0,
    modules_required JSONB DEFAULT '[]', -- Required module completions
    practices_required JSONB DEFAULT '[]', -- Required sustainable practices
    rarity TEXT DEFAULT 'common' CHECK (rarity IN ('common', 'rare', 'epic', 'legendary')),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User Badges
CREATE TABLE user_badges (
    user_badge_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    profile_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    badge_id UUID REFERENCES badges(badge_id),
    awarded_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    progress_data JSONB, -- Data showing how badge was earned
    is_displayed BOOLEAN DEFAULT TRUE, -- Whether user chooses to display this badge
    UNIQUE(profile_id, badge_id)
);

-- User Gamification Stats
CREATE TABLE user_gamification_stats (
    stats_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    profile_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    total_points INTEGER DEFAULT 0,
    level INTEGER DEFAULT 1,
    streak_days INTEGER DEFAULT 0, -- Current learning streak
    longest_streak_days INTEGER DEFAULT 0,
    modules_completed INTEGER DEFAULT 0,
    badges_earned INTEGER DEFAULT 0,
    community_contributions INTEGER DEFAULT 0,
    sustainable_practices_logged INTEGER DEFAULT 0,
    carbon_credits_earned NUMERIC(10,2) DEFAULT 0,
    trades_completed INTEGER DEFAULT 0,
    total_earnings NUMERIC(12,2) DEFAULT 0,
    last_activity_date DATE DEFAULT CURRENT_DATE,
    achievements JSONB DEFAULT '{}', -- Various achievement counters
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- NOTIFICATION & COMMUNICATION TABLES
-- ============================================

-- Push Notifications
CREATE TABLE push_notifications (
    notification_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    profile_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('weather_alert', 'price_update', 'trade_inquiry', 'learning_reminder', 'system_update', 'community_message', 'loan_reminder', 'insurance_claim')),
    data JSONB, -- Additional notification data
    action_url TEXT, -- Deep link for notification action
    is_read BOOLEAN DEFAULT FALSE,
    is_sent BOOLEAN DEFAULT FALSE,
    sent_at TIMESTAMP WITH TIME ZONE,
    read_at TIMESTAMP WITH TIME ZONE,
    priority TEXT DEFAULT 'normal' CHECK (priority IN ('low', 'normal', 'high', 'critical')),
    scheduled_for TIMESTAMP WITH TIME ZONE,
    expires_at TIMESTAMP WITH TIME ZONE,
    device_tokens JSONB DEFAULT '[]', -- FCM tokens for push delivery
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- ANALYTICS & REPORTING TABLES
-- ============================================

-- User Activity Logs
CREATE TABLE user_activity_logs (
    log_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    profile_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    activity_type TEXT NOT NULL,
    activity_details JSONB,
    screen_name TEXT,
    session_id TEXT,
    device_info JSONB,
    location_geojson JSONB,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- App Analytics
CREATE TABLE app_analytics (
    analytics_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    event_name TEXT NOT NULL,
    event_data JSONB,
    user_id UUID REFERENCES profiles(id),
    session_id TEXT,
    platform TEXT CHECK (platform IN ('android', 'ios', 'web')),
    app_version TEXT,
    device_model TEXT,
    os_version TEXT,
    country TEXT,
    state TEXT,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- INDEXES FOR PERFORMANCE
-- ============================================

-- Core profile indexes
CREATE INDEX idx_profiles_phone ON profiles(phone_number);
CREATE INDEX idx_profiles_kyc_verified ON profiles(is_kyc_verified);
CREATE INDEX idx_profiles_created_at ON profiles(created_at);

-- Farm and location indexes
CREATE INDEX idx_farms_profile_id ON farms(profile_id);
CREATE INDEX idx_farms_location ON farms USING GIN(location_geojson);
CREATE INDEX idx_farms_primary_crop ON farms(primary_crop_id);

-- Market data indexes
CREATE INDEX idx_market_data_crop_date ON market_data_points(crop_id, price_date DESC);
CREATE INDEX idx_market_data_location ON market_data_points USING GIN(location_geojson);
CREATE INDEX idx_produce_listings_active ON produce_listings(status, created_at DESC) WHERE status = 'active';

-- Time-based indexes
CREATE INDEX idx_system_alerts_profile_unread ON system_alerts(profile_id, created_at DESC) WHERE is_read = FALSE;
CREATE INDEX idx_weather_forecasts_farm_date ON weather_forecasts(farm_id, forecast_date DESC);
CREATE INDEX idx_push_notifications_profile_unread ON push_notifications(profile_id, created_at DESC) WHERE is_read = FALSE;

-- Learning and gamification indexes
CREATE INDEX idx_user_learning_progress_profile ON user_learning_progress(profile_id, last_viewed_at DESC);
CREATE INDEX idx_learning_modules_category ON learning_modules(category, status);

-- FPO and community indexes
CREATE INDEX idx_fpo_members_fpo_status ON fpo_members(fpo_id, status);
CREATE INDEX idx_fpo_chats_fpo_timestamp ON fpo_chats(fpo_id, timestamp DESC);

-- Financial indexes
CREATE INDEX idx_loans_profile_status ON loans(profile_id, status);
CREATE INDEX idx_insurance_policies_profile_active ON insurance_policies(profile_id, status) WHERE status = 'active';

-- ============================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================

-- Enable RLS on all tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE kyc_documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE mr_credentials ENABLE ROW LEVEL SECURITY;
ALTER TABLE farms ENABLE ROW LEVEL SECURITY;
ALTER TABLE farm_diagnoses ENABLE ROW LEVEL SECURITY;
ALTER TABLE sustainable_practices ENABLE ROW LEVEL SECURITY;
ALTER TABLE carbon_credits ENABLE ROW LEVEL SECURITY;
ALTER TABLE credit_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE weather_forecasts ENABLE ROW LEVEL SECURITY;
ALTER TABLE irrigation_recommendations ENABLE ROW LEVEL SECURITY;
ALTER TABLE iot_sensor_data ENABLE ROW LEVEL SECURITY;
ALTER TABLE system_alerts ENABLE ROW LEVEL SECURITY;
ALTER TABLE produce_listings ENABLE ROW LEVEL SECURITY;
ALTER TABLE trade_inquiries ENABLE ROW LEVEL SECURITY;
ALTER TABLE trade_contracts ENABLE ROW LEVEL SECURITY;
ALTER TABLE loan_applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE loans ENABLE ROW LEVEL SECURITY;
ALTER TABLE insurance_policies ENABLE ROW LEVEL SECURITY;
ALTER TABLE insurance_claims ENABLE ROW LEVEL SECURITY;
ALTER TABLE fpos ENABLE ROW LEVEL SECURITY;
ALTER TABLE fpo_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE fpo_chats ENABLE ROW LEVEL SECURITY;
ALTER TABLE fpo_forum_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE fpo_forum_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_learning_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_badges ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_gamification_stats ENABLE ROW LEVEL SECURITY;
ALTER TABLE push_notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_activity_logs ENABLE ROW LEVEL SECURITY;

-- Basic RLS policies for user data access
CREATE POLICY "Users can view own profile" ON profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can view own settings" ON user_settings FOR ALL USING (profile_id = auth.uid());

CREATE POLICY "Users can view own KYC documents" ON kyc_documents FOR SELECT USING (profile_id = auth.uid());
CREATE POLICY "Users can insert own KYC documents" ON kyc_documents FOR INSERT WITH CHECK (profile_id = auth.uid());

CREATE POLICY "Users can view own MRV credentials" ON mr_credentials FOR SELECT USING (profile_id = auth.uid());

CREATE POLICY "Users can manage own farms" ON farms FOR ALL USING (profile_id = auth.uid());

CREATE POLICY "Users can manage own diagnoses" ON farm_diagnoses FOR ALL USING (profile_id = auth.uid());

CREATE POLICY "Users can manage own practices" ON sustainable_practices FOR ALL USING (profile_id = auth.uid());

CREATE POLICY "Users can view own carbon credits" ON carbon_credits FOR SELECT USING (profile_id = auth.uid());
CREATE POLICY "Users can view all active carbon credit listings" ON carbon_credits FOR SELECT USING (status = 'listed');

CREATE POLICY "Users can view own weather data" ON weather_forecasts FOR SELECT USING (
    farm_id IN (SELECT farm_id FROM farms WHERE profile_id = auth.uid())
);

CREATE POLICY "Users can view own irrigation recommendations" ON irrigation_recommendations FOR SELECT USING (
    farm_id IN (SELECT farm_id FROM farms WHERE profile_id = auth.uid())
);

CREATE POLICY "Users can view own alerts" ON system_alerts FOR ALL USING (profile_id = auth.uid());

CREATE POLICY "Users can manage own produce listings" ON produce_listings FOR ALL USING (profile_id = auth.uid());
CREATE POLICY "Anyone can view active produce listings" ON produce_listings FOR SELECT USING (status = 'active');

CREATE POLICY "Users can view inquiries for their listings" ON trade_inquiries FOR SELECT USING (
    listing_id IN (SELECT listing_id FROM produce_listings WHERE profile_id = auth.uid())
    OR buyer_profile_id = auth.uid()
);

CREATE POLICY "Users can view own financial data" ON loan_applications FOR ALL USING (profile_id = auth.uid());
CREATE POLICY "Users can view own loans" ON loans FOR SELECT USING (profile_id = auth.uid());
CREATE POLICY "Users can view own insurance" ON insurance_policies FOR ALL USING (profile_id = auth.uid());

-- FPO access policies
CREATE POLICY "Users can view FPOs they are members of" ON fpos FOR SELECT USING (
    fpo_id IN (SELECT fpo_id FROM fpo_members WHERE profile_id = auth.uid() AND status = 'active')
);

CREATE POLICY "Users can view FPO members if they are members" ON fpo_members FOR SELECT USING (
    fpo_id IN (SELECT fpo_id FROM fpo_members WHERE profile_id = auth.uid() AND status = 'active')
);

CREATE POLICY "Users can view FPO chats if they are members" ON fpo_chats FOR SELECT USING (
    fpo_id IN (SELECT fpo_id FROM fpo_members WHERE profile_id = auth.uid() AND status = 'active')
);
CREATE POLICY "Users can post in FPO chats if they are members" ON fpo_chats FOR INSERT WITH CHECK (
    sender_profile_id = auth.uid() AND
    fpo_id IN (SELECT fpo_id FROM fpo_members WHERE profile_id = auth.uid() AND status = 'active')
);

-- Learning progress policies
CREATE POLICY "Users can manage own learning progress" ON user_learning_progress FOR ALL USING (profile_id = auth.uid());
CREATE POLICY "Users can view own badges" ON user_badges FOR SELECT USING (profile_id = auth.uid());
CREATE POLICY "Users can view own gamification stats" ON user_gamification_stats FOR ALL USING (profile_id = auth.uid());

-- Notification policies
CREATE POLICY "Users can view own notifications" ON push_notifications FOR ALL USING (profile_id = auth.uid());

-- ============================================
-- FUNCTIONS AND TRIGGERS
-- ============================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Add updated_at triggers to relevant tables
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_user_settings_updated_at BEFORE UPDATE ON user_settings FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_farms_updated_at BEFORE UPDATE ON farms FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_produce_listings_updated_at BEFORE UPDATE ON produce_listings FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_fpos_updated_at BEFORE UPDATE ON fpos FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_learning_modules_updated_at BEFORE UPDATE ON learning_modules FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_user_gamification_stats_updated_at BEFORE UPDATE ON user_gamification_stats FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to calculate age from date of birth
CREATE OR REPLACE FUNCTION calculate_age(birth_date DATE)
RETURNS INTEGER AS $$
BEGIN
    RETURN EXTRACT(YEAR FROM AGE(birth_date));
END;
$$ LANGUAGE plpgsql;

-- Function to calculate distance between two points
CREATE OR REPLACE FUNCTION calculate_distance_km(lat1 FLOAT, lon1 FLOAT, lat2 FLOAT, lon2 FLOAT)
RETURNS FLOAT AS $$
BEGIN
    RETURN (
        6371 * acos(
            cos(radians(lat1)) * cos(radians(lat2)) * cos(radians(lon2) - radians(lon1)) +
            sin(radians(lat1)) * sin(radians(lat2))
        )
    );
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- INITIAL SEED DATA
-- ============================================

-- Insert sample crops
INSERT INTO crops (name_en, name_local, category, scientific_name, characteristics, growth_duration_days, harvest_season) VALUES
('Rice', '{"hi": "चावल", "bn": "ধান", "te": "వరి"}', 'cereal', 'Oryza sativa', 'Staple cereal crop requiring flooded fields', 120, 'monsoon'),
('Wheat', '{"hi": "गेहूं", "bn": "গম", "te": "గోధుమ"}', 'cereal', 'Triticum aestivum', 'Winter cereal crop', 180, 'winter'),
('Cotton', '{"hi": "कपास", "bn": "তুলা", "te": "పత్తి"}', 'cash_crop', 'Gossypium', 'Cash crop for textile industry', 180, 'winter'),
('Sugarcane', '{"hi": "गन्ना", "bn": "আখ", "te": "చెరకు"}', 'cash_crop', 'Saccharum officinarum', 'Long duration cash crop', 365, 'winter'),
('Tomato', '{"hi": "टमाटर", "bn": "টমেটো", "te": "టమాట"}', 'vegetable', 'Solanum lycopersicum', 'High value vegetable crop', 90, 'all_season'),
('Onion', '{"hi": "प्याज", "bn": "পেঁয়াজ", "te": "ఉల్లిపాయ"}', 'vegetable', 'Allium cepa', 'Essential vegetable with export potential', 120, 'winter'),
('Chilli', '{"hi": "मिर्च", "bn": "মরিচ", "te": "మిర్చి"}', 'spice', 'Capsicum annuum', 'High value spice crop', 150, 'winter'),
('Turmeric', '{"hi": "हल्दी", "bn": "হলুদ", "te": "పసుపు"}', 'spice', 'Curcuma longa', 'Medicinal and culinary spice', 270, 'winter');

-- Insert sample learning modules
INSERT INTO learning_modules (title_en, title_local, description_en, category, content_type, duration_minutes, difficulty_level, points_value) VALUES
('Climate-Smart Rice Cultivation', '{"hi": "जलवायु-स्मार्ट धान की खेती"}', 'Learn modern techniques for rice farming that adapt to climate change', 'climate_smart_farming', 'video', 45, 'intermediate', 25),
('Integrated Pest Management', '{"hi": "एकीकृत कीट प्रबंधन"}', 'Sustainable methods to control pests without harmful chemicals', 'pest_management', 'interactive', 30, 'beginner', 20),
('Soil Health Assessment', '{"hi": "मिट्टी स्वास्थ्य मूल्यांकन"}', 'Understanding and improving your soil quality', 'soil_health', 'article', 20, 'beginner', 15),
('Water-Efficient Irrigation', '{"hi": "जल-कुशल सिंचाई"}', 'Modern irrigation techniques to save water and increase yield', 'water_management', 'video', 35, 'intermediate', 30),
('Post-Harvest Management', '{"hi": "फसल के बाद प्रबंधन"}', 'Reduce losses and add value to your produce', 'post_harvest', 'interactive', 40, 'advanced', 35);

-- Insert sample badges
INSERT INTO badges (name_en, name_local, description_en, icon_url, badge_type, points_threshold, rarity) VALUES
('Learning Starter', '{"hi": "शिक्षा शुरुआत"}', 'Complete your first learning module', '/badges/learning_starter.png', 'learning', 15, 'common'),
('Knowledge Seeker', '{"hi": "ज्ञान खोजी"}', 'Complete 10 learning modules', '/badges/knowledge_seeker.png', 'learning', 200, 'rare'),
('Sustainability Champion', '{"hi": "स्थिरता चैंपियन"}', 'Log 5 sustainable practices', '/badges/sustainability_champion.png', 'practice', 100, 'epic'),
('Carbon Hero', '{"hi": "कार्बन हीरो"}', 'Earn your first carbon credits', '/badges/carbon_hero.png', 'sustainability', 50, 'rare'),
('Community Leader', '{"hi": "समुदाय नेता"}', 'Help 10 farmers in FPO discussions', '/badges/community_leader.png', 'community', 150, 'epic'),
('Market Master', '{"hi": "बाजार मास्टर"}', 'Complete 5 successful trades', '/badges/market_master.png', 'trading', 100, 'rare');

-- Create default notification settings function
CREATE OR REPLACE FUNCTION create_default_user_settings()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO user_settings (profile_id) VALUES (NEW.id);
    INSERT INTO user_gamification_stats (profile_id) VALUES (NEW.id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to create default settings for new users
CREATE TRIGGER create_user_defaults_trigger
    AFTER INSERT ON profiles
    FOR EACH ROW
    EXECUTE FUNCTION create_default_user_settings();

-- ============================================
-- REALTIME PUBLICATION FOR LIVE FEATURES
-- ============================================

-- Enable realtime for chat and notifications
ALTER PUBLICATION supabase_realtime ADD TABLE fpo_chats;
ALTER PUBLICATION supabase_realtime ADD TABLE push_notifications;
ALTER PUBLICATION supabase_realtime ADD TABLE system_alerts;
ALTER PUBLICATION supabase_realtime ADD TABLE trade_inquiries;
ALTER PUBLICATION supabase_realtime ADD TABLE iot_sensor_data;

-- ============================================
-- STORAGE BUCKETS
-- ============================================

-- Note: These would be created via Supabase Dashboard or Supabase CLI
-- Bucket configurations:
-- 1. profile-pics: Public, 5MB limit, image files only
-- 2. kyc-documents: Private, 10MB limit, PDF/image files
-- 3. practice-proofs: Private, 5MB limit, image files
-- 4. diagnosis-images: Private, 5MB limit, image files
-- 5. produce-photos: Public, 5MB limit, image files
-- 6. learning-content: Public, 100MB limit, video/image files
-- 7. fpo-files: Private per FPO, 20MB limit, document files
-- 8. insurance-documents: Private, 10MB limit, PDF/image files

-- Sample bucket policies (to be created in Supabase Dashboard):
-- INSERT INTO storage.buckets (id, name, public) VALUES 
-- ('profile-pics', 'profile-pics', true),
-- ('kyc-documents', 'kyc-documents', false),
-- ('practice-proofs', 'practice-proofs', false),
-- ('diagnosis-images', 'diagnosis-images', false),
-- ('produce-photos', 'produce-photos', true),
-- ('learning-content', 'learning-content', true),
-- ('fpo-files', 'fpo-files', false),
-- ('insurance-documents', 'insurance-documents', false);

-- ============================================
-- EDGE FUNCTIONS (Pseudo-code references)
-- ============================================

-- These would be implemented as separate TypeScript files in Supabase Edge Functions:
-- 1. ai-diagnosis-handler: Process crop/soil analysis images
-- 2. weather-updater: Fetch and cache weather data
-- 3. irrigation-advisor: Generate irrigation recommendations
-- 4. carbon-credit-calculator: Calculate credits from practices
-- 5. loan-eligibility-scorer: Calculate loan eligibility scores
-- 6. parametric-insurance-trigger: Auto-trigger weather-based claims
-- 7. market-data-updater: Fetch APMC/market prices
-- 8. gemini-voice-handler: Process voice commands via Gemini
-- 9. notification-sender: Handle push notification delivery
-- 10. trade-contract-manager: Manage trade agreements

COMMIT;
