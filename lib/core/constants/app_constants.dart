class AppConstants {
  AppConstants._();

  static const String appName = '버짓';

  // DB
  static const String seedDbAssetPath = 'assets/menu_seed.db';
  static const String dbFileName = 'menu.db';
  static const String tempDbFileName = 'menu_new.db';
  static const String dbVersionKey = 'db_version';

  // Remote manifest
  static const String manifestUrl =
      'https://sirdeath.github.io/burger-budget/manifest.json';

  // Franchise codes
  static const Map<String, String> franchiseNames = {
    'mcd': "McDonald's",
    'bk': 'Burger King',
    'kfc': 'KFC',
    'mom': "Mom's Touch",
    'lot': 'Lotteria',
  };

  static const List<String> franchiseCodes = [
    'mcd',
    'bk',
    'kfc',
    'mom',
    'lot',
  ];

  static const Map<String, String> franchiseEmojis = {
    'mcd': '\u{1F35F}',
    'bk': '\u{1F354}',
    'kfc': '\u{1F357}',
    'mom': '\u{1F414}',
    'lot': '\u{1F32D}',
  };

  // Google Maps search queries per franchise
  static const Map<String, String> franchiseSearchQueries = {
    'mcd': '맥도날드 근처',
    'bk': '버거킹 근처',
    'kfc': 'KFC 근처',
    'mom': '맘스터치 근처',
    'lot': '롯데리아 근처',
  };

  // Franchise official URLs (ordering / coupon pages)
  static const Map<String, String> franchiseUrls = {
    'mcd': 'https://www.mcdonalds.co.kr',
    'bk': 'https://www.burgerking.co.kr',
    'kfc': 'https://www.kfckorea.com',
    'mom': 'https://www.momstouch.co.kr',
    'lot': 'https://www.lotteeatz.com/brand/LT',
  };

  // Budget limits
  static const int minBudget = 1000;
  static const int maxBudget = 100000;
  static const int sliderMaxBudget = 50000;
  static const int sliderStep = 1000;
  static const List<int> budgetPresets = [5000, 8000, 10000, 15000, 20000];
  static const int maxRecommendations = 5;
}
