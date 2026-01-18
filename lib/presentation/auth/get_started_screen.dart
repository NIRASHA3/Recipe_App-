import 'package:flutter/material.dart';
import '../../core/widgets/primary_button.dart';
import 'login_screen.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png',
              height: 300,
            ),
            const SizedBox(height: 24),
            const Text(
              "Recipes that love your health back",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1C1C1C),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Discover delicious and nutritious recipes tailored to your dietary preferences. From healthy meal plans to quick cooking tips, TasteFit helps you maintain a balanced lifestyle while enjoying every bite.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF6F6F6F),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            PrimaryButton(
              text: "Get Started",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
