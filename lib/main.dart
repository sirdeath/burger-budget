import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/app_shell/presentation/screens/app_shell.dart';
import 'features/onboarding/presentation/screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final hasSeenOnboarding =
      prefs.getBool('has_seen_onboarding') ?? false;

  runApp(
    ProviderScope(
      child: BurgerBudgetApp(showOnboarding: !hasSeenOnboarding),
    ),
  );
}

class BurgerBudgetApp extends ConsumerWidget {
  const BurgerBudgetApp({super.key, this.showOnboarding = false});

  final bool showOnboarding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Burger Budget',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: showOnboarding
          ? const OnboardingScreen()
          : const AppShell(),
      debugShowCheckedModeBanner: false,
    );
  }
}
