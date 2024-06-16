import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'home_screen.dart';

class SplashAnimated extends StatelessWidget {
  const SplashAnimated({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
        splashIconSize: 300,
        backgroundColor: Colors.white,
        pageTransitionType: PageTransitionType.topToBottom,
        splashTransition: SplashTransition.rotationTransition,
        splash: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          "assets/images/logo.png",
          width: 300,
          height: 300,
          fit: BoxFit.contain,
        ),
      ),
        nextScreen: HomeScreen(),
        duration: 2000,
        animationDuration: const Duration(seconds: 5));
  }
}