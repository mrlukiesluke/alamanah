import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Utillities {
  static Future<String> getSavedUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username =
        prefs.getString('username') ?? ''; // returns '' if no value
    return username;
  }

  static Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool username =
        prefs.getBool('isLoggedIn') ?? false; // returns false if no value
    return username;
  }

  static Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    await prefs.remove('password');
    await prefs.setBool('isLoggedIn', false);
  }

  static Future<void> showSavedUsername(BuildContext context) async {
    String username = await getSavedUsername();
    print('Saved Username: $username');

    // Display in a snackbar
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Username: $username')));
  }
}
