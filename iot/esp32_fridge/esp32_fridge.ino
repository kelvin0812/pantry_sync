/*
 * ═══════════════════════════════════════════════════════════
 * PANTRY SYNC - ESP32 Smart Fridge Controller
 * ═══════════════════════════════════════════════════════════
 * 
 * Hardware:
 *   - ESP32-CAM (AI-Thinker) — camera + WiFi
 *   - DHT22 sensor — temperature + humidity
 *   - Reed switch — door open/close detection
 *   - (Optional) DS18B20 — precise fridge/freezer temperature
 * 
 * Flow:
 *   1. Door opens → update door_open = true in Supabase
 *   2. Door closes → capture image → upload to Supabase Storage
 *      → update door_open = false
 *   3. Every 30s → read sensors → update fridge_status table
 * 
 * Wiring:
 *   - DHT22 data pin → GPIO 13
 *   - Reed switch → GPIO 12 (with internal pull-up)
 *   - Camera uses default ESP32-CAM pins
 * 
 * Libraries needed (install via Arduino Library Manager):
 *   - ArduinoJson (by Benoit Blanchon)
 *   - DHT sensor library (by Adafruit)
 *   - ESP32 board package
 */

#include <WiFi.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>
#include "DHT.h"
#include "esp_camera.h"
#include "soc/soc.h"
#include "soc/rtc_cntl_reg.h"

// ═══════════════════════════════════════════════════════════
// CONFIGURATION — Update these!
// ═══════════════════════════════════════════════════════════

// WiFi credentials
const char* WIFI_SSID = "YOUR_WIFI_SSID";
const char* WIFI_PASSWORD = "YOUR_WIFI_PASSWORD";

// Supabase credentials
const char* SUPABASE_URL = "https://qixngbxvkwfopvryvpkk.supabase.co";
const char* SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFpeG5nYnh2a3dmb3B2cnl2cGtrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODMwMDA5NDUsImV4cCI6MjA5ODU3Njk0NX0.WmmM2dxL1_BdeiL3nIvbO8TZUtvQ88sg2YNBvKLdJKM";

// ═══════════════════════════════════════════════════════════
// PIN CONFIGURATION
// ═══════════════════════════════════════════════════════════

#define DHTPIN 13          // DHT22 data pin
#define DHTTYPE DHT22
#define DOOR_SWITCH_PIN 12 // Reed switch (LOW = closed, HIGH = open)
#define LED_PIN 4          // Built-in flash LED (ESP32-CAM)

// ═══════════════════════════════════════════════════════════
// ESP32-CAM CAMERA PINS (AI-Thinker module)
// ═══════════════════════════════════════════════════════════

#define PWDN_GPIO_NUM     32
#define RESET_GPIO_NUM    -1
#define XCLK_GPIO_NUM      0
#define SIOD_GPIO_NUM     26
#define SIOC_GPIO_NUM     27
#define Y9_GPIO_NUM       35
#define Y8_GPIO_NUM       34
#define Y7_GPIO_NUM       39
#define Y6_GPIO_NUM       36
#define Y5_GPIO_NUM       21
#define Y4_GPIO_NUM       19
#define Y3_GPIO_NUM       18
#define Y2_GPIO_NUM        5
#define VSYNC_GPIO_NUM    25
#define HREF_GPIO_NUM     23
#define PCLK_GPIO_NUM     22

// ═══════════════════════════════════════════════════════════
// GLOBAL VARIABLES
// ═══════════════════════════════════════════════════════════

DHT dht(DHTPIN, DHTTYPE);

bool doorOpen = false;
bool lastDoorState = false;
unsigned long lastSensorUpdate = 0;
const unsigned long SENSOR_INTERVAL = 30000; // 30 seconds

float fridgeTemp = 4.0;
float humidity = 45.0;
float energyWatts = 65.0;

// ═══════════════════════════════════════════════════════════
// SETUP
// ═══════════════════════════════════════════════════════════

void setup() {
  WRITE_PERI_REG(RTC_CNTL_BROWN_OUT_REG, 0); // Disable brownout detector

  Serial.begin(115200);
  Serial.println("\n=== Pantry Sync ESP32 Starting ===");

  // Pin setup
  pinMode(DOOR_SWITCH_PIN, INPUT_PULLUP);
  pinMode(LED_PIN, OUTPUT);
  digitalWrite(LED_PIN, LOW);

  // Initialize DHT sensor
  dht.begin();

  // Initialize camera
  initCamera();

  // Connect to WiFi
  connectWiFi();

  Serial.println("=== Setup Complete ===\n");
}

