import 'package:alamanah/l10n/app_localizations.dart';
import 'package:alamanah/mobile_pages/home_page.dart';
import 'package:alamanah/mobile_pages/language_switcher.dart';
import 'package:alamanah/mobile_pages/login_page.dart';
import 'package:alamanah/mobile_pages/profile_page.dart';
import 'package:alamanah/mobile_pages/registration_page.dart';
import 'package:alamanah/utills/utillities.dart';
import 'package:flutter/material.dart';

class NavigationPage extends StatefulWidget {
  final Function(Locale) onLocaleChange;

  const NavigationPage({super.key, required this.onLocaleChange});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  final PageController _pageController = PageController();
  late bool isLoggedIn = false;

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadLoginStatus();
  }

  void _loadLoginStatus() async {
    bool logged = await Utillities.isLoggedIn();
    setState(() {
      isLoggedIn = logged;
    });
  }

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
                  builder: (context) => LanguageSwitcher(
                    onLocaleChange: widget.onLocaleChange,
                    navigationTabClick: false,
                  ),
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
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/app_bg.jpg"),
                  fit: BoxFit.cover, // covers entire drawer header
                ),
              ),
              child: Text(
                "",
                style: TextStyle(color: Colors.white, fontSize: 22),
              ),
            ),

            if (!isLoggedIn)
              // ➤ Example: Change language
              ListTile(
                leading: const Icon(Icons.login),
                title: const Text("Login"),
                onTap: () async {
                  Navigator.pop(context); // close drawer
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );

                  if (result == true) {
                    setState(() {
                      isLoggedIn = true; // <— hide Login ListTile
                    });
                  }
                },
              ),

            if (isLoggedIn)
              // ➤ Example: Change language
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text("Logout"),
                onTap: () async {
                  Navigator.pop(context);
                  _showLogoutDialog();
                },
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
          LanguageSwitcher(
            onLocaleChange: widget.onLocaleChange,
            navigationTabClick: true,
          ),
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

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                await Utillities.logout(); // remove saved login data
                setState(() {
                  isLoggedIn = false;
                });

                Navigator.pop(context); // close dialog

                // Optional: message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Logged out successfully")),
                );
              },
              child: const Text("Logout", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
