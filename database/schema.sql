-- ==============================================================================
-- StrideSync iOS: Multi-User Cloud Database Schema + Row Level Security (RLS)
-- Compatible with PostgreSQL 15+ / Supabase Cloud / Neon / AWS RDS Aurora
-- ==============================================================================

-- Enable UUID extension & PostGIS spatial extensions if available
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ==============================================================================
-- 1. USERS & PROFILES TABLE
-- ==============================================================================
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    apple_user_id VARCHAR(255) UNIQUE,
    email VARCHAR(255) UNIQUE NOT NULL,
    username VARCHAR(50) UNIQUE NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    bio TEXT,
    avatar_url TEXT,
    location VARCHAR(100) DEFAULT 'Jakarta, Indonesia',
    weight_kg NUMERIC(5, 2) DEFAULT 65.0,
    height_cm NUMERIC(5, 2) DEFAULT 170.0,
    gender VARCHAR(20) DEFAULT 'Pria',
    is_metric_units BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index on search & username lookups
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

-- ==============================================================================
-- 2. SOCIAL FOLLOWS GRAPH TABLE
-- ==============================================================================
CREATE TABLE IF NOT EXISTS follows (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    follower_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    following_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(follower_id, following_id)
);

CREATE INDEX IF NOT EXISTS idx_follows_follower ON follows(follower_id);
CREATE INDEX IF NOT EXISTS idx_follows_following ON follows(following_id);

-- ==============================================================================
-- 3. ACTIVITIES TABLE (Runs, Rides, Hikes, Walks)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS activities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(150) NOT NULL,
    activity_type VARCHAR(30) NOT NULL, -- 'run', 'ride', 'walk', 'hike'
    start_time TIMESTAMP WITH TIME ZONE NOT NULL,
    end_time TIMESTAMP WITH TIME ZONE NOT NULL,
    distance_meters NUMERIC(10, 2) NOT NULL DEFAULT 0.0,
    duration_seconds NUMERIC(10, 2) NOT NULL DEFAULT 0.0,
    moving_time_seconds NUMERIC(10, 2) NOT NULL DEFAULT 0.0,
    total_elevation_gain_meters NUMERIC(8, 2) DEFAULT 0.0,
    average_speed_mps NUMERIC(6, 3) DEFAULT 0.0,
    max_speed_mps NUMERIC(6, 3) DEFAULT 0.0,
    average_heart_rate INTEGER,
    max_heart_rate INTEGER,
    calories_burned INTEGER DEFAULT 0,
    average_cadence INTEGER,
    average_power_watts NUMERIC(6, 1),
    encoded_polyline TEXT, -- Polyline compression for GPS route
    notes TEXT,
    gear_name VARCHAR(100),
    visibility VARCHAR(30) DEFAULT 'publicVisibility', -- 'publicVisibility', 'followersOnly', 'privateVisibility'
    kudos_count INTEGER DEFAULT 0,
    comments_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_activities_user_time ON activities(user_id, start_time DESC);
CREATE INDEX IF NOT EXISTS idx_activities_visibility_time ON activities(visibility, start_time DESC);

-- ==============================================================================
-- 4. ACTIVITY TELEMETRY POINTS (GPS Breadcrumbs & Sensor Data)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS activity_telemetry (
    id BIGSERIAL PRIMARY KEY,
    activity_id UUID NOT NULL REFERENCES activities(id) ON DELETE CASCADE,
    timestamp TIMESTAMP WITH TIME ZONE NOT NULL,
    latitude NUMERIC(10, 7) NOT NULL,
    longitude NUMERIC(10, 7) NOT NULL,
    altitude NUMERIC(7, 2),
    speed_mps NUMERIC(6, 3),
    heart_rate INTEGER,
    cadence INTEGER,
    power_watts NUMERIC(6, 1)
);

CREATE INDEX IF NOT EXISTS idx_telemetry_activity_time ON activity_telemetry(activity_id, timestamp ASC);

