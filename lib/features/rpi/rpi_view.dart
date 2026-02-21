import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class RpiView extends StatelessWidget {
  const RpiView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.rpiTab),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Center(child: Text(l10n.systemResources)),
    );
  }
}
