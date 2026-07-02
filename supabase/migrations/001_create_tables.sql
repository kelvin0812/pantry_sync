-- Pantry Sync - Supabase Database Schema
-- Run this in your Supabase SQL Editor (Dashboard > SQL Editor)

-- ═══════════════════════════════════════════════════════════
-- TABLE: inventory
-- Stores food items detected by the fridge camera
-- IoT device INSERTs rows on each door-close scan
-- ═══════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS inventory (
  id BIGSERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  category TEXT NOT NULL DEFAULT 'Other',
  quantity DOUBLE PRECISION NOT NULL DEFAULT 100.0,
  protein DOUBLE PRECISION NOT NULL DEFAULT 0.0,
  carbs DOUBLE PRECISION NOT NULL DEFAULT 0.0,
  fat DOUBLE PRECISION NOT NULL DEFAULT 0.0,
  calories DOUBLE PRECISION NOT NULL DEFAULT 0.0,
  detected_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  image_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ═══════════════════════════════════════════════════════════
-- TABLE: fridge_status
-- Real-time sensor data from IoT fridge hardware
-- Single row updated continuously by ESP32/Raspberry Pi
-- ═══════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS fridge_status (
  id INTEGER PRIMARY KEY DEFAULT 1,
  fridge_temperature DOUBLE PRECISION DEFAULT 4.0,
  freezer_temperature DOUBLE PRECISION DEFAULT -18.0,
  humidity DOUBLE PRECISION DEFAULT 45.0,
  energy_usage_watts DOUBLE PRECISION DEFAULT 65.0,
  daily_energy_kwh DOUBLE PRECISION DEFAULT 1.2,
  door_open BOOLEAN DEFAULT FALSE,
  energy_save_mode BOOLEAN DEFAULT FALSE,
  compressor_speed INTEGER DEFAULT 50,
  last_updated TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT single_row CHECK (id = 1)
);

-- Insert default fridge status row
INSERT INTO fridge_status (id) VALUES (1)
ON CONFLICT (id) DO NOTHING;
