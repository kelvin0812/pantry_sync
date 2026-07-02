# 🔌 Pantry Sync — ESP32 IoT Setup

## Hardware Required

| Component | Purpose | ~Price |
|-----------|---------|--------|
| ESP32-CAM (AI-Thinker) | Camera + WiFi | ~$8 |
| DHT22 sensor | Temperature + Humidity | ~$4 |
| Reed switch + magnet | Door open/close detection | ~$2 |
| 10kΩ resistor | Pull-up for DHT22 | ~$0.10 |
| 5V power supply | Power the ESP32 | ~$3 |
| Jumper wires | Connections | ~$2 |

## Wiring Diagram

```
ESP32-CAM (AI-Thinker)
┌──────────────────┐
│                  │
│  GPIO 13 ───────────── DHT22 Data Pin
│                  │         │
│                  │        [10kΩ] ── 3.3V
│                  │
│  GPIO 12 ───────────── Reed Switch ── GND
│                  │     (other pin)
│                  │
│  5V ────────────────── DHT22 VCC
│  GND ───────────────── DHT22 GND
│                  │
│  (Camera built-in)     Reed switch magnet
│                  │     mounted on fridge door
└──────────────────┘
```

## Setup Steps

1. **Install Arduino IDE** (or PlatformIO)

2. **Add ESP32 board support:**
   - Arduino IDE → Preferences → Additional Board URLs:
   - `https://dl.espressif.com/dl/package_esp32_index.json`
   - Tools → Board Manager → Install "esp32"

3. **Install libraries** (Sketch → Include Library → Manage Libraries):
   - `ArduinoJson` by Benoit Blanchon
   - `DHT sensor library` by Adafruit
   - `Adafruit Unified Sensor`

4. **Configure the code:**
   - Open `esp32_fridge.ino`
   - Update `WIFI_SSID` and `WIFI_PASSWORD`
   - Supabase credentials are already filled in

5. **Upload:**
   - Board: "AI Thinker ESP32-CAM"
   - Port: your COM port
   - Connect GPIO 0 to GND for upload mode
   - Click Upload
   - Disconnect GPIO 0 from GND
   - Press Reset

## How It Works

```
Door Opens → Reed switch triggers
          → ESP32 sends door_open=true to Supabase
          → Flutter app shows "Door Open" in real-time

Door Closes → Reed switch triggers
           → ESP32 captures photo with flash
           → Image uploaded to Supabase Storage
           → ESP32 sends door_open=false
           → Flutter app receives update instantly

Every 30s → DHT22 reads temperature + humidity
          → ESP32 updates fridge_status table
          → Flutter app dashboard refreshes
```

## Mounting Tips

- Mount ESP32-CAM at the **top of the fridge** pointing down
- Place **reed switch** on the fridge frame, **magnet** on the door
- Keep DHT22 **inside the fridge** (seal wire entry with silicone)
- Use a **waterproof enclosure** for the ESP32 if inside the fridge
- Power via USB cable routed through the door seal gap

## Troubleshooting

| Issue | Fix |
|-------|-----|
| Camera init failed | Check power supply (5V 2A minimum) |
| WiFi won't connect | Ensure 2.4GHz network (ESP32 doesn't support 5GHz) |
| DHT returns NaN | Check wiring + pull-up resistor |
| Upload to Supabase fails | Check RLS policies are set correctly |
| Blurry images | Clean lens, ensure adequate lighting (flash LED helps) |
