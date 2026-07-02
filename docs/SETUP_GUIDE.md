# Pantry Sync — Complete Setup Guide
## ESP32 + Supabase + Flutter Connection Instructions

---

## Table of Contents

1. [System Overview](#1-system-overview)
2. [Hardware Required](#2-hardware-required)
3. [Wiring Diagram](#3-wiring-diagram)
4. [Supabase Setup](#4-supabase-setup)
5. [ESP32 Arduino IDE Setup](#5-esp32-arduino-ide-setup)
6. [Flash ESP32 Code](#6-flash-esp32-code)
7. [Flutter App Setup](#7-flutter-app-setup)
8. [Testing the Connection](#8-testing-the-connection)
9. [Troubleshooting](#9-troubleshooting)

---

## 1. System Overview

### Architecture
```
ESP32-CAM (Inside Fridge)
    │
    │ WiFi (HTTP REST API)
    ▼
SUPABASE (Cloud)
    │
    │ Realtime WebSocket
    ▼
FLUTTER APP (User's Phone)
```

### Data Flow
1. ESP32 reads sensors every 30 seconds → writes to Supabase `fridge_status` table
2. ESP32 detects door close → captures photo → saves to SD card → uploads to Supabase Storage
3. Supabase Realtime pushes changes to Flutter app instantly
4. User sees live temperature, door status, and food inventory on their phone

### Why This Approach is Best
- **No separate server needed** — Supabase handles database + realtime + file storage
- **32GB SD card** as local buffer — photos saved locally first, uploaded in background
- **Reliable** — if WiFi drops, data stored on SD and uploaded later
- **Free tier** — Supabase free plan is enough (500MB database, 1GB storage)

---

## 2. Hardware Required

| # | Component | Model | Purpose | Est. Cost |
|---|-----------|-------|---------|-----------|
| 1 | ESP32-CAM | AI-Thinker | Camera + WiFi + Processor | RM 35 |
| 2 | MicroSD Card | 32GB (your existing) | Local photo backup + buffer | — |
| 3 | DHT22 Sensor | AM2302 | Temperature + Humidity inside fridge | RM 12 |
| 4 | Reed Switch + Magnet | Generic | Door open/close detection | RM 5 |
| 5 | FTDI Programmer | FT232RL or CP2102 | For uploading code to ESP32-CAM | RM 10 |
| 6 | 10kΩ Resistor | 1/4W | Pull-up for DHT22 data pin | RM 0.50 |
| 7 | Jumper Wires | Male-Female | Connections | RM 5 |
| 8 | 5V 2A Power Supply | Micro USB or bare wire | Power the ESP32 inside fridge | RM 10 |
| 9 | Waterproof Enclosure | Small plastic box | Protect ESP32 from moisture | RM 8 |

**Total estimated: ~RM 85**

---

## 3. Wiring Diagram

```
                    ┌─────────────────────────────────┐
                    │         ESP32-CAM               │
                    │         (AI-Thinker)            │
                    │                                 │
                    │   [Camera Module on top]        │
                    │                                 │
  DHT22 Data ──────┤── GPIO 13                       │
                    │                                 │
  Reed Switch ─────┤── GPIO 12          GPIO 4 ──────┤── (Flash LED, built-in)
                    │                                 │
  DHT22 VCC ───────┤── 3.3V                          │
  DHT22 GND ───────┤── GND                           │
  Reed GND ────────┤── GND                           │
                    │                                 │
                    │   [MicroSD slot on bottom]      │
                    └─────────────────────────────────┘


DHT22 Wiring Detail:
┌───────────┐
│   DHT22   │
│  ┌─┬─┬─┐ │
│  │1│2│3│4│ │    Pin 1 (VCC) → ESP32 3.3V
│  └─┴─┴─┴─┘ │    Pin 2 (Data) → ESP32 GPIO 13 + 10kΩ to 3.3V
└───────────┘      Pin 3 (NC) → Not connected
                   Pin 4 (GND) → ESP32 GND


Reed Switch Wiring:
┌──────────────┐
│ Reed Switch  │──── One leg → ESP32 GPIO 12 (has internal pull-up)
│              │──── Other leg → ESP32 GND
└──────────────┘
[Magnet on fridge door, switch on fridge frame]
When door closed: magnet near switch → circuit closed → GPIO 12 reads LOW
When door open: magnet away → circuit open → GPIO 12 reads HIGH
```

---

## 4. Supabase Setup

### Step 4.1: Create Project (Already Done ✓)
Your project: `https://qixngbxvkwfopvryvpkk.supabase.co`

### Step 4.2: Create Tables (Already Done ✓)
Tables `inventory` and `fridge_status` already created.

### Step 4.3: Create Storage Bucket for Images

1. Go to **Supabase Dashboard** → **Storage** (left sidebar)
2. Click **"New bucket"**
3. Name: `food-images`
4. Toggle **"Public bucket"** → ON
5. Click **"Create bucket"**

### Step 4.4: Set Storage Policies

Go to **SQL Editor** and run:
```sql
-- Allow anyone to view food images
CREATE POLICY "Public read food images"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'food-images');

-- Allow ESP32 to upload images
CREATE POLICY "Allow upload food images"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'food-images');

-- Allow deleting old images
CREATE POLICY "Allow delete food images"
  ON storage.objects FOR DELETE
  USING (bucket_id = 'food-images');
```

### Step 4.5: Enable Realtime (Already Done ✓)
Tables are already added to realtime publication.

### Step 4.6: Verify Your Credentials
```
Project URL: https://qixngbxvkwfopvryvpkk.supabase.co
Anon Key:    eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
             (full key in lib/config/supabase_config.dart)
```

---

## 5. ESP32 Arduino IDE Setup

### Step 5.1: Install Arduino IDE
- Download from: https://www.arduino.cc/en/software
- Install version 2.x (latest)

### Step 5.2: Add ESP32 Board Support
1. Open Arduino IDE
2. Go to **File → Preferences**
3. In "Additional Board Manager URLs", add:
```
https://dl.espressif.com/dl/package_esp32_index.json
```
4. Click OK
5. Go to **Tools → Board → Board Manager**
6. Search "esp32"
7. Install **"esp32 by Espressif Systems"** (version 2.x or 3.x)

### Step 5.3: Install Required Libraries
Go to **Sketch → Include Library → Manage Libraries** and install:

| Library | Author | Version |
|---------|--------|---------|
| ArduinoJson | Benoit Blanchon | 7.x |
| DHT sensor library | Adafruit | 1.4.x |
| Adafruit Unified Sensor | Adafruit | 1.1.x |

### Step 5.4: Select Board Settings
- **Tools → Board:** "AI Thinker ESP32-CAM"
- **Tools → Partition Scheme:** "Huge APP (3MB No OTA / 1MB SPIFFS)"
- **Tools → Flash Frequency:** "80MHz"
- **Tools → Upload Speed:** "115200"

---

## 6. Flash ESP32 Code

### Step 6.1: Connect FTDI Programmer to ESP32-CAM

```
FTDI Programmer          ESP32-CAM
─────────────            ─────────
GND          ──────────  GND
VCC (5V)     ──────────  5V
TX           ──────────  U0R (GPIO 3)
RX           ──────────  U0T (GPIO 1)
                         
                         GPIO 0 ──── GND  (FOR UPLOAD MODE ONLY!)
```

**IMPORTANT:** Connect GPIO 0 to GND only during upload. Remove after flashing!

### Step 6.2: Update WiFi Credentials
Open `iot/esp32_fridge/esp32_fridge.ino` and change:
```cpp
const char* WIFI_SSID = "YOUR_WIFI_NAME";      // ← Your WiFi name
const char* WIFI_PASSWORD = "YOUR_WIFI_PASS";   // ← Your WiFi password
```

### Step 6.3: Upload
1. Connect FTDI to computer via USB
2. Connect GPIO 0 to GND on ESP32-CAM
3. Press RST button on ESP32-CAM
4. In Arduino IDE: **Tools → Port** → select your COM port
5. Click **Upload** (→ arrow button)
6. Wait for "Done uploading"
7. **Disconnect GPIO 0 from GND**
8. Press RST button again

### Step 6.4: Verify
1. Open **Tools → Serial Monitor**
2. Set baud rate to **115200**
3. Press RST on ESP32-CAM
4. You should see:
```
=== Pantry Sync ESP32 Starting ===
Connecting to WiFi....
✓ WiFi connected!
  IP: 192.168.x.x
✓ Camera initialized
=== Setup Complete ===
```

---

## 7. Flutter App Setup

### Step 7.1: Install Flutter
- Download from: https://flutter.dev/docs/get-started/install
- Ensure `flutter doctor` shows no critical issues

### Step 7.2: Get Dependencies
```bash
cd pantry_sync
flutter pub get
```

### Step 7.3: Run on Device
```bash
flutter run
```
Or in Android Studio / VS Code: press F5

### Step 7.4: Verify Connection
- Open the app → Dashboard should show live fridge status
- If Supabase is connected: data comes from database
- If not configured: falls back to mock data

---

## 8. Testing the Connection

### Test 1: Sensor Data Flow
1. Power on ESP32 inside fridge
2. Wait 30 seconds
3. Check Supabase Dashboard → **Table Editor → fridge_status**
4. You should see temperature/humidity values updating
5. Open Flutter app → Dashboard should show the same values

### Test 2: Door Sensor
1. Open fridge door (separate magnet from reed switch)
2. Check Supabase: `door_open` should change to `true`
3. Flutter app should show "Door is Open" with yellow warning
4. Close door → `door_open` changes to `false`
5. App shows "Door is Closed — Everything is secure ✓"

### Test 3: Camera + Image Upload
1. Close the fridge door
2. ESP32 Serial Monitor should show:
```
🚪 Door CLOSED — capturing image...
✓ Image captured: 45231 bytes
✓ Image uploaded to Supabase Storage
```
3. Check Supabase → **Storage → food-images → scans/**
4. You should see the uploaded JPEG file

### Test 4: Full End-to-End
1. Open fridge door → app shows door open
2. Close door → ESP32 captures + uploads image
3. Image appears in Supabase Storage
4. (Future) Gemini Vision processes image → inventory updates
5. App inventory tab shows detected food items

---

## 9. Troubleshooting

| Problem | Solution |
|---------|----------|
| ESP32 won't connect to WiFi | Make sure it's 2.4GHz (not 5GHz). Check SSID/password. |
| "Camera init failed" | Use 5V 2A power supply. ESP32-CAM needs strong power. |
| Upload to Supabase fails (HTTP 401) | Check anon key is correct and complete. |
| Upload to Supabase fails (HTTP 404) | Make sure `food-images` bucket exists in Storage. |
| DHT22 returns NaN | Check wiring. Add 10kΩ pull-up resistor between Data and 3.3V. |
| Flutter app stuck loading | Check Supabase URL/key in `lib/config/supabase_config.dart`. |
| Reed switch not detecting | Test with multimeter. Ensure magnet is close enough (<1cm). |
| Photos blurry | Clean ESP32-CAM lens. Use flash LED (GPIO 4). |
| SD card not detected | Format as FAT32. Insert before powering on. |
| Supabase Realtime not working | Ensure tables added to publication (migration 002). |

---

## Quick Reference Card

### Supabase API Endpoints (for ESP32)
```
Base URL: https://qixngbxvkwfopvryvpkk.supabase.co

Update fridge status:
  PATCH /rest/v1/fridge_status?id=eq.1
  Headers: apikey: <KEY>, Authorization: Bearer <KEY>
  Body: {"fridge_temperature": 4.0, "door_open": false, ...}

Upload image:
  POST /storage/v1/object/food-images/scans/filename.jpg
  Headers: Authorization: Bearer <KEY>, Content-Type: image/jpeg
  Body: <raw image bytes>

Insert inventory item:
  POST /rest/v1/inventory
  Headers: apikey: <KEY>, Authorization: Bearer <KEY>
  Body: {"name": "Eggs", "category": "Protein", "quantity": 360, ...}
```

### Pin Reference
```
GPIO 13 → DHT22 Data
GPIO 12 → Reed Switch
GPIO 4  → Flash LED (built-in)
GPIO 0  → GND during upload only
SD Card → Built-in slot (uses GPIO 2, 14, 15, 13)
```

**Note:** GPIO 13 is shared with SD card. If using SD, move DHT22 to GPIO 2 or 14.

---

## What's Next?

After basic connection works:
1. **Add Gemini Vision** — ESP32 uploads image → Supabase Edge Function calls Gemini → food items written to inventory table
2. **Add expiry detection** — Track when items were first detected, alert before they expire
3. **Energy monitoring** — Add CT clamp sensor for real energy measurement
4. **Multiple users** — Add Supabase Auth for family sharing

---

*Document generated for Pantry Sync project*
*GitHub: https://github.com/kelvin0812/pantry_sync*
