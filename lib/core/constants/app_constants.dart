class AppConstants {
  AppConstants._();

  static const String appName = '버짓';

  // DB
  static const String seedDbAssetPath = 'assets/menu_seed.db';
  static const String dbFileName = 'menu.db';
  static const String seedDbVersion = '1.1';
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
    'lot': 'https://www.lotteeatz.com/brand/ria',
  };

  // 시그니처/인기 메뉴 키워드 (메뉴명에 포함되면 인기순에서 상위 노출)
  static const Map<String, List<String>> signatureMenus = {
    'mcd': [
      '빅맥',
      '1955',
      '맥치킨',
      '쿼터파운더',
      '맥스파이시',
      '불고기',
      '맥너겟',
      '해피밀',
    ],
    'bk': [
      '와퍼',
      '콰트로',
      '몬스터',
      '통새우',
      '불고기',
      '스태커',
    ],
    'kfc': [
      '징거',
      '타워',
      '오리지널',
      '핫크리스피',
      '갓양념',
      '켄터키',
    ],
    'mom': [
      '싸이버거',
      '불싸이',
      '치즈싸이',
      '언빌리버블',
      '딥치즈',
      '후라이드',
    ],
    'lot': [
      '불고기',
      '데리',
      '한우',
      '새우',
      '리아치즈',
      '양념치킨',
    ],
  };

  /// franchise 코드와 메뉴명으로 시그니처 여부 판단
  static bool isSignatureMenu(String franchise, String name) {
    final keywords = signatureMenus[franchise] ?? [];
    return keywords.any((k) => name.contains(k));
  }

  // Budget limits
  static const int minBudget = 1000;
  static const int maxBudget = 100000;
  static const List<int> budgetPresets = [
    5000,
    10000,
    15000,
    20000,
    30000,
  ];
  static const int maxRecommendations = 5;
}
