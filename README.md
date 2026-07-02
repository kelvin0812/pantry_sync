# 🧊 Pantry Sync

**The Frictionless Kitchen Agent** — A smart fridge IoT system with AI-powered food recognition and recipe suggestions.

Built with Flutter + Supabase + Google Gemini AI.

## ✨ Features

### 🏠 Home Dashboard
- Warm personalized greeting
- Real-time fridge door sensor status
- Temperature & humidity monitoring
- Food inventory summary with macro breakdown
- Energy usage tracking with eco mode

### 🍳 Smart Inventory (My Food)
- **AI-powered food scanning** — Camera detects food items using Gemini Vision
- Visual food cards with emoji representations
- Category filtering & search
- Tap-for-detail nutrition breakdown
- USDA-backed nutrition database (80+ common items)

### 🤖 Chef AI Assistant
- Conversational recipe suggestions based on current inventory
- Context-aware — knows what's in your fridge
- Quick suggestion chips for common queries
- Powered by Google Gemini API

### ⚙️ Settings
- Notification preferences (door alerts, expiry reminders)
- Multi-language support (English, Malay, Chinese, Tamil)
- Theme selection (Light/Dark/System)
- Temperature unit preference

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────┐
│                   Flutter App                        │
│  ┌───────────┐  ┌───────────┐  ┌───────────┐      │
│  │ Dashboard │  │ Inventory │  │  Chef AI  │      │
│  └─────┬─────┘  └─────┬─────┘  └─────┬─────┘      │
│        │               │               │            │
│  ┌─────▼───────────────▼───────────────▼─────┐     │
│  │           Provider (State Management)      │     │
│  └─────────────────────┬─────────────────────┘     │
└────────────────────────┼────────────────────────────┘
                         │
           ┌─────────────┼─────────────┐
           │             │             │
    ┌──────▼──────┐ ┌───▼────┐ ┌─────▼──────┐
    │  Supabase   │ │ Gemini │ │  USDA API  │
    │  (Realtime  │ │ Vision │ │ (Nutrition)│
    │   Database) │ │  (AI)  │ │            │
    └──────┬──────┘ └────────┘ └────────────┘
           │
    ┌──────▼──────┐
    │  IoT Device │
    │ (ESP32/RPi) │
    │  - Camera   │
    │  - Sensors  │
    └─────────────┘
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.11+
- A Supabase account (free tier works)
- Google Gemini API key (for food scanning & Chef AI)

### Setup

1. **Clone the repo**
```bash
git clone https://github.com/kelvin0812/pantry_sync.git
cd pantry_sync
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Configure Supabase**
   - Create a project at [supabase.com](https://supabase.com)
   - Run the SQL migrations in `supabase/migrations/` via SQL Editor
   - Update `lib/config/supabase_config.dart` with your URL and anon key

4. **Configure Gemini AI** (optional, for food scanning)
   - Get an API key at [aistudio.google.com](https://aistudio.google.com/app/apikey)
   - Initialize `FoodRecognitionService` with your key

5. **Run the app**
```bash
flutter run
```

> The app runs in **mock mode** by default if Supabase isn't configured.

## 🗄️ Database Schema (Supabase)

### `inventory` table
| Column | Type | Description |
|--------|------|-------------|
| id | BIGSERIAL | Primary key |
| name | TEXT | Food item name |
| category | TEXT | Protein, Carbs, Vegetables, etc. |
| quantity | FLOAT | Weight in grams |
| protein | FLOAT | Protein per 100g |
| carbs | FLOAT | Carbs per 100g |
| fat | FLOAT | Fat per 100g |
| calories | FLOAT | Calories per 100g |
| detected_at | TIMESTAMPTZ | When item was scanned |
| image_url | TEXT | Optional photo URL |

### `fridge_status` table
| Column | Type | Description |
|--------|------|-------------|
| fridge_temperature | FLOAT | Current fridge temp (°C) |
| freezer_temperature | FLOAT | Current freezer temp (°C) |
| humidity | FLOAT | Internal humidity (%) |
| door_open | BOOLEAN | Door sensor state |
| energy_save_mode | BOOLEAN | Eco mode toggle |
| compressor_speed | INTEGER | Compressor speed (0-100%) |
| energy_usage_watts | FLOAT | Current power draw |

## 📦 Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | Flutter (Dart) |
| State Management | Provider |
| Database | Supabase (PostgreSQL + Realtime) |
| AI / Vision | Google Gemini 2.0 Flash |
| Nutrition Data | USDA FoodData Central API + Local DB |
| Charts | fl_chart |
| IoT Communication | Supabase Realtime (WebSocket) |

## 🔮 IoT Integration

The IoT device (ESP32 or Raspberry Pi) communicates with the app through Supabase:

- **Door sensor** → writes `door_open` to `fridge_status`
- **Temperature sensors** → updates `fridge_temperature`, `freezer_temperature`
- **Camera** → on door close, captures image → sends to Gemini Vision → writes detected items to `inventory`
- **App settings** → user adjusts temperature/eco mode → written to `fridge_status` → IoT device reads and actuates

## 📄 License

This project is for educational/academic purposes.
