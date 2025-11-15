import 'package:alamanah/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class LanguageSwitcher extends StatelessWidget {
  final Function(Locale) onLocaleChange;

  const LanguageSwitcher({super.key, required this.onLocaleChange});

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(local.welcome)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(local.hello),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => onLocaleChange(const Locale('en')),
              child: const Text('English'),
            ),
            ElevatedButton(
              onPressed: () => onLocaleChange(const Locale('ar')),
              child: const Text('العربية'),
            ),
          ],
        ),
      ),
    );
  }
}
