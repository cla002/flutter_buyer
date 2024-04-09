// ignore_for_file: use_build_context_synchronously
import 'package:buyers/screens/splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> logout(BuildContext context) async {
  bool confirmed = await _showLogoutConfirmationDialog(context);

  if (confirmed) {
    try {
      await FirebaseAuth.instance.signOut();
      SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.remove('isLoggedIn');
      print('User signed out successfully');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const SplashScreen(),
        ),
      );
    } catch (e) {
      print('Error during logout: $e');
    }
  }
}

Future<bool> _showLogoutConfirmationDialog(BuildContext context) async {
  return await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are You Sure You Want to Logout?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              print('cancel is clicked');
              Navigator.of(context).pop(false);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              print('logout is clicked');
              await FirebaseAuth.instance.signOut();
              Navigator.pushNamed(context, SplashScreen.id);
            },
            child: const Text('Logout'),
          ),
        ],
      );
    },
  );
}
