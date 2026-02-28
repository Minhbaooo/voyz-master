import 'package:flutter/material.dart';
import 'package:voyz/data/mock_data.dart';
import 'package:voyz/screens/smart_planner_screen.dart';
import 'package:voyz/theme/app_theme.dart';

/// Splash screen — full-screen black with gradient "AIVIVU" logo text.
///
/// Auto-navigates to the Smart Planner after 2.5 seconds.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    Future.delayed(const Duration(milliseconds: 2500), _navigateNext);
  }

  void _navigateNext() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (c, a1, a2) => const SmartPlannerScreen(),
        transitionsBuilder: (c2, anim, a3, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FadeTransition(
        opacity: _fadeIn,
        child: SizedBox.expand(
          child: Column(
            children: [
              const Spacer(),
              // ── Logo ──
              ShaderMask(
                shaderCallback: (bounds) =>
                    AppTheme.splashTextGradient.createShader(bounds),
                child: Text(
                  MockData.appName,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 64,
                    letterSpacing: -1,
                    color: Colors.white, // masked by shader
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // ── Subtitle ──
              Text(
                MockData.splashSubtitle.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 3,
                  color: Colors.white.withValues(alpha: 0.35),
                ),
              ),
              const Spacer(),
              // ── Dots ──
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  return Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.15 + (i * 0.08)),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 40),
              // ── Version ──
              Text(
                MockData.appVersion.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 4,
                  color: Colors.white.withValues(alpha: 0.15),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
