import 'package:flutter/material.dart';

/// App-wide localization support for 4 languages:
/// English, Malay (Bahasa Melayu), Chinese (中文), Tamil (தமிழ்)
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': _english,
    'ms': _malay,
    'zh': _chinese,
    'ta': _tamil,
  };

  String get(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']![key] ??
        key;
  }

  // ─── Shortcut getters for common strings ───────────────────

  // Navigation
  String get home => get('home');
  String get myFood => get('myFood');
  String get chefAi => get('chefAi');
  String get settings => get('settings');

  // Dashboard
  String get goodMorning => get('goodMorning');
  String get goodAfternoon => get('goodAfternoon');
  String get goodEvening => get('goodEvening');
  String get fridgeStatus => get('fridgeStatus');
  String get doorClosed => get('doorClosed');
  String get doorOpen => get('doorOpen');
  String get doorClosedDesc => get('doorClosedDesc');
  String get doorOpenDesc => get('doorOpenDesc');
  String get fridge => get('fridge');
  String get freezer => get('freezer');
  String get humidity => get('humidity');
  String get whatsInFridge => get('whatsInFridge');
  String get itemsDetected => get('itemsDetected');
  String get protein => get('protein');
  String get carbs => get('carbs');
  String get fats => get('fats');
  String get caloriesAvailable => get('caloriesAvailable');
  String get energyUsage => get('energyUsage');
  String get quickTipFull => get('quickTipFull');
  String get quickTipLow => get('quickTipLow');
  String get quickTipEmpty => get('quickTipEmpty');
  String get fridgeSubtitle => get('fridgeSubtitle');

  // Inventory
  String get myFridgeItems => get('myFridgeItems');
  String get searchFood => get('searchFood');
  String get all => get('all');
  String get noItemsFound => get('noItemsFound');
  String get tryDifferentSearch => get('tryDifferentSearch');
  String get itemsAfterScan => get('itemsAfterScan');
  String get nutrition => get('nutrition');
  String get detected => get('detected');
  String get scanFridge => get('scanFridge');
  String get scanning => get('scanning');

  // Chef AI
  String get chefAiTitle => get('chefAiTitle');
  String get chefAssistant => get('chefAssistant');
  String get chefAssistantDesc => get('chefAssistantDesc');
  String get askChefAi => get('askChefAi');
  String get chefThinking => get('chefThinking');
  String get clearChat => get('clearChat');
  String get whatForDinner => get('whatForDinner');
  String get highProtein => get('highProtein');
  String get quickRecipe => get('quickRecipe');

  // Settings
  String get notifications => get('notifications');
  String get enableNotifications => get('enableNotifications');
  String get doorAlerts => get('doorAlerts');
  String get expiryReminders => get('expiryReminders');
  String get weeklySummary => get('weeklySummary');
  String get language => get('language');
  String get appLanguage => get('appLanguage');
  String get chooseLanguage => get('chooseLanguage');
  String get appearance => get('appearance');
  String get theme => get('theme');
  String get light => get('light');
  String get dark => get('dark');
  String get system => get('system');
  String get units => get('units');
  String get temperatureUnit => get('temperatureUnit');
  String get about => get('about');
  String get appVersion => get('appVersion');
  String get helpSupport => get('helpSupport');
  String get privacyPolicy => get('privacyPolicy');

  // ═══════════════════════════════════════════════════════════
  // ENGLISH
  // ═══════════════════════════════════════════════════════════
  static const Map<String, String> _english = {
    // Navigation
    'home': 'Home',
    'myFood': 'My Food',
    'chefAi': 'Chef AI',
    'settings': 'Settings',

    // Dashboard
    'goodMorning': 'Good Morning',
    'goodAfternoon': 'Good Afternoon',
    'goodEvening': 'Good Evening',
    'fridgeStatus': 'Fridge Status',
    'doorClosed': 'Door is Closed',
    'doorOpen': 'Door is Open',
    'doorClosedDesc': 'Everything is secure ✓',
    'doorOpenDesc': 'Camera will scan when you close it',
    'fridge': 'Fridge',
    'freezer': 'Freezer',
    'humidity': 'Humidity',
    'whatsInFridge': "What's in Your Fridge",
    'itemsDetected': 'items detected',
    'protein': 'Protein',
    'carbs': 'Carbs',
    'fats': 'Fats',
    'caloriesAvailable': 'calories available',
    'energyUsage': 'Energy Usage',
    'quickTipFull': 'You have plenty of ingredients! Ask Chef AI for a recipe idea.',
    'quickTipLow': 'Running low on items. Consider restocking soon.',
    'quickTipEmpty': 'Your fridge is empty. Items will appear after the next scan.',
    'fridgeSubtitle': "Here's what's happening with your fridge today.",

    // Inventory
    'myFridgeItems': 'My Fridge Items',
    'searchFood': 'Search for food...',
    'all': 'All',
    'noItemsFound': 'No items found',
    'tryDifferentSearch': 'Try a different search',
    'itemsAfterScan': 'Items appear after your fridge is scanned',
    'nutrition': 'Nutrition',
    'detected': 'Detected',
    'scanFridge': 'Scan Fridge',
    'scanning': 'Scanning your fridge...',

    // Chef AI
    'chefAiTitle': 'Chef AI',
    'chefAssistant': 'Your AI Chef Assistant',
    'chefAssistantDesc': "Ask me what to cook based on what's in your fridge. I can suggest recipes, calculate macros, and more!",
    'askChefAi': 'Ask your Chef AI...',
    'chefThinking': 'Chef is thinking...',
    'clearChat': 'Clear chat',
    'whatForDinner': 'What can I make for dinner?',
    'highProtein': 'High protein meal',
    'quickRecipe': 'Quick 15-min recipe',

    // Settings
    'notifications': 'Notifications',
    'enableNotifications': 'Enable Notifications',
    'doorAlerts': 'Door Open Alerts',
    'expiryReminders': 'Expiry Reminders',
    'weeklySummary': 'Weekly Summary',
    'language': 'Language',
    'appLanguage': 'App Language',
    'chooseLanguage': 'Choose your preferred language',
    'appearance': 'Appearance',
    'theme': 'Theme',
    'light': 'Light',
    'dark': 'Dark',
    'system': 'System',
    'units': 'Units',
    'temperatureUnit': 'Temperature Unit',
    'about': 'About',
    'appVersion': 'App Version',
    'helpSupport': 'Help & Support',
    'privacyPolicy': 'Privacy Policy',
  };

  // ═══════════════════════════════════════════════════════════
  // MALAY (Bahasa Melayu)
  // ═══════════════════════════════════════════════════════════
  static const Map<String, String> _malay = {
    'home': 'Utama',
    'myFood': 'Makanan Saya',
    'chefAi': 'Chef AI',
    'settings': 'Tetapan',

    'goodMorning': 'Selamat Pagi',
    'goodAfternoon': 'Selamat Tengah Hari',
    'goodEvening': 'Selamat Petang',
    'fridgeStatus': 'Status Peti Sejuk',
    'doorClosed': 'Pintu Tertutup',
    'doorOpen': 'Pintu Terbuka',
    'doorClosedDesc': 'Semuanya selamat ✓',
    'doorOpenDesc': 'Kamera akan mengimbas apabila anda menutupnya',
    'fridge': 'Peti Sejuk',
    'freezer': 'Peti Beku',
    'humidity': 'Kelembapan',
    'whatsInFridge': 'Apa dalam Peti Sejuk',
    'itemsDetected': 'item dikesan',
    'protein': 'Protein',
    'carbs': 'Karbohidrat',
    'fats': 'Lemak',
    'caloriesAvailable': 'kalori tersedia',
    'energyUsage': 'Penggunaan Tenaga',
    'quickTipFull': 'Anda mempunyai banyak bahan! Tanya Chef AI untuk idea resipi.',
    'quickTipLow': 'Bahan semakin berkurangan. Pertimbangkan untuk membeli stok.',
    'quickTipEmpty': 'Peti sejuk kosong. Item akan muncul selepas imbasan.',
    'fridgeSubtitle': 'Ini apa yang berlaku dengan peti sejuk anda hari ini.',

    'myFridgeItems': 'Item Peti Sejuk Saya',
    'searchFood': 'Cari makanan...',
    'all': 'Semua',
    'noItemsFound': 'Tiada item dijumpai',
    'tryDifferentSearch': 'Cuba carian lain',
    'itemsAfterScan': 'Item akan muncul selepas peti sejuk diimbas',
    'nutrition': 'Nutrisi',
    'detected': 'Dikesan',
    'scanFridge': 'Imbas Peti Sejuk',
    'scanning': 'Mengimbas peti sejuk anda...',

    'chefAiTitle': 'Chef AI',
    'chefAssistant': 'Pembantu Chef AI Anda',
    'chefAssistantDesc': 'Tanya saya apa yang boleh dimasak berdasarkan apa yang ada dalam peti sejuk anda.',
    'askChefAi': 'Tanya Chef AI anda...',
    'chefThinking': 'Chef sedang berfikir...',
    'clearChat': 'Padam sembang',
    'whatForDinner': 'Apa boleh masak untuk makan malam?',
    'highProtein': 'Makanan tinggi protein',
    'quickRecipe': 'Resipi 15 minit',

    'notifications': 'Pemberitahuan',
    'enableNotifications': 'Aktifkan Pemberitahuan',
    'doorAlerts': 'Amaran Pintu Terbuka',
    'expiryReminders': 'Peringatan Tamat Tempoh',
    'weeklySummary': 'Ringkasan Mingguan',
    'language': 'Bahasa',
    'appLanguage': 'Bahasa Aplikasi',
    'chooseLanguage': 'Pilih bahasa pilihan anda',
    'appearance': 'Penampilan',
    'theme': 'Tema',
    'light': 'Cerah',
    'dark': 'Gelap',
    'system': 'Sistem',
    'units': 'Unit',
    'temperatureUnit': 'Unit Suhu',
    'about': 'Tentang',
    'appVersion': 'Versi Aplikasi',
    'helpSupport': 'Bantuan & Sokongan',
    'privacyPolicy': 'Dasar Privasi',
  };

  // ═══════════════════════════════════════════════════════════
  // CHINESE (中文)
  // ═══════════════════════════════════════════════════════════
  static const Map<String, String> _chinese = {
    'home': '首页',
    'myFood': '我的食物',
    'chefAi': 'AI厨师',
    'settings': '设置',

    'goodMorning': '早上好',
    'goodAfternoon': '下午好',
    'goodEvening': '晚上好',
    'fridgeStatus': '冰箱状态',
    'doorClosed': '门已关闭',
    'doorOpen': '门已打开',
    'doorClosedDesc': '一切正常 ✓',
    'doorOpenDesc': '关门时摄像头将自动扫描',
    'fridge': '冷藏',
    'freezer': '冷冻',
    'humidity': '湿度',
    'whatsInFridge': '冰箱里有什么',
    'itemsDetected': '件物品已检测',
    'protein': '蛋白质',
    'carbs': '碳水',
    'fats': '脂肪',
    'caloriesAvailable': '卡路里可用',
    'energyUsage': '能源使用',
    'quickTipFull': '您有充足的食材！问问AI厨师要做什么菜。',
    'quickTipLow': '食材不多了，考虑补充一下。',
    'quickTipEmpty': '冰箱是空的。扫描后将显示物品。',
    'fridgeSubtitle': '这是您冰箱今天的情况。',

    'myFridgeItems': '我的冰箱物品',
    'searchFood': '搜索食物...',
    'all': '全部',
    'noItemsFound': '未找到物品',
    'tryDifferentSearch': '试试其他搜索词',
    'itemsAfterScan': '扫描冰箱后物品将显示',
    'nutrition': '营养信息',
    'detected': '检测时间',
    'scanFridge': '扫描冰箱',
    'scanning': '正在扫描您的冰箱...',

    'chefAiTitle': 'AI厨师',
    'chefAssistant': '您的AI厨师助手',
    'chefAssistantDesc': '问我根据冰箱里的食材能做什么菜。我可以推荐食谱、计算营养等！',
    'askChefAi': '问问AI厨师...',
    'chefThinking': '厨师正在思考...',
    'clearChat': '清除聊天',
    'whatForDinner': '晚餐做什么好？',
    'highProtein': '高蛋白餐',
    'quickRecipe': '15分钟快速食谱',

    'notifications': '通知',
    'enableNotifications': '开启通知',
    'doorAlerts': '开门提醒',
    'expiryReminders': '过期提醒',
    'weeklySummary': '每周总结',
    'language': '语言',
    'appLanguage': '应用语言',
    'chooseLanguage': '选择您喜欢的语言',
    'appearance': '外观',
    'theme': '主题',
    'light': '浅色',
    'dark': '深色',
    'system': '跟随系统',
    'units': '单位',
    'temperatureUnit': '温度单位',
    'about': '关于',
    'appVersion': '应用版本',
    'helpSupport': '帮助与支持',
    'privacyPolicy': '隐私政策',
  };

  // ═══════════════════════════════════════════════════════════
  // TAMIL (தமிழ்)
  // ═══════════════════════════════════════════════════════════
  static const Map<String, String> _tamil = {
    'home': 'முகப்பு',
    'myFood': 'என் உணவு',
    'chefAi': 'AI சமையல்',
    'settings': 'அமைப்புகள்',

    'goodMorning': 'காலை வணக்கம்',
    'goodAfternoon': 'மதிய வணக்கம்',
    'goodEvening': 'மாலை வணக்கம்',
    'fridgeStatus': 'குளிர்சாதன நிலை',
    'doorClosed': 'கதவு மூடப்பட்டது',
    'doorOpen': 'கதவு திறந்துள்ளது',
    'doorClosedDesc': 'எல்லாம் பாதுகாப்பாக உள்ளது ✓',
    'doorOpenDesc': 'நீங்கள் மூடும்போது கேமரா ஸ்கேன் செய்யும்',
    'fridge': 'குளிர்சாதனம்',
    'freezer': 'உறைவிப்பான்',
    'humidity': 'ஈரப்பதம்',
    'whatsInFridge': 'குளிர்சாதனத்தில் என்ன உள்ளது',
    'itemsDetected': 'பொருட்கள் கண்டறியப்பட்டன',
    'protein': 'புரதம்',
    'carbs': 'மாவுச்சத்து',
    'fats': 'கொழுப்பு',
    'caloriesAvailable': 'கலோரிகள் கிடைக்கும்',
    'energyUsage': 'மின் பயன்பாடு',
    'quickTipFull': 'உங்களிடம் நிறைய பொருட்கள் உள்ளன! AI சமையலிடம் யோசனை கேளுங்கள்.',
    'quickTipLow': 'பொருட்கள் குறைவாக உள்ளன. விரைவில் நிரப்புங்கள்.',
    'quickTipEmpty': 'குளிர்சாதனம் காலியாக உள்ளது. ஸ்கேன் செய்த பிறகு பொருட்கள் தோன்றும்.',
    'fridgeSubtitle': 'இன்று உங்கள் குளிர்சாதனத்தின் நிலை இதோ.',

    'myFridgeItems': 'என் குளிர்சாதன பொருட்கள்',
    'searchFood': 'உணவைத் தேடு...',
    'all': 'அனைத்தும்',
    'noItemsFound': 'பொருட்கள் இல்லை',
    'tryDifferentSearch': 'வேறு தேடலை முயற்சிக்கவும்',
    'itemsAfterScan': 'ஸ்கேன் செய்த பிறகு பொருட்கள் தோன்றும்',
    'nutrition': 'ஊட்டச்சத்து',
    'detected': 'கண்டறியப்பட்டது',
    'scanFridge': 'ஸ்கேன் செய்',
    'scanning': 'உங்கள் குளிர்சாதனத்தை ஸ்கேன் செய்கிறது...',

    'chefAiTitle': 'AI சமையல்',
    'chefAssistant': 'உங்கள் AI சமையல் உதவியாளர்',
    'chefAssistantDesc': 'உங்கள் குளிர்சாதனத்தில் உள்ளவற்றை வைத்து என்ன சமைக்கலாம் என்று கேளுங்கள்.',
    'askChefAi': 'AI சமையலிடம் கேளுங்கள்...',
    'chefThinking': 'சமையல் யோசிக்கிறது...',
    'clearChat': 'அரட்டையை அழி',
    'whatForDinner': 'இரவு உணவுக்கு என்ன செய்யலாம்?',
    'highProtein': 'அதிக புரத உணவு',
    'quickRecipe': '15 நிமிட சமையல்',

    'notifications': 'அறிவிப்புகள்',
    'enableNotifications': 'அறிவிப்புகளை இயக்கு',
    'doorAlerts': 'கதவு திறப்பு எச்சரிக்கை',
    'expiryReminders': 'காலாவதி நினைவூட்டல்',
    'weeklySummary': 'வாரச் சுருக்கம்',
    'language': 'மொழி',
    'appLanguage': 'செயலி மொழி',
    'chooseLanguage': 'உங்கள் விருப்ப மொழியைத் தேர்ந்தெடுக்கவும்',
    'appearance': 'தோற்றம்',
    'theme': 'தீம்',
    'light': 'வெளிர்',
    'dark': 'இருண்ட',
    'system': 'கணினி',
    'units': 'அலகுகள்',
    'temperatureUnit': 'வெப்பநிலை அலகு',
    'about': 'பற்றி',
    'appVersion': 'செயலி பதிப்பு',
    'helpSupport': 'உதவி & ஆதரவு',
    'privacyPolicy': 'தனியுரிமை கொள்கை',
  };
}

// ═══════════════════════════════════════════════════════════
// LOCALIZATION DELEGATE
// ═══════════════════════════════════════════════════════════

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  static const supportedLocales = [
    Locale('en'),
    Locale('ms'),
    Locale('zh'),
    Locale('ta'),
  ];

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ms', 'zh', 'ta'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) {
    return false;
  }
}
