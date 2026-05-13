import 'dart:math';
import 'package:flutter/material.dart';

// note: This model stores one AI prediction result.
class AiDetectionResult {
  final String objectName;
  final String category;
  final String confidence;
  final IconData icon;
  final Color color;

  AiDetectionResult({
    required this.objectName,
    required this.category,
    required this.confidence,
    required this.icon,
    required this.color,
  });
}

// note: This service will later connect to the real Roboflow/TFLite model.
class AiDetectionService {
  final List<AiDetectionResult> fakeResults = [
    AiDetectionResult(
      objectName: "Banana Peel",
      category: "BIODEGRADABLE",
      confidence: "95%",
      icon: Icons.eco,
      color: Colors.lightGreen,
    ),
    AiDetectionResult(
      objectName: "Cardboard Box",
      category: "CARDBOARD",
      confidence: "89%",
      icon: Icons.inventory,
      color: Colors.brown,
    ),
    AiDetectionResult(
      objectName: "Glass Bottle",
      category: "GLASS",
      confidence: "91%",
      icon: Icons.wine_bar,
      color: Colors.orange,
    ),
    AiDetectionResult(
      objectName: "Soda Can",
      category: "METAL",
      confidence: "93%",
      icon: Icons.inventory_2,
      color: Colors.blueGrey,
    ),
    AiDetectionResult(
      objectName: "Paper Cup",
      category: "PAPER",
      confidence: "90%",
      icon: Icons.article,
      color: Colors.teal,
    ),
    AiDetectionResult(
      objectName: "Plastic Bottle",
      category: "PLASTIC",
      confidence: "98%",
      icon: Icons.local_drink,
      color: Colors.deepPurple,
    ),
  ];

  // note: This fake detection will be replaced by real AI model prediction later.
  Future<AiDetectionResult> detectTrash() async {
    await Future.delayed(const Duration(seconds: 2));

    final random = Random();
    return fakeResults[random.nextInt(fakeResults.length)];
  }
}