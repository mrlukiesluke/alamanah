import 'package:alamanah/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class LanguageSwitcher extends StatefulWidget {
  final Function(Locale) onLocaleChange;
  final bool navigationTabClick;

  const LanguageSwitcher({
    super.key,
    required this.onLocaleChange,
    required this.navigationTabClick,
  });

  @override
  State<LanguageSwitcher> createState() => _LanguageSwitcherState();
}

class _LanguageSwitcherState extends State<LanguageSwitcher> {
  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: widget.navigationTabClick
          ? null
          : AppBar(
              leading: IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text("Language Settings"),
            ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(local.welcome),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => widget.onLocaleChange(const Locale('en')),
              child: const Text('English'),
            ),
            ElevatedButton(
              onPressed: () => widget.onLocaleChange(const Locale('ar')),
              child: const Text('العربية'),
            ),
          ],
        ),
      ),
    );
  }
}
