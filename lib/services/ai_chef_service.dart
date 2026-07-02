import '../models/food_item.dart';
import '../models/recipe.dart';
import '../models/chat_message.dart';

/// AI Chef Agent service.
/// Generates recipes based on available inventory and user preferences.
///
/// In production, integrate with Google Gemini API via google_generative_ai package.
/// For demo purposes, returns pre-built recipe suggestions.
class AiChefService {
  // Singleton
  static final AiChefService _instance = AiChefService._internal();
  factory AiChefService() => _instance;
  AiChefService._internal();

  final List<ChatMessage> _chatHistory = [];

  List<ChatMessage> get chatHistory => List.unmodifiable(_chatHistory);

  /// Generate a recipe suggestion based on current inventory
  Future<Recipe> suggestRecipe(List<FoodItem> inventory) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    // Demo recipe based on mock inventory (eggs, rice, scallions)
    return Recipe(
      title: 'Egg Fried Rice with Scallions',
      description:
          'A quick and satisfying stir-fried rice using your leftover rice, eggs, and fresh scallions.',
      ingredients: [
        '2 cups leftover rice',
        '3 eggs, beaten',
        '4 stalks scallions, chopped',
        '2 tbsp soy sauce',
        '1 tbsp butter or oil',
        'Salt and pepper to taste',
      ],
      steps: [
        'Heat butter or oil in a large wok or skillet over high heat.',
        'Add beaten eggs and scramble until just set, then break into pieces.',
        'Add the cold leftover rice, breaking up any clumps.',
        'Stir-fry for 3-4 minutes until rice is heated through and slightly crispy.',
        'Add soy sauce and toss to coat evenly.',
        'Fold in chopped scallions, reserving some for garnish.',
        'Season with salt and pepper. Serve hot with scallion garnish.',
      ],
      prepTimeMinutes: 5,
      cookTimeMinutes: 10,
      nutrition: NutritionInfo(
        calories: 420,
        protein: 18.5,
        carbs: 52.0,
        fat: 15.0,
      ),
      difficulty: 'Easy',
    );
  }

  /// Send a chat message to the AI agent and get a response
  Future<ChatMessage> sendMessage(
    String userMessage,
    List<FoodItem> inventory,
  ) async {
    // Add user message to history
    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: MessageRole.user,
      content: userMessage,
      timestamp: DateTime.now(),
    );
    _chatHistory.add(userMsg);

    // Simulate AI thinking
    await Future.delayed(const Duration(seconds: 1));

    // Build context-aware response
    final inventoryList =
        inventory.map((item) => '${item.name} (${item.quantity}g)').join(', ');

    String responseText;

    if (userMessage.toLowerCase().contains('protein')) {
      final totalProtein =
          inventory.fold(0.0, (sum, item) => sum + item.totalProtein);
      responseText =
          'Based on your fridge contents ($inventoryList), you have approximately '
          '${totalProtein.toStringAsFixed(0)}g of protein available.\n\n'
          'For a high-protein meal, I suggest:\n\n'
          '**Grilled Chicken with Egg & Rice Bowl**\n'
          '- 200g chicken breast (62g protein)\n'
          '- 2 eggs (13g protein)\n'
          '- Steamed rice with scallions\n'
          '- Total: ~75g protein\n\n'
          'Shall I give you step-by-step instructions?';
    } else if (userMessage.toLowerCase().contains('dinner') ||
        userMessage.toLowerCase().contains('make')) {
      responseText =
          'Looking at what\'s in your fridge: $inventoryList\n\n'
          'Here are 3 dinner ideas:\n\n'
          '1. **Egg Fried Rice** - Quick 15-min meal with eggs, rice, and scallions\n'
          '2. **Chicken Stir-Fry** - Bell pepper and chicken with soy sauce over rice\n'
          '3. **Chicken Rice Bowl** - Sliced chicken breast over rice with scallion garnish\n\n'
          'Which one interests you? I can provide the full recipe with macros.';
    } else {
      responseText =
          'I can see you have: $inventoryList in your fridge right now.\n\n'
          'Try asking me:\n'
          '- "What can I make for dinner?"\n'
          '- "I need a high-protein meal"\n'
          '- "Quick 15-minute recipe"\n'
          '- "What\'s the healthiest option?"\n\n'
          'I\'ll tailor recipes to exactly what you have available!';
    }

    final assistantMsg = ChatMessage(
      id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
      role: MessageRole.assistant,
      content: responseText,
      timestamp: DateTime.now(),
    );
    _chatHistory.add(assistantMsg);

    return assistantMsg;
  }

  void clearHistory() {
    _chatHistory.clear();
  }
}