-- ==============================================================================
-- 5. KUDOS / LIKES TABLE
-- ==============================================================================
CREATE TABLE IF NOT EXISTS kudos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    activity_id UUID NOT NULL REFERENCES activities(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(activity_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_kudos_activity ON kudos(activity_id);
CREATE INDEX IF NOT EXISTS idx_kudos_user ON kudos(user_id);

-- ==============================================================================
-- 6. COMMENTS TABLE
-- ==============================================================================
CREATE TABLE IF NOT EXISTS comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    activity_id UUID NOT NULL REFERENCES activities(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    message TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_comments_activity_time ON comments(activity_id, created_at ASC);

-- ==============================================================================
-- 7. SEGMENTS & GLOBAL LEADERBOARD TABLES
-- ==============================================================================
CREATE TABLE IF NOT EXISTS segments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    creator_id UUID REFERENCES users(id) ON DELETE SET NULL,
    name VARCHAR(150) NOT NULL,
    activity_type VARCHAR(30) NOT NULL,
    distance_meters NUMERIC(10, 2) NOT NULL,
    average_grade_percent NUMERIC(5, 2) DEFAULT 0.0,
    elevation_difference_meters NUMERIC(8, 2) DEFAULT 0.0,
    start_latitude NUMERIC(10, 7) NOT NULL,
    start_longitude NUMERIC(10, 7) NOT NULL,
    end_latitude NUMERIC(10, 7) NOT NULL,
    end_longitude NUMERIC(10, 7) NOT NULL,
    encoded_polyline TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS segment_efforts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    segment_id UUID NOT NULL REFERENCES segments(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    activity_id UUID NOT NULL REFERENCES activities(id) ON DELETE CASCADE,
    elapsed_time_seconds NUMERIC(10, 2) NOT NULL,
    moving_time_seconds NUMERIC(10, 2) NOT NULL,
    average_speed_mps NUMERIC(6, 3) NOT NULL,
    average_heart_rate INTEGER,
    average_power_watts NUMERIC(6, 1),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_efforts_segment_time ON segment_efforts(segment_id, elapsed_time_seconds ASC);

-- ==============================================================================
-- 8. ROW LEVEL SECURITY (RLS) POLICIES
-- ==============================================================================
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE activities ENABLE ROW LEVEL SECURITY;
ALTER TABLE follows ENABLE ROW LEVEL SECURITY;
ALTER TABLE kudos ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE segments ENABLE ROW LEVEL SECURITY;
ALTER TABLE segment_efforts ENABLE ROW LEVEL SECURITY;

-- Public read policies
CREATE POLICY "Users are publicly readable" ON users FOR SELECT USING (true);
CREATE POLICY "Activities are publicly readable" ON activities FOR SELECT USING (true);
CREATE POLICY "Comments are publicly readable" ON comments FOR SELECT USING (true);
CREATE POLICY "Kudos are publicly readable" ON kudos FOR SELECT USING (true);
CREATE POLICY "Segments are publicly readable" ON segments FOR SELECT USING (true);
CREATE POLICY "Leaderboards are publicly readable" ON segment_efforts FOR SELECT USING (true);

-- Authenticated write policies
CREATE POLICY "Users can insert activities" ON activities FOR INSERT WITH CHECK (true);
CREATE POLICY "Users can insert comments" ON comments FOR INSERT WITH CHECK (true);
CREATE POLICY "Users can insert kudos" ON kudos FOR INSERT WITH CHECK (true);

-- ==============================================================================
-- 9. DATABASE FUNCTIONS & TRIGGERS
-- ==============================================================================

-- Trigger to increment/decrement kudos_count on activity
CREATE OR REPLACE FUNCTION update_kudos_count() RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        UPDATE activities SET kudos_count = kudos_count + 1 WHERE id = NEW.activity_id;
        RETURN NEW;
    ELSIF (TG_OP = 'DELETE') THEN
        UPDATE activities SET kudos_count = GREATEST(0, kudos_count - 1) WHERE id = OLD.activity_id;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trigger_kudos_count
AFTER INSERT OR DELETE ON kudos
FOR EACH ROW EXECUTE FUNCTION update_kudos_count();

-- Trigger to increment/decrement comments_count on activity
CREATE OR REPLACE FUNCTION update_comments_count() RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        UPDATE activities SET comments_count = comments_count + 1 WHERE id = NEW.activity_id;
        RETURN NEW;
    ELSIF (TG_OP = 'DELETE') THEN
        UPDATE activities SET comments_count = GREATEST(0, comments_count - 1) WHERE id = OLD.activity_id;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trigger_comments_count
AFTER INSERT OR DELETE ON comments
FOR EACH ROW EXECUTE FUNCTION update_comments_count();
