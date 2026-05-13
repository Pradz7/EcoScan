import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'home_navigation.dart';
import 'detection_data.dart';

// note: This list stores available phone cameras.
List<CameraDescription> cameras = [];

// note: This is the main entry point of the app.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  cameras = await availableCameras();

  // note: This loads saved detection history before the app starts.
  await loadDetectionHistory();

  runApp(const SmartTrashApp());
}

// note: This class controls the whole application theme and first screen.
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
      home: const HomeNavigation(),
    );
  }
}