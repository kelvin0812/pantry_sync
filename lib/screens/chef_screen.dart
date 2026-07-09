import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/chat_message.dart';
import '../providers/chat_provider.dart';
import '../providers/inventory_provider.dart';
import '../theme/app_theme.dart';

class ChefScreen extends StatefulWidget {
  const ChefScreen({super.key});

  @override
  State<ChefScreen> createState() => _ChefScreenState();
}

class _ChefScreenState extends State<ChefScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final chatProvider = context.read<ChatProvider>();
    final inventory = context.read<InventoryProvider>();

    chatProvider.sendMessage(text, inventory.items);
    _messageController.clear();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Chef AI',
            style: TextStyle(fontWeight: FontWeight.bold)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear chat',
            onPressed: () => chatProvider.clearChat(),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 100),
          // Chat messages
          Expanded(
            child: chatProvider.messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: chatProvider.messages.length,
                    itemBuilder: (context, index) {
                      return _buildMessageBubble(chatProvider.messages[index]);
                    },
                  ),
          ),

          // Typing indicator
          if (chatProvider.isTyping)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  _buildMascotSmall(),
                  const SizedBox(width: 8),
                  const Text('Thinking...',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontStyle: FontStyle.italic,
                      )),
                ],
              ),
            ),

          // Quick suggestions
          if (chatProvider.messages.isEmpty) _buildQuickSuggestions(),

          // Input
          _buildInputField(),
        ],
      ),
    );
  }

  // ─── MASCOT ─────────────────────────────────────────────────
  Widget _buildMascot() {
    return Container(
      width: 80, height: 80,
      decoration: BoxDecoration(
        gradient: AppTheme.lightGradient,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.3),
            blurRadius: 16,
          ),
        ],
      ),
      child: const Center(
        child: Text('🤖', style: TextStyle(fontSize: 40)),
      ),
    );
  }

  Widget _buildMascotSmall() {
    return Container(
      width: 28, height: 28,
      decoration: BoxDecoration(
        gradient: AppTheme.lightGradient,
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Text('🤖', style: TextStyle(fontSize: 14)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildMascot(),
          const SizedBox(height: 20),
          const Text(
            'Hi! I\'m your Chef AI 🍳',
            style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Ask me what to cook with what\'s in your fridge. '
              'I\'ll suggest recipes with macros!',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSuggestions() {
    final suggestions = [
      '🍽️ What for dinner?',
      '💪 High protein meal',
      '⏱️ Quick 15-min recipe',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: suggestions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return ActionChip(
            label: Text(suggestions[index]),
            backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.08),
            labelStyle: const TextStyle(
                color: AppTheme.primaryBlue, fontSize: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: AppTheme.primaryBlue.withValues(alpha: 0.2)),
            ),
            onPressed: () {
              _messageController.text = suggestions[index]
                  .replaceAll(RegExp(r'[^\w\s?]'), '').trim();
              _sendMessage();
            },
          );
        },
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.role == MessageRole.user;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            _buildMascotSmall(),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: isUser ? AppTheme.primaryGradient : null,
                color: isUser ? null : AppTheme.primaryBlue.withValues(alpha: 0.06),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  color: isUser ? Colors.white : AppTheme.textPrimary,
                  fontSize: 14, height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: 'Ask Chef AI...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppTheme.backgroundLight,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: const BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: _sendMessage,
                icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