// ═══════════════════════════════════════════════════════════
// MAIN LOOP
// ═══════════════════════════════════════════════════════════

void loop() {
  // Check door state
  bool currentDoorState = digitalRead(DOOR_SWITCH_PIN) == HIGH;

  // Door state changed
  if (currentDoorState != lastDoorState) {
    lastDoorState = currentDoorState;
    doorOpen = currentDoorState;

    if (doorOpen) {
      Serial.println("🚪 Door OPENED");
      updateDoorStatus(true);
    } else {
      Serial.println("🚪 Door CLOSED — capturing image...");
      updateDoorStatus(false);
      delay(1000); // Wait for door to fully close
      captureAndUpload();
    }
  }

  // Periodic sensor reading (every 30s)
  if (millis() - lastSensorUpdate >= SENSOR_INTERVAL) {
    lastSensorUpdate = millis();
    readAndUpdateSensors();
  }

  delay(100); // Small delay to debounce
}

// ═══════════════════════════════════════════════════════════
// WiFi CONNECTION
// ═══════════════════════════════════════════════════════════

void connectWiFi() {
  Serial.print("Connecting to WiFi");
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

  int attempts = 0;
  while (WiFi.status() != WL_CONNECTED && attempts < 30) {
    delay(500);
    Serial.print(".");
    attempts++;
  }

  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("\n✓ WiFi connected!");
    Serial.print("  IP: ");
    Serial.println(WiFi.localIP());
  } else {
    Serial.println("\n✗ WiFi failed! Restarting...");
    ESP.restart();
  }
}

// ═══════════════════════════════════════════════════════════
// CAMERA INITIALIZATION
// ═══════════════════════════════════════════════════════════

void initCamera() {
  camera_config_t config;
  config.ledc_channel = LEDC_CHANNEL_0;
  config.ledc_timer = LEDC_TIMER_0;
  config.pin_d0 = Y2_GPIO_NUM;
  config.pin_d1 = Y3_GPIO_NUM;
  config.pin_d2 = Y4_GPIO_NUM;
  config.pin_d3 = Y5_GPIO_NUM;
  config.pin_d4 = Y6_GPIO_NUM;
  config.pin_d5 = Y7_GPIO_NUM;
  config.pin_d6 = Y8_GPIO_NUM;
  config.pin_d7 = Y9_GPIO_NUM;
  config.pin_xclk = XCLK_GPIO_NUM;
  config.pin_pclk = PCLK_GPIO_NUM;
  config.pin_vsync = VSYNC_GPIO_NUM;
  config.pin_href = HREF_GPIO_NUM;
  config.pin_sccb_sda = SIOD_GPIO_NUM;
  config.pin_sccb_scl = SIOC_GPIO_NUM;
  config.pin_pwdn = PWDN_GPIO_NUM;
  config.pin_reset = RESET_GPIO_NUM;
  config.xclk_freq_hz = 20000000;
  config.pixel_format = PIXFORMAT_JPEG;

  // Use higher resolution for better food detection
  config.frame_size = FRAMESIZE_VGA; // 640x480
  config.jpeg_quality = 12;
  config.fb_count = 1;

  esp_err_t err = esp_camera_init(&config);
  if (err != ESP_OK) {
    Serial.printf("✗ Camera init failed: 0x%x\n", err);
  } else {
    Serial.println("✓ Camera initialized");
  }
}

// ═══════════════════════════════════════════════════════════
// CAPTURE IMAGE & UPLOAD TO SUPABASE STORAGE
// ═══════════════════════════════════════════════════════════

void captureAndUpload() {
  // Flash LED on for capture
  digitalWrite(LED_PIN, HIGH);
  delay(200);

  camera_fb_t *fb = esp_camera_fb_get();
  digitalWrite(LED_PIN, LOW);

  if (!fb) {
    Serial.println("✗ Camera capture failed");
    return;
  }

  Serial.printf("✓ Image captured: %d bytes\n", fb->len);

  // Upload to Supabase Storage
  String fileName = "scans/fridge_" + String(millis()) + ".jpg";
  String uploadUrl = String(SUPABASE_URL) + "/storage/v1/object/food-images/" + fileName;

  HTTPClient http;
  http.begin(uploadUrl);
  http.addHeader("Authorization", "Bearer " + String(SUPABASE_KEY));
  http.addHeader("Content-Type", "image/jpeg");
  http.addHeader("x-upsert", "true");

  int httpCode = http.POST(fb->buf, fb->len);

  if (httpCode == 200 || httpCode == 201) {
    Serial.println("✓ Image uploaded to Supabase Storage");

    // Get public URL for the image
    String publicUrl = String(SUPABASE_URL) + "/storage/v1/object/public/food-images/" + fileName;
    Serial.println("  URL: " + publicUrl);
  } else {
    Serial.printf("✗ Upload failed: HTTP %d\n", httpCode);
    String response = http.getString();
    Serial.println("  Response: " + response);
  }

  http.end();
  esp_camera_fb_return(fb);
}

// ═══════════════════════════════════════════════════════════
// READ SENSORS & UPDATE SUPABASE
// ═══════════════════════════════════════════════════════════

void readAndUpdateSensors() {
  // Read DHT22
  float h = dht.readHumidity();
  float t = dht.readTemperature();

  if (!isnan(h) && !isnan(t)) {
    humidity = h;
    fridgeTemp = t;
    Serial.printf("📡 Sensors: %.1f°C, %.0f%% humidity\n", fridgeTemp, humidity);
  } else {
    Serial.println("⚠ DHT read failed, using last values");
  }

  // Simulate energy reading (replace with actual CT sensor if available)
  energyWatts = random(55, 75);

  // Update Supabase fridge_status table
  updateFridgeStatus();
}

// ═══════════════════════════════════════════════════════════
// UPDATE FRIDGE STATUS IN SUPABASE
// ═══════════════════════════════════════════════════════════

void updateFridgeStatus() {
  if (WiFi.status() != WL_CONNECTED) {
    connectWiFi();
  }

  // Build JSON payload
  StaticJsonDocument<256> doc;
  doc["fridge_temperature"] = fridgeTemp;
  doc["humidity"] = humidity;
  doc["energy_usage_watts"] = energyWatts;
  doc["daily_energy_kwh"] = (energyWatts * 24.0) / 1000.0;
  doc["door_open"] = doorOpen;
  doc["last_updated"] = getTimestamp();

  String jsonPayload;
  serializeJson(doc, jsonPayload);

  // PATCH fridge_status where id = 1
  String url = String(SUPABASE_URL) + "/rest/v1/fridge_status?id=eq.1";

  HTTPClient http;
  http.begin(url);
  http.addHeader("apikey", SUPABASE_KEY);
  http.addHeader("Authorization", "Bearer " + String(SUPABASE_KEY));
  http.addHeader("Content-Type", "application/json");
  http.addHeader("Prefer", "return=minimal");

  int httpCode = http.PATCH(jsonPayload);

  if (httpCode == 200 || httpCode == 204) {
    Serial.println("✓ Fridge status updated in Supabase");
  } else {
    Serial.printf("✗ Status update failed: HTTP %d\n", httpCode);
  }

  http.end();
}

// ═══════════════════════════════════════════════════════════
// UPDATE DOOR STATUS
// ═══════════════════════════════════════════════════════════

void updateDoorStatus(bool isOpen) {
  if (WiFi.status() != WL_CONNECTED) return;

  StaticJsonDocument<128> doc;
  doc["door_open"] = isOpen;
  doc["last_updated"] = getTimestamp();

  String jsonPayload;
  serializeJson(doc, jsonPayload);

  String url = String(SUPABASE_URL) + "/rest/v1/fridge_status?id=eq.1";

  HTTPClient http;
  http.begin(url);
  http.addHeader("apikey", SUPABASE_KEY);
  http.addHeader("Authorization", "Bearer " + String(SUPABASE_KEY));
  http.addHeader("Content-Type", "application/json");
  http.addHeader("Prefer", "return=minimal");

  http.PATCH(jsonPayload);
  http.end();
}

// ═══════════════════════════════════════════════════════════
// UTILITY: Get ISO 8601 timestamp
// ═══════════════════════════════════════════════════════════

String getTimestamp() {
  // Simple timestamp without NTP (use millis-based)
  // For production, sync with NTP server for real timestamps
  unsigned long ms = millis();
  unsigned long secs = ms / 1000;
  unsigned long mins = secs / 60;
  unsigned long hrs = mins / 60;

  // Return a basic ISO-ish timestamp
  // In production, use NTP: configTime(0, 0, "pool.ntp.org");
  char buf[30];
  time_t now;
  time(&now);
  struct tm *timeinfo = gmtime(&now);
  strftime(buf, sizeof(buf), "%Y-%m-%dT%H:%M:%SZ", timeinfo);
  return String(buf);
}
