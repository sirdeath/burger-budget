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
      title: 'buzit',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: showOnboarding
          ? const OnboardingScreen()
          : const _SplashFadeIn(child: AppShell()),
      debugShowCheckedModeBanner: false,
    );
  }
}

class _SplashFadeIn extends StatefulWidget {
  const _SplashFadeIn({required this.child});

  final Widget child;

  @override
  State<_SplashFadeIn> createState() => _SplashFadeInState();
}

class _SplashFadeInState extends State<_SplashFadeIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _opacity = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: widget.child,
    );
  }
}
