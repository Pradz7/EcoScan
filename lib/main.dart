import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'home_navigation.dart';
import 'detection_data.dart';
import 'auth_screen.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  cameras = await availableCameras();

  await loadDetectionHistory();

  runApp(const SmartTrashApp());
}

class SmartTrashApp extends StatelessWidget {
  const SmartTrashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Trash Detection',
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Arial',
      ),
      home: FirebaseAuth.instance.currentUser != null
    ? const HomeNavigation()
    : const AuthScreen(),
    );
  }
}