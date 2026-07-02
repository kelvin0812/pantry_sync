-- Enable Realtime for IoT data streaming
-- This allows the Flutter app to receive live updates
-- when the IoT device writes new sensor data

ALTER PUBLICATION supabase_realtime ADD TABLE inventory;
ALTER PUBLICATION supabase_realtime ADD TABLE fridge_status;

-- ═══════════════════════════════════════════════════════════
-- ROW LEVEL SECURITY (RLS)
-- For production: restrict access per user/device
-- ═══════════════════════════════════════════════════════════

ALTER TABLE inventory ENABLE ROW LEVEL SECURITY;
ALTER TABLE fridge_status ENABLE ROW LEVEL SECURITY;

-- Allow authenticated users to read all inventory
CREATE POLICY "Allow read access to inventory"
  ON inventory FOR SELECT
  USING (true);

-- Allow authenticated users to insert/update/delete
CREATE POLICY "Allow write access to inventory"
  ON inventory FOR ALL
  USING (true)
  WITH CHECK (true);

-- Allow read access to fridge status
CREATE POLICY "Allow read access to fridge_status"
  ON fridge_status FOR SELECT
  USING (true);

-- Allow update to fridge status (IoT device + app settings)
CREATE POLICY "Allow update fridge_status"
  ON fridge_status FOR UPDATE
  USING (true)
  WITH CHECK (true);
