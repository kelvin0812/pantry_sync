import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/supabase_config.dart';
import 'providers/inventory_provider.dart';
import 'providers/fridge_provider.dart';
import 'providers/chat_provider.dart';
import 'screens/home_screen.dart';
import 'services/supabase_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase (or mock mode if not configured)
  final supabaseService = SupabaseService();
  if (SupabaseConfig.useMockData) {
    await supabaseService.initializeMock();
  } else {
    await supabaseService.initialize(
      supabaseUrl: SupabaseConfig.url,
      supabaseAnonKey: SupabaseConfig.anonKey,
    );
  }

  runApp(const PantrySyncApp());
}

class PantrySyncApp extends StatelessWidget {
  const PantrySyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => InventoryProvider()..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => FridgeProvider()..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => ChatProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Pantry Sync',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
      ),
    );
  }
}
