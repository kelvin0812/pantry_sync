// ignore_for_file: avoid_print
/// ═══════════════════════════════════════════════════════════
/// TEST: Food Recognition with Gemini Vision
/// ═══════════════════════════════════════════════════════════
///
/// This script downloads an image from your Supabase Storage
/// and sends it to Gemini Vision to identify food items.
///
/// HOW TO RUN:
///   1. Get a Gemini API key from: https://aistudio.google.com/app/apikey
///   2. Replace 'YOUR_GEMINI_API_KEY' below
///   3. Run: dart run test/test_food_recognition.dart
///
/// WHAT IT DOES:
///   1. Downloads image from Supabase Storage
///   2. Sends to Gemini Vision API
///   3. Prints detected food items with categories + quantities
///   4. Looks up nutrition data for each item
///
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:google_generative_ai/google_generative_ai.dart';

// ─── CONFIG ────────────────────────────────────────────────
const supabaseUrl = 'https://qixngbxvkwfopvryvpkk.supabase.co';
const geminiApiKey = 'AIzaSyDs9K3KOOIL7UxCHmbR2uwdt55PwYz8_5c'; // Gemini API Key

// Your test image in Supabase Storage
const testImageBucket = 'Inventory';
const testImagePath = 'photo_1195559.jpg';
// ───────────────────────────────────────────────────────────

void main() async {
  print('═══════════════════════════════════════════════');
  print('  PANTRY SYNC — Food Recognition Test');
  print('═══════════════════════════════════════════════\n');

  if (geminiApiKey == 'YOUR_GEMINI_API_KEY') {
    print('❌ ERROR: Please add your Gemini API key!');
    print('   Get one free at: https://aistudio.google.com/app/apikey');
    print('   Then replace YOUR_GEMINI_API_KEY in this file.\n');
    return;
  }

  // Step 1: Download image from Supabase Storage
  print('📷 Step 1: Downloading image from Supabase...');
  final imageUrl =
      '$supabaseUrl/storage/v1/object/public/$testImageBucket/$testImagePath';
  print('   URL: $imageUrl');

  final imageResponse = await http.get(Uri.parse(imageUrl));
  if (imageResponse.statusCode != 200) {
    print('❌ Failed to download image (HTTP ${imageResponse.statusCode})');
    print('   Make sure the bucket is public and file exists.');
    return;
  }

  final Uint8List imageBytes = imageResponse.bodyBytes;
  print('   ✓ Downloaded: ${imageBytes.length} bytes\n');

  // Step 2: Send to Gemini Vision
  print('🤖 Step 2: Sending to Gemini Vision for analysis...');

  final model = GenerativeModel(
    model: 'gemini-2.5-flash-lite',
    apiKey: geminiApiKey,
    generationConfig: GenerationConfig(
      temperature: 0.2,
      responseMimeType: 'application/json',
    ),
  );

  final prompt = '''
Analyze this fridge image and identify all visible food items.

For each food item, provide:
- "name": the common name of the food (in English)
- "category": one of [Protein, Carbs, Vegetables, Fruits, Dairy, Condiments, Beverages, Snacks, Other]
- "estimated_quantity_grams": estimated weight in grams based on visual size
- "confidence": your confidence level (high, medium, low)

Return a JSON array. Example:
[
  {"name": "Eggs", "category": "Protein", "estimated_quantity_grams": 360, "confidence": "high"},
  {"name": "Milk", "category": "Dairy", "estimated_quantity_grams": 1000, "confidence": "medium"}
]

Only include items you can clearly identify. Be conservative with quantity estimates.
Return ONLY the JSON array, no other text.
''';

  try {
    final content = Content.multi([
      TextPart(prompt),
      DataPart('image/jpeg', imageBytes),
    ]);

    final response = await model.generateContent([content]);
    final responseText = response.text;

    if (responseText == null || responseText.isEmpty) {
      print('❌ Gemini returned empty response');
      return;
    }

    print('   ✓ Gemini responded!\n');

    // Step 3: Parse results
    print('🍎 Step 3: Detected Food Items:');
    print('─────────────────────────────────────────────');

    final List<dynamic> items = jsonDecode(responseText);

    if (items.isEmpty) {
      print('   No food items detected in this image.');
      print('   Try a clearer image with food visible.');
      return;
    }

    for (int i = 0; i < items.length; i++) {
      final item = items[i] as Map<String, dynamic>;
      final name = item['name'] ?? 'Unknown';
      final category = item['category'] ?? 'Other';
      final quantity = item['estimated_quantity_grams'] ?? 0;
      final confidence = item['confidence'] ?? 'unknown';

      print('   ${i + 1}. $name');
      print('      Category: $category');
      print('      Estimated: ${quantity}g');
      print('      Confidence: $confidence');
      print('');
    }

    print('─────────────────────────────────────────────');
    print('✅ Total items detected: ${items.length}');
    print('\n💡 These items would be inserted into your');
    print('   Supabase "inventory" table automatically');
    print('   when the ESP32 triggers a scan.\n');

  } catch (e) {
    print('❌ Error calling Gemini: $e');
    print('   Check your API key and internet connection.');
  }
}
