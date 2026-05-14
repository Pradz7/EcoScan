import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'main.dart';
import 'result_screen.dart';
import 'detection_data.dart';
import 'ai_detection_service.dart';
import 'firestore_service.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? cameraController;

  bool isCameraReady = false;
  bool isScanning = false;

  final AiDetectionService aiDetectionService = AiDetectionService();

  String detectedObject = "Ready";
  String detectedCategory = "";
  String detectedConfidence = "";
  IconData detectedIcon = Icons.center_focus_strong;
  Color detectedColor = const Color(0xFF6BFB9A);

  @override
  void initState() {
    super.initState();
    setupCamera();
  }

  Future<void> setupCamera() async {
    if (cameras.isEmpty) return;

    cameraController = CameraController(
      cameras[0],
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await cameraController!.initialize();

    if (!mounted) return;

    setState(() {
      isCameraReady = true;
    });
  }

  Future<void> saveDetectionHistory() async {
    final now = DateTime.now();

    detectionHistory.insert(
      0,
      DetectionItem(
        objectName: detectedObject,
        category: detectedCategory,
        confidence: detectedConfidence,
        date: "${now.day}/${now.month}/${now.year}",
        time: "${now.hour}:${now.minute.toString().padLeft(2, '0')}",
        iconCodePoint: detectedIcon.codePoint,
        colorValue: detectedColor.value,
      ),
    );

    await saveDetectionHistoryToStorage();
    await FirestoreService.saveDetection(detectionHistory.first);
  }

  void startDetection() async {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return;
    }

    setState(() {
      isScanning = true;
      detectedObject = "Scanning";
      detectedConfidence = "";
    });

    await Future.delayed(const Duration(milliseconds: 300));

    final image = await cameraController!.takePicture();
    final result = await aiDetectionService.detectTrash(File(image.path));

    if (!mounted) return;

    detectedObject = result.objectName;
    detectedCategory = result.category;
    detectedConfidence = result.confidence;
    detectedIcon = result.icon;
    detectedColor = result.color;

    await saveDetectionHistory();

    setState(() {
      isScanning = false;
    });

    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          objectName: detectedObject,
          category: detectedCategory,
          confidence: detectedConfidence,
          icon: detectedIcon,
          color: detectedColor,
        ),
      ),
    );
  }

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }

  Widget _scannerCorner(Alignment alignment) {
    final bool top =
        alignment == Alignment.topLeft || alignment == Alignment.topRight;
    final bool bottom =
        alignment == Alignment.bottomLeft || alignment == Alignment.bottomRight;
    final bool left =
        alignment == Alignment.topLeft || alignment == Alignment.bottomLeft;
    final bool right =
        alignment == Alignment.topRight || alignment == Alignment.bottomRight;

    return Align(
      alignment: alignment,
      child: Container(
        width: 34,
        height: 34,
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: alignment == Alignment.topLeft
                ? const Radius.circular(14)
                : Radius.zero,
            topRight: alignment == Alignment.topRight
                ? const Radius.circular(14)
                : Radius.zero,
            bottomLeft: alignment == Alignment.bottomLeft
                ? const Radius.circular(14)
                : Radius.zero,
            bottomRight: alignment == Alignment.bottomRight
                ? const Radius.circular(14)
                : Radius.zero,
          ),
          border: Border(
            top: top
                ? BorderSide(color: detectedColor, width: 6)
                : BorderSide.none,
            bottom: bottom
                ? BorderSide(color: detectedColor, width: 6)
                : BorderSide.none,
            left: left
                ? BorderSide(color: detectedColor, width: 6)
                : BorderSide.none,
            right: right
                ? BorderSide(color: detectedColor, width: 6)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool showLabel = isScanning || detectedCategory.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFF101415),
      body: Stack(
        children: [
          SizedBox.expand(
            child: isCameraReady && cameraController != null
                ? CameraPreview(cameraController!)
                : Container(
                    color: Colors.black,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF6BFB9A),
                      ),
                    ),
                  ),
          ),

          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.55),
                  Colors.transparent,
                  Colors.black.withOpacity(0.85),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: const Text(
                    "Align object in frame",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),

          Align(
            alignment: const Alignment(0, -0.18),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 270,
              height: 340,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: detectedColor,
                  width: 3.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: detectedColor.withOpacity(0.45),
                    blurRadius: 22,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  _scannerCorner(Alignment.topLeft),
                  _scannerCorner(Alignment.topRight),
                  _scannerCorner(Alignment.bottomLeft),
                  _scannerCorner(Alignment.bottomRight),

                  if (showLabel)
                    Positioned(
                      top: 24,
                      left: 18,
                      right: 18,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.55),
                            borderRadius: BorderRadius.circular(40),
                            border: Border.all(
                              color: detectedColor.withOpacity(0.45),
                            ),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: detectedColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  isScanning ? "Scanning..." : detectedObject,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (!isScanning &&
                                    detectedConfidence.isNotEmpty) ...[
                                  const SizedBox(width: 12),
                                  Text(
                                    detectedConfidence,
                                    style: TextStyle(
                                      color: detectedColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                  if (isScanning)
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: 300),
                      duration: const Duration(seconds: 2),
                      curve: Curves.linear,
                      builder: (context, value, child) {
                        return Positioned(
                          top: value,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 2,
                            decoration: BoxDecoration(
                              color: detectedColor,
                              boxShadow: [
                                BoxShadow(
                                  color: detectedColor,
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: isScanning || !isCameraReady ? null : startDetection,
                    child: Container(
                      width: 92,
                      height: 92,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: detectedColor,
                          width: 5,
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: detectedColor.withOpacity(0.25),
                          ),
                          child: Center(
                            child: Container(
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: detectedColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  Text(
                    isScanning
                        ? "AI analyzing object..."
                        : "Tap to start AI detection",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}