import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// note: This model stores one detection result.
class DetectionItem {
  final String objectName;
  final String category;
  final String confidence;
  final String date;
  final String time;
  final int iconCodePoint;
  final int colorValue;

  DetectionItem({
    required this.objectName,
    required this.category,
    required this.confidence,
    required this.date,
    required this.time,
    required this.iconCodePoint,
    required this.colorValue,
  });

  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');

  Color get color => Color(colorValue);

  Map<String, dynamic> toJson() {
    return {
      "objectName": objectName,
      "category": category,
      "confidence": confidence,
      "date": date,
      "time": time,
      "iconCodePoint": iconCodePoint,
      "colorValue": colorValue,
    };
  }

  factory DetectionItem.fromJson(Map<String, dynamic> json) {
    return DetectionItem(
      objectName: json["objectName"],
      category: json["category"],
      confidence: json["confidence"],
      date: json["date"],
      time: json["time"],
      iconCodePoint: json["iconCodePoint"],
      colorValue: json["colorValue"],
    );
  }
}

// note: This list stores detection history.
List<DetectionItem> detectionHistory = [];

// note: This loads saved history when app starts.
Future<void> loadDetectionHistory() async {
  final prefs = await SharedPreferences.getInstance();
  final savedData = prefs.getStringList("detectionHistory") ?? [];

  detectionHistory = savedData.map((item) {
    return DetectionItem.fromJson(jsonDecode(item));
  }).toList();
}

// note: This saves history after each detection.
Future<void> saveDetectionHistoryToStorage() async {
  final prefs = await SharedPreferences.getInstance();

  final savedData = detectionHistory.map((item) {
    return jsonEncode(item.toJson());
  }).toList();

  await prefs.setStringList("detectionHistory", savedData);
}

// note: This clears saved history.
Future<void> clearDetectionHistoryStorage() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove("detectionHistory");
}