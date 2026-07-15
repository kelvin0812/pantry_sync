# Pantry Sync — System Workflow & Working Principle

## Project Overview

Pantry Sync is a smart fridge IoT system that combines hardware sensors (ESP32-CAM), cloud database (Supabase), AI food recognition (Google Gemini Vision), and a mobile app (Flutter) to automate food inventory tracking and recipe suggestions.

**GitHub:** https://github.com/kelvin0812/pantry_sync

---

## 1. System Architecture

```
┌──────────────────────────────────────────────────────────────────────┐
│                         SMART FRIDGE (Hardware)                       │
│                                                                      │
│   ┌───────────────┐   ┌──────────┐   ┌──────────────┐              │
│   │  ESP32-CAM    │   │  DHT22   │   │ Reed Switch  │              │
│   │  (Camera +    │   │  (Temp + │   │ (Door Open/  │              │
│   │   WiFi +      │   │ Humidity)│   │  Close)      │              │
│   │   32GB SD)    │   └────┬─────┘   └──────┬───────┘              │
│   └───────┬───────┘        │                 │                      │
│           │         GPIO 13│          GPIO 12│                      │
│           └────────────────┴─────────────────┘                      │
└───────────────────────────────┬──────────────────────────────────────┘
                                │
                                │ WiFi (HTTP REST API)
                                │
┌───────────────────────────────▼──────────────────────────────────────┐
│                         SUPABASE (Cloud)                              │
│                                                                      │
│   ┌─────────────────┐  ┌─────────────────┐  ┌───────────────────┐  │
│   │  PostgreSQL DB  │  │  Realtime Engine │  │  Storage (1GB)    │  │
│   │                 │  │  (WebSocket)     │  │                   │  │
│   │  • inventory    │  │                  │  │  • food-images/   │  │
│   │  • fridge_status│  │  Pushes changes  │  │  • Bucket:        │  │
│   │                 │  │  to Flutter app  │  │    "Inventory"    │  │
│   └────────┬────────┘  └────────┬─────────┘  └────────┬──────────┘  │
│            │                    │                      │             │
└────────────┼────────────────────┼──────────────────────┼─────────────┘
             │                    │                      │
             │                    │ Realtime             │
             │                    │ WebSocket            │
┌────────────▼────────────────────▼──────────────────────▼─────────────┐
│                      FLUTTER APP (Mobile)                             │
│                                                                      │
│   ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────────┐       │
│   │ Dashboard│  │ My Food  │  │ Chef AI  │  │  Settings    │       │
│   │ (Tab 1)  │  │ (Tab 2)  │  │ (Tab 3)  │  │  (Tab 4)     │       │
│   └──────────┘  └──────────┘  └────┬─────┘  └──────────────┘       │
│                                     │                                │
└─────────────────────────────────────┼────────────────────────────────┘
                                      │
                                      │ HTTPS API
                                      │
┌─────────────────────────────────────▼────────────────────────────────┐
│                      GOOGLE GEMINI AI                                 │
│                                                                      │
│   ┌─────────────────────────┐  ┌────────────────────────────────┐   │
│   │  Gemini 2.5 Flash Lite  │  │  Food Recognition (Vision)     │   │
│   │  (Chat/Recipe AI)       │  │  Image → Food name + quantity  │   │
│   └─────────────────────────┘  └────────────────────────────────┘   │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

---

## 2. Data Flow — Step by Step

### Flow A: Door Close → Food Detection → Inventory Update

```
Step 1: User closes fridge door
            │
Step 2: Reed switch triggers (GPIO 12 goes LOW)
            │
Step 3: ESP32 detects door close event
            │
Step 4: ESP32 activates camera flash (GPIO 4)
            │
Step 5: ESP32-CAM captures JPEG photo
            │
Step 6: Photo saved to 32GB SD card (local backup)
            │
Step 7: ESP32 uploads photo via HTTP POST to:
        → Supabase Storage: /storage/v1/object/Inventory/scan_<timestamp>.jpg
            │
Step 8: ESP32 sends PATCH to Supabase:
        → /rest/v1/fridge_status?id=eq.1
        → Body: {"door_open": false, "last_updated": "<now>"}
            │
Step 9: Supabase Realtime pushes fridge_status change to Flutter app
            │
Step 10: Flutter app's AutoScanService detects new image in Storage
            │
Step 11: AutoScanService downloads the image bytes
            │
Step 12: Image sent to Gemini Vision API with prompt:
         "Analyze this fridge image, identify food items..."
            │
Step 13: Gemini returns JSON array:
         [{"name": "Eggs", "category": "Protein", "estimated_quantity_grams": 360}, ...]
            │
Step 14: Each item matched against NutritionDatabase (80+ items, USDA-sourced)
         → Gets protein, carbs, fat, calories per 100g
            │
Step 15: Food items inserted into Supabase 'inventory' table
            │
Step 16: Supabase Realtime pushes inventory change to Flutter app
            │
Step 17: App UI updates — My Food tab shows detected items
```

### Flow B: Sensor Monitoring (Every 30 seconds)

```
Step 1: ESP32 timer fires every 30 seconds
            │
Step 2: DHT22 sensor reads temperature + humidity
            │
Step 3: ESP32 sends HTTP PATCH to Supabase:
        → /rest/v1/fridge_status?id=eq.1
        → Body: {
            "fridge_temperature": 4.2,
            "humidity": 45.0,
            "energy_usage_watts": 65,
            "daily_energy_kwh": 1.2,
            "last_updated": "<now>"
          }
            │
Step 4: Supabase Realtime pushes update via WebSocket
            │
Step 5: Flutter app receives update in FridgeProvider
            │
Step 6: Dashboard UI refreshes (temp gauges, charts update)
```

### Flow C: Chef AI Conversation

```
Step 1: User types "What can I make for dinner?" in Chef AI tab
            │
Step 2: ChatProvider receives message
            │
Step 3: AiChefService builds context:
        → Reads current inventory from InventoryProvider
        → Creates prompt: "User has: Eggs (360g), Chicken (500g), Rice (400g)..."
            │
Step 4: (Current) Mock AI responds with keyword-based recipes
        (Production) Send to Gemini API for real AI response
            │
Step 5: Response displayed as chat bubble with mascot avatar 🤖
```

### Flow D: Door Open Alert

```
Step 1: User opens fridge door
            │
Step 2: Reed switch opens (GPIO 12 goes HIGH)
            │
Step 3: ESP32 immediately sends PATCH:
        → {"door_open": true, "last_updated": "<now>"}
            │
Step 4: Supabase Realtime pushes to app instantly
            │
Step 5: Dashboard shows yellow "Door Opened" warning with glowing dot
```

---

## 3. File Structure & Linking

```
pantry_sync/
├── lib/
│   ├── main.dart                    ← App entry point. Initializes Supabase, providers, locale
│   │
│   ├── config/
│   │   └── supabase_config.dart     ← Supabase URL + anon key
│   │
│   ├── models/
│   │   ├── food_item.dart           ← FoodItem data model (name, category, macros)
│   │   ├── fridge_status.dart       ← FridgeStatus model (temp, humidity, door, energy)
│   │   ├── chat_message.dart        ← Chat message model (user/assistant)
│   │   └── recipe.dart              ← Recipe model (ingredients, steps, nutrition)
│   │
│   ├── providers/                   ← State management (Provider pattern)
│   │   ├── inventory_provider.dart  ← Manages food items list, triggers scans
│   │   ├── fridge_provider.dart     ← Manages fridge sensor data
│   │   ├── chat_provider.dart       ← Manages AI chat messages
│   │   └── locale_provider.dart     ← Manages language switching
│   │
│   ├── services/                    ← Business logic & API communication
│   │   ├── supabase_service.dart    ← Supabase DB read/write + realtime streams
│   │   ├── auto_scan_service.dart   ← Watches for new images, calls Gemini, updates inventory
│   │   ├── food_recognition_service.dart  ← Gemini Vision API wrapper
│   │   ├── nutrition_database.dart  ← Local DB of 80+ foods with USDA nutrition data
│   │   ├── usda_api_service.dart    ← Online USDA API fallback
│   │   ├── ai_chef_service.dart     ← Chef AI chat logic
│   │   └── image_storage_service.dart ← Upload/download images from Supabase Storage
│   │
│   ├── screens/                     ← UI pages
│   │   ├── home_screen.dart         ← Bottom navigation (4 tabs)
│   │   ├── dashboard_screen.dart    ← Tab 1: Live photo, door, sensors, energy
│   │   ├── inventory_screen.dart    ← Tab 2: Food items with categories
│   │   ├── chef_screen.dart         ← Tab 3: AI chat with mascot
│   │   └── settings_screen.dart     ← Tab 4: Notifications, language, theme
│   │
│   ├── l10n/
│   │   └── app_localizations.dart   ← 4 languages (EN, MS, ZH, TA)
│   │
│   └── theme/
│       └── app_theme.dart           ← Blue gradient tech theme
│
├── iot/
│   └── esp32_fridge/
│       └── esp32_fridge.ino         ← Arduino code for ESP32-CAM
│
├── supabase/
│   ├── migrations/
│   │   ├── 001_create_tables.sql    ← Creates inventory + fridge_status tables
│   │   └── 002_enable_realtime.sql  ← Enables realtime + RLS policies
│   └── functions/
│       └── analyze-food/index.ts    ← Edge function (alternative to app-side scan)
│
├── test/
│   └── test_food_recognition.dart   ← Test script for Gemini Vision food detection
│
└── docs/
    ├── SETUP_GUIDE.md               ← Hardware wiring + setup instructions
    └── SYSTEM_WORKFLOW.md           ← This file
```

---

## 4. How Services Link Together

```
main.dart
    │
    ├── SupabaseService.initialize()     ← Connects to cloud DB
    ├── AutoScanService.initialize()     ← Prepares Gemini Vision model
    ├── LocaleProvider.loadSavedLocale() ← Loads language preference
    │
    └── MultiProvider
            │
            ├── InventoryProvider
            │       │
            │       ├── listens to → SupabaseService.inventoryStream (realtime)
            │       ├── calls → AutoScanService.scanLatestImage()
            │       └── updates UI → InventoryScreen (My Food tab)
            │
            ├── FridgeProvider
            │       │
            │       ├── listens to → SupabaseService.fridgeStatusStream (realtime)
            │       ├── calls → SupabaseService.updateFridgeSettings()
            │       └── updates UI → DashboardScreen (sensors, door, energy)
            │
            ├── ChatProvider
            │       │
            │       ├── calls → AiChefService.sendMessage()
            │       ├── reads → InventoryProvider.items (for context)
            │       └── updates UI → ChefScreen (chat bubbles)
            │
            └── LocaleProvider
                    │
                    └── updates → MaterialApp.locale → rebuilds all screens
```

---

## 5. Database Schema

### Table: `inventory`
| Column | Type | Source | Purpose |
|--------|------|--------|---------|
| id | BIGSERIAL | Auto | Primary key |
| name | TEXT | Gemini Vision | Food item name ("Eggs", "Chicken") |
| category | TEXT | Gemini Vision | Classification (Protein, Carbs, etc.) |
| quantity | FLOAT | Gemini Vision | Estimated weight in grams |
| protein | FLOAT | NutritionDatabase | Protein per 100g |
| carbs | FLOAT | NutritionDatabase | Carbs per 100g |
| fat | FLOAT | NutritionDatabase | Fat per 100g |
| calories | FLOAT | NutritionDatabase | Calories per 100g |
| detected_at | TIMESTAMP | ESP32/App | When item was scanned |
| image_url | TEXT | Supabase Storage | URL of the source image |

### Table: `fridge_status`
| Column | Type | Source | Purpose |
|--------|------|--------|---------|
| id | INTEGER | Fixed (1) | Single row, always updated |
| fridge_temperature | FLOAT | DHT22 sensor | Current fridge temp (°C) |
| freezer_temperature | FLOAT | ESP32 setting | Current freezer temp (°C) |
| humidity | FLOAT | DHT22 sensor | Internal humidity (%) |
| energy_usage_watts | FLOAT | ESP32 (mock/CT) | Current power draw |
| daily_energy_kwh | FLOAT | Calculated | Daily energy consumption |
| door_open | BOOLEAN | Reed switch | Door state |
| energy_save_mode | BOOLEAN | App setting | Eco mode toggle |
| compressor_speed | INTEGER | App setting | Compressor speed (0-100%) |
| last_updated | TIMESTAMP | ESP32 | Last sensor reading time |

---

## 6. API Communication

### ESP32 → Supabase (HTTP REST)

**Update fridge status:**
```
PATCH https://qixngbxvkwfopvryvpkk.supabase.co/rest/v1/fridge_status?id=eq.1
Headers:
  apikey: <SUPABASE_ANON_KEY>
  Authorization: Bearer <SUPABASE_ANON_KEY>
  Content-Type: application/json
Body:
  {"fridge_temperature": 4.2, "humidity": 45, "door_open": false}
```

**Upload image:**
```
POST https://qixngbxvkwfopvryvpkk.supabase.co/storage/v1/object/Inventory/scan_123456.jpg
Headers:
  Authorization: Bearer <SUPABASE_ANON_KEY>
  Content-Type: image/jpeg
Body: <raw JPEG bytes>
```

### Flutter App → Supabase (supabase_flutter SDK)

- Realtime subscription via WebSocket (auto-managed by SDK)
- REST queries for reading/writing data
- Storage API for image download

### Flutter App → Gemini Vision (google_generative_ai SDK)

```dart
final model = GenerativeModel(model: 'gemini-2.5-flash-lite', apiKey: key);
final content = Content.multi([TextPart(prompt), DataPart('image/jpeg', bytes)]);
final response = await model.generateContent([content]);
// Returns JSON array of detected food items
```

---

## 7. Key Technologies

| Component | Technology | Purpose |
|-----------|-----------|---------|
| Mobile App | Flutter (Dart) | Cross-platform UI |
| State Management | Provider | Reactive state updates |
| Database | Supabase (PostgreSQL) | Cloud data storage |
| Realtime Sync | Supabase Realtime (WebSocket) | Instant updates to app |
| File Storage | Supabase Storage | Food photos |
| AI Vision | Google Gemini 2.5 Flash Lite | Food image recognition |
| AI Chat | Google Gemini (via AiChefService) | Recipe suggestions |
| Nutrition Data | USDA FoodData Central + Local DB | Macro values per food |
| IoT Hardware | ESP32-CAM (AI-Thinker) | Camera + WiFi + processing |
| Temp Sensor | DHT22 | Temperature + humidity |
| Door Sensor | Reed switch + magnet | Open/close detection |
| Localization | Flutter l10n | EN, MS, ZH, TA |
| Charts | fl_chart | Energy usage, sensor displays |

---

## 8. Security Model

- **Supabase Anon Key**: Used by both ESP32 and Flutter app. Safe for client-side use.
- **Row Level Security (RLS)**: Enabled on all tables. Currently allows public read/write (for IoT device). In production, add user-based policies.
- **Gemini API Key**: Stored in app code. In production, move to Supabase Edge Function (server-side).
- **Storage Bucket**: Public read (for displaying images), write protected by anon key.

---

## 9. Current State vs Production

| Feature | Current (Demo) | Production |
|---------|---------------|------------|
| Fridge data | Mock data if Supabase not reachable | Live ESP32 sensor data |
| Food scanning | Works via Gemini Vision | Same, triggered on door close |
| Chef AI chat | Keyword-based mock responses | Full Gemini API conversation |
| Auth | No login (anon key) | Supabase Auth (email/social) |
| Notifications | UI only (toggles) | Push notifications via FCM |
| Multi-user | Single fridge | Family sharing with roles |

---

*Document version: 1.0*
*Last updated: July 2026*
*Project: Pantry Sync — Smart Fridge IoT System*
