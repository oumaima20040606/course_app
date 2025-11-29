import 'package:flutter/material.dart';
import 'package:course_app/constants/color.dart';

import 'package:course_app/pages/auth/login_screen.dart';
import 'package:course_app/pages/auth/register_screen.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFF4B8B),
      body: SafeArea(
        child: SizedBox.expand(
          child: Stack(
            children: [
              // Partie supérieure (fond rose avec logo + MyCourse)
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 80.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 92,
                        width: 92,
                        child: Image.asset(
                          'assets/icons/graduation.jpg',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'MyCourse',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.4,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Online Learning',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                              letterSpacing: 1.1,
                            ),
                      ),
                    ],
                  ),
                ),
              ),

              // Partie inférieure noire avec forme ondulée
              Align(
                alignment: Alignment.bottomCenter,
                child: ClipPath(
                  clipper: _BottomWaveClipper(),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.55,
                    width: double.infinity,
                    color: const Color(0xFF111827),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 32),
                    child: _welcomePanelContent(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // <----------------- Widgets ----------------->
  Widget _welcomePanel() {
    return Container();
  }

  Widget _welcomePanelContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Create an account to join MyCourse',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: _register('Create Account'),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: _login('Login'),
        ),
      ],
    );
  }

  // button widget
  Widget _login(String signIn) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFFFF4B8B),
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40.0),
        ),
        minimumSize: Size(170, 70),
      ),
      onPressed: () {
        showModalBottomSheet<void>(
          isScrollControlled: true,
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(45),
              topRight: Radius.circular(45),
            ),
          ),
          builder: (BuildContext context) {
            return const LoginScreen();
          },
        );
      },
      child: Text(signIn),
    );
  }

  // register widget
  Widget _register(String signUp) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.circular(40.0),
        ),
        minimumSize: Size(170, 70),
      ),
      onPressed: () {
        showModalBottomSheet<void>(
          isScrollControlled: true,
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(45),
              topRight: Radius.circular(45),
            ),
          ),
          builder: (BuildContext context) {
            return const RegisterScreen();
          },
        );
      },
      child: Text(
        signUp,
        style: const TextStyle(color: Colors.grey),
      ),
    );
  }
}

class _BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.3);

    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.05,
      size.width * 0.5,
      size.height * 0.15,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.25,
      size.width,
      size.height * 0.1,
    );

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}