import 'package:alamanah/l10n/app_localizations.dart';
import 'package:alamanah/mobile_pages/home_page.dart';
import 'package:alamanah/mobile_pages/language_switcher.dart';
import 'package:alamanah/mobile_pages/profile_page.dart';
import 'package:alamanah/mobile_pages/registration_page.dart';
import 'package:flutter/material.dart';

class NavigationPage extends StatefulWidget {
  final Function(Locale) onLocaleChange;

  const NavigationPage({super.key, required this.onLocaleChange});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  final PageController _pageController = PageController();

  int _currentIndex = 0;

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onNavTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Al Amanah'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      LanguageSwitcher(onLocaleChange: widget.onLocaleChange),
                ),
              );
            },
          ),
        ],
      ),
      // ✅ HAMBURGER MENU (LEFT)
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.green),
              child: Text(
                "Menu",
                style: TextStyle(color: Colors.white, fontSize: 22),
              ),
            ),

            // ➤ Registration page item
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text("Registration"),
              onTap: () {
                Navigator.pop(context); // close drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegistrationPage()),
                );
              },
            ),

            // ➤ Example: Change language
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text("Change Language"),
              onTap: () {
                Navigator.pop(context);
                _showLanguageDialog();
              },
            ),
          ],
        ),
      ),

      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: [
          // MyHomePage(title: "Home", onNavigate: _onNavTapped),
          // LinkItem(
          //   profileImageUrl: '',
          //   name: 'Luke Waashington Garces',
          //   company: 'Lenovo PCCW Inc',
          //   description: 'des',
          //   contentImageUrl: 'd',
          // ),
          HomePage(),
          ProfilePage(),
          LanguageSwitcher(onLocaleChange: widget.onLocaleChange),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onNavTapped,
        selectedItemColor: const Color.fromARGB(255, 3, 48, 13),
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: local.home),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: local.profile,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: local.settings,
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Select Language"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () {
                  widget.onLocaleChange(const Locale('en'));
                  Navigator.pop(context);
                },
                child: const Text("English"),
              ),
              TextButton(
                onPressed: () {
                  widget.onLocaleChange(const Locale('ar'));
                  Navigator.pop(context);
                },
                child: const Text("Arabic"),
              ),
            ],
          ),
        );
      },
    );
  }
}
