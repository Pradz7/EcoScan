import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'detection_data.dart';

// note: This service saves and loads detection history from Firestore per user.
class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static String? get userId => _auth.currentUser?.uid;

  static Future<void> saveDetection(DetectionItem item) async {
    if (userId == null) return;

    await _firestore
        .collection("users")
        .doc(userId)
        .collection("detections")
        .add({
      "objectName": item.objectName,
      "category": item.category,
      "confidence": item.confidence,
      "date": item.date,
      "time": item.time,
      "iconCodePoint": item.iconCodePoint,
      "colorValue": item.colorValue,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  static Future<void> loadDetections() async {
    if (userId == null) return;

    final snapshot = await _firestore
        .collection("users")
        .doc(userId)
        .collection("detections")
        .orderBy("createdAt", descending: true)
        .get();

    detectionHistory = snapshot.docs.map((doc) {
      final data = doc.data();

      return DetectionItem(
        objectName: data["objectName"] ?? "",
        category: data["category"] ?? "",
        confidence: data["confidence"] ?? "0%",
        date: data["date"] ?? "",
        time: data["time"] ?? "",
        iconCodePoint: data["iconCodePoint"] ?? 0xe3af,
        colorValue: data["colorValue"] ?? 0xFF9CA3AF,
      );
    }).toList();
  }

  static Future<void> clearDetections() async {
    if (userId == null) return;

    final snapshot = await _firestore
        .collection("users")
        .doc(userId)
        .collection("detections")
        .get();

    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}