import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'config/supabase_config.dart';
import 'l10n/app_localizations.dart';
import 'providers/inventory_provider.dart';
import 'providers/fridge_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/locale_provider.dart';
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

  // Load saved language preference
  final localeProvider = LocaleProvider();
  await localeProvider.loadSavedLocale();

  runApp(PantrySyncApp(localeProvider: localeProvider));
}

class PantrySyncApp extends StatelessWidget {
  final LocaleProvider localeProvider;

  const PantrySyncApp({super.key, required this.localeProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: localeProvider),
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
      child: Consumer<LocaleProvider>(
        builder: (context, locale, _) {
          return MaterialApp(
            title: 'Pantry Sync',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,

            // Localization
            locale: locale.locale,
            supportedLocales: const [
              Locale('en'),
              Locale('ms'),
              Locale('zh'),
              Locale('ta'),
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],

            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
