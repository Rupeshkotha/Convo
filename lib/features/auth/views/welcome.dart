import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Convo/features/auth/views/login.dart';
import 'package:Convo/theme/theme.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  void _navigateToLoginPage(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (builder) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorTheme = Theme.of(context).custom.colorTheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness:
              Theme.of(context).brightness == Brightness.dark
                  ? Brightness.light
                  : Brightness.dark,
          systemNavigationBarColor: colorTheme.navigationBarColor,
        ),
        actions: [
          Icon(
            Icons.more_vert_rounded,
            color: colorTheme.greyColor,
          ),
          const SizedBox(width: 16)
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.1),
            // Add your image here
            Image.asset(
              'assets/images/landing_img.png',
              width: MediaQuery.of(context).size.width * 0.9,
            ),
            const SizedBox(height: 32),
            const Text(
              'Convo',
              style: TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.bold,
                color: Colors.orange, // Match the orange button color
                fontFamily: 'Pacifico', // Fancy text font
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 48.0),
              child: Text(
                'Welcome to Convo - A platform for meaningful conversations.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.orange, // Match the orange button color
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 52,
                vertical: 25,
              ),
              child: ElevatedButton(
                onPressed: () => _navigateToLoginPage(context),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.orange),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Match the button text color
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
