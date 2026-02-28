import 'package:flutter/material.dart';
import 'package:voyz/data/saved_trips_provider.dart';
import 'package:voyz/screens/splash_screen.dart';
import 'package:voyz/theme/app_theme.dart';

void main() {
  runApp(const VoyzApp());
}

class VoyzApp extends StatelessWidget {
  const VoyzApp({super.key});

  @override
  Widget build(BuildContext context) {
    return SavedTripsProvider(
      child: MaterialApp(
        title: 'AIVIVU - AI Travel Advisor',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme(),
        darkTheme: AppTheme.darkTheme(),
        themeMode: ThemeMode.dark,
        home: const SplashScreen(),
      ),
    );
  }
}
