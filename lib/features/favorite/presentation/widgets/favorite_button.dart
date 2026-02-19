import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/favorite_provider.dart';

class FavoriteButton extends ConsumerWidget {
  const FavoriteButton({
    super.key,
    required this.mainItemId,
    this.sideItemId,
    this.drinkItemId,
  });

  final String mainItemId;
  final String? sideItemId;
  final String? drinkItemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavoriteAsync = ref.watch(
      isFavoriteProvider(
        mainItemId: mainItemId,
        sideItemId: sideItemId,
        drinkItemId: drinkItemId,
      ),
    );

    return isFavoriteAsync.when(
      data: (isFav) => _FavoriteIconButton(
        isFavorite: isFav,
        onPressed: () => _toggleFavorite(context, ref),
      ),
      loading: () => const _FavoriteIconButton(
        isFavorite: false,
        onPressed: null,
      ),
      error: (_, _) => const _FavoriteIconButton(
        isFavorite: false,
        onPressed: null,
      ),
    );
  }

  Future<void> _toggleFavorite(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(favoriteListProvider.notifier);
    await notifier.toggle(
      mainItemId: mainItemId,
      sideItemId: sideItemId,
      drinkItemId: drinkItemId,
    );

    // Check the new state to show appropriate message
    final isFavoriteAsync = await ref.read(
      isFavoriteProvider(
        mainItemId: mainItemId,
        sideItemId: sideItemId,
        drinkItemId: drinkItemId,
      ).future,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isFavoriteAsync
                ? '즐겨찾기에 추가했습니다'
                : '즐겨찾기에서 제거했습니다',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}

class _FavoriteIconButton extends StatefulWidget {
  const _FavoriteIconButton({
    required this.isFavorite,
    required this.onPressed,
  });

  final bool isFavorite;
  final VoidCallback? onPressed;

  @override
  State<_FavoriteIconButton> createState() => _FavoriteIconButtonState();
}

class _FavoriteIconButtonState extends State<_FavoriteIconButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounceController;
  late final Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(_FavoriteIconButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFavorite != widget.isFavorite && widget.isFavorite) {
      _bounceController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return IconButton(
      onPressed: widget.onPressed,
      icon: ScaleTransition(
        scale: _bounceAnimation,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            widget.isFavorite ? Icons.favorite : Icons.favorite_border,
            key: ValueKey(widget.isFavorite),
            color: widget.isFavorite
                ? Colors.red
                : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
