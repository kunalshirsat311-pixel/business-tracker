import 'package:flutter/material.dart';
import 'product_setup_screen.dart';
import 'daily_entry_screen.dart';
import 'database_helper.dart';

void main() {
  runApp(const NatureTouchApp());
}

class NatureTouchApp extends StatelessWidget {
  const NatureTouchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Business Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF1B4332),
        fontFamily: 'Arial',
      ),
      home: const SplashRouter(),
    );
  }
}

// SplashRouter checks the database on startup
// and decides which screen to show
class SplashRouter extends StatefulWidget {
  const SplashRouter({super.key});

  @override
  State<SplashRouter> createState() => _SplashRouterState();
}

class _SplashRouterState extends State<SplashRouter> {
  @override
  void initState() {
    super.initState();
    _checkAndRoute();
  }

  // Check if products exist in database
  // If yes — go to Daily Entry
  // If no — go to Product Setup (onboarding)
  Future<void> _checkAndRoute() async {
    final hasProducts = await DatabaseHelper.instance.hasProducts();

    if (!mounted) return;

    if (hasProducts) {
      final products = await DatabaseHelper.instance.getAllProducts();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DailyEntryScreen(products: products),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ProductSetupScreen(),
        ),
      );
    }
  }

  // Show a simple loading screen while checking
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF1B4332),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Business Tracker',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            CircularProgressIndicator(
              color: Color(0xFF52B788),
            ),
          ],
        ),
      ),
    );
  }
}