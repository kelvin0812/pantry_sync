import 'package:flutter/foundation.dart';

import '../models/chat_message.dart';
import '../models/food_item.dart';
import '../services/ai_chef_service.dart';

class ChatProvider extends ChangeNotifier {
  final AiChefService _aiService = AiChefService();

  List<ChatMessage> get messages => _aiService.chatHistory;
  bool _isTyping = false;

  bool get isTyping => _isTyping;

  Future<void> sendMessage(String text, List<FoodItem> inventory) async {
    _isTyping = true;
    notifyListeners();

    await _aiService.sendMessage(text, inventory);

    _isTyping = false;
    notifyListeners();
  }

  void clearChat() {
    _aiService.clearHistory();
    notifyListeners();
  }
}
