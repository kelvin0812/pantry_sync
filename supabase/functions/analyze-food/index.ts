// ═══════════════════════════════════════════════════════════
// SUPABASE EDGE FUNCTION: Auto-analyze uploaded food images
// ═══════════════════════════════════════════════════════════
//
// This function is triggered via a Database Webhook when a new
// file is uploaded to the 'Inventory' storage bucket.
//
// Flow:
//   1. New image uploaded to Storage (by ESP32 or app)
//   2. Webhook triggers this function
//   3. Function downloads the image
//   4. Sends to Gemini Vision for food detection
//   5. Inserts detected items into 'inventory' table
//
// SETUP:
//   1. Deploy: supabase functions deploy analyze-food
//   2. Set secret: supabase secrets set GEMINI_API_KEY=AIzaSyDs9K3KOOIL7UxCHmbR2uwdt55PwYz8_5c
//   3. Create a Database Webhook (see instructions below)
//
// ALTERNATIVE (simpler): Use a Storage webhook or call this
// function directly from the ESP32 after uploading an image.

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const GEMINI_API_KEY = Deno.env.get("GEMINI_API_KEY") ?? "";
const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";

serve(async (req) => {
  try {
    const { imagePath, bucketName } = await req.json();

    if (!imagePath) {
      return new Response(JSON.stringify({ error: "imagePath is required" }), {
        status: 400,
        headers: { "Content-Type": "application/json" },
      });
    }

    const bucket = bucketName || "Inventory";

    // 1. Download image from Supabase Storage
    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);
    const { data: fileData, error: downloadError } = await supabase.storage
      .from(bucket)
      .download(imagePath);

    if (downloadError || !fileData) {
      return new Response(
        JSON.stringify({ error: `Failed to download image: ${downloadError?.message}` }),
        { status: 500, headers: { "Content-Type": "application/json" } }
      );
    }

    // Convert to base64
    const arrayBuffer = await fileData.arrayBuffer();
    const base64Image = btoa(String.fromCharCode(...new Uint8Array(arrayBuffer)));

    // 2. Send to Gemini Vision
    const geminiUrl = `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent?key=${GEMINI_API_KEY}`;

    const geminiResponse = await fetch(geminiUrl, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        contents: [
          {
            parts: [
              {
                text: `Analyze this fridge image and identify all visible food items.
For each food item, provide:
- "name": the common name of the food (in English)
- "category": one of [Protein, Carbs, Vegetables, Fruits, Dairy, Condiments, Beverages, Snacks, Other]
- "estimated_quantity_grams": estimated weight in grams based on visual size

Return ONLY a JSON array. Example:
[{"name": "Eggs", "category": "Protein", "estimated_quantity_grams": 360}]

If no food is visible, return an empty array: []`,
              },
              {
                inlineData: {
                  mimeType: "image/jpeg",
                  data: base64Image,
                },
              },
            ],
          },
        ],
        generationConfig: {
          temperature: 0.2,
          responseMimeType: "application/json",
        },
      }),
    });

    const geminiResult = await geminiResponse.json();

    // Extract text response
    const responseText =
      geminiResult?.candidates?.[0]?.content?.parts?.[0]?.text ?? "[]";

    let detectedItems: any[];
    try {
      detectedItems = JSON.parse(responseText);
    } catch {
      detectedItems = [];
    }

    if (detectedItems.length === 0) {
      return new Response(
        JSON.stringify({ message: "No food items detected", items: [] }),
        { status: 200, headers: { "Content-Type": "application/json" } }
      );
    }

    // 3. Nutrition lookup (basic values per 100g)
    const nutritionMap: Record<string, { protein: number; carbs: number; fat: number; calories: number }> = {
      "Protein": { protein: 20, carbs: 1, fat: 8, calories: 155 },
      "Carbs": { protein: 3, carbs: 28, fat: 0.5, calories: 130 },
      "Vegetables": { protein: 2, carbs: 5, fat: 0.3, calories: 30 },
      "Fruits": { protein: 0.8, carbs: 14, fat: 0.3, calories: 55 },
      "Dairy": { protein: 3.4, carbs: 5, fat: 3, calories: 60 },
      "Condiments": { protein: 2, carbs: 10, fat: 0.5, calories: 50 },
      "Beverages": { protein: 0.5, carbs: 10, fat: 0.1, calories: 45 },
      "Snacks": { protein: 5, carbs: 30, fat: 15, calories: 300 },
      "Other": { protein: 5, carbs: 10, fat: 3, calories: 80 },
    };

    // 4. Insert into inventory table
    const imageUrl = `${SUPABASE_URL}/storage/v1/object/public/${bucket}/${imagePath}`;

    const inventoryItems = detectedItems.map((item: any) => {
      const category = item.category || "Other";
      const nutrition = nutritionMap[category] || nutritionMap["Other"];
      return {
        name: item.name,
        category: category,
        quantity: item.estimated_quantity_grams || 100,
        protein: nutrition.protein,
        carbs: nutrition.carbs,
        fat: nutrition.fat,
        calories: nutrition.calories,
        detected_at: new Date().toISOString(),
        image_url: imageUrl,
      };
    });

    const { error: insertError } = await supabase
      .from("inventory")
      .insert(inventoryItems);

    if (insertError) {
      return new Response(
        JSON.stringify({ error: `Insert failed: ${insertError.message}`, items: detectedItems }),
        { status: 500, headers: { "Content-Type": "application/json" } }
      );
    }

    return new Response(
      JSON.stringify({
        message: `Successfully detected and stored ${detectedItems.length} food items`,
        items: detectedItems,
      }),
      { status: 200, headers: { "Content-Type": "application/json" } }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { "Content-Type": "application/json" } }
    );
  }
});
