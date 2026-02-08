import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_constants.dart';

class FindStoreButton extends StatelessWidget {
  const FindStoreButton({
    super.key,
    required this.franchiseCode,
  });

  final String franchiseCode;

  Future<void> _openMaps() async {
    final query = AppConstants.franchiseSearchQueries[franchiseCode] ??
        '${AppConstants.franchiseNames[franchiseCode]} 근처';
    final encoded = Uri.encodeComponent(query);
    final url = Uri.parse('https://www.google.com/maps/search/$encoded');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: _openMaps,
      icon: const Icon(Icons.location_on_outlined),
      label: const Text('주변 매장 찾기'),
    );
  }
}
