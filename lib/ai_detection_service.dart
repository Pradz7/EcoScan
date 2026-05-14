import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'roboflow_config.dart';

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

class AiDetectionService {
  Future<AiDetectionResult> detectTrash(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final uri = Uri.parse(
        "https://detect.roboflow.com/${RoboflowConfig.modelId}?api_key=${RoboflowConfig.apiKey}&confidence=1&overlap=30",
      );

      final response = await http.post(
        uri,
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: base64Image,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["predictions"] != null && data["predictions"].isNotEmpty) {
          final prediction = data["predictions"][0];

          final label = prediction["class"].toString().toUpperCase();
          final confidenceValue = prediction["confidence"] as num;
          final confidencePercent =
              "${(confidenceValue * 100).toStringAsFixed(1)}%";

          return _mapPredictionToResult(label, confidencePercent);
        }
      }

      return AiDetectionResult(
        objectName: "No Object Detected",
        category: "UNKNOWN",
        confidence: "0%",
        icon: Icons.help_outline,
        color: Colors.grey,
      );
    } catch (e) {
      return AiDetectionResult(
        objectName: "Detection Error",
        category: "ERROR",
        confidence: "0%",
        icon: Icons.error_outline,
        color: Colors.redAccent,
      );
    }
  }

  AiDetectionResult _mapPredictionToResult(String label, String confidence) {
    switch (label) {
      case "BIODEGRADABLE":
        return AiDetectionResult(
          objectName: "Biodegradable Waste",
          category: "BIODEGRADABLE",
          confidence: confidence,
          icon: Icons.eco,
          color: const Color(0xFF6BFB9A),
        );

      case "CARDBOARD":
        return AiDetectionResult(
          objectName: "Cardboard Waste",
          category: "CARDBOARD",
          confidence: confidence,
          icon: Icons.inventory_2,
          color: Colors.brown,
        );

      case "GLASS":
        return AiDetectionResult(
          objectName: "Glass Waste",
          category: "GLASS",
          confidence: confidence,
          icon: Icons.wine_bar,
          color: Colors.lightBlue,
        );

      case "METAL":
        return AiDetectionResult(
          objectName: "Metal Waste",
          category: "METAL",
          confidence: confidence,
          icon: Icons.settings,
          color: Colors.blueGrey,
        );

      case "PAPER":
        return AiDetectionResult(
          objectName: "Paper Waste",
          category: "PAPER",
          confidence: confidence,
          icon: Icons.article,
          color: Colors.orange,
        );

      case "PLASTIC":
        return AiDetectionResult(
          objectName: "Plastic Waste",
          category: "PLASTIC",
          confidence: confidence,
          icon: Icons.local_drink,
          color: const Color(0xFF44E2CD),
        );

      default:
        return AiDetectionResult(
          objectName: label,
          category: label,
          confidence: confidence,
          icon: Icons.delete_outline,
          color: Colors.grey,
        );
    }
  }
}