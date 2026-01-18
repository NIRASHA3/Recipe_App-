import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // This will be generated automatically
import 'core/theme/app_theme.dart';
import 'presentation/auth/get_started_screen.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const ProviderScope(child: TasteFitApp()));
}

class TasteFitApp extends StatelessWidget {
  const TasteFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TasteFit',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const GetStartedScreen(),
    );
  }
}