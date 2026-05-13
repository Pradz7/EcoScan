import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'main.dart';
import 'result_screen.dart';
import 'detection_data.dart';
import 'ai_detection_service.dart';

// note: This screen uses the real phone camera.
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
  IconData detectedIcon = Icons.local_drink;
  Color detectedColor = Colors.deepPurple;

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
  }

  void startDetection() async {
    setState(() {
      isScanning = true;
    });

    final result = await aiDetectionService.detectTrash();

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
    return Align(
      alignment: alignment,
      child: Container(
        width: 28,
        height: 28,
        margin: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          border: Border(
            top: alignment == Alignment.topLeft ||
                    alignment == Alignment.topRight
                ? BorderSide(color: detectedColor, width: 4)
                : BorderSide.none,
            bottom: alignment == Alignment.bottomLeft ||
                    alignment == Alignment.bottomRight
                ? BorderSide(color: detectedColor, width: 4)
                : BorderSide.none,
            left: alignment == Alignment.topLeft ||
                    alignment == Alignment.bottomLeft
                ? BorderSide(color: detectedColor, width: 4)
                : BorderSide.none,
            right: alignment == Alignment.topRight ||
                    alignment == Alignment.bottomRight
                ? BorderSide(color: detectedColor, width: 4)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  Colors.black.withOpacity(0.75),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 52),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    child: const Text(
                      "Align object in frame",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 52),
                ],
              ),
            ),
          ),

          Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              width: 260,
              height: 360,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: detectedColor,
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: detectedColor.withOpacity(0.35),
                    blurRadius: 30,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  _scannerCorner(Alignment.topLeft),
                  _scannerCorner(Alignment.topRight),
                  _scannerCorner(Alignment.bottomLeft),
                  _scannerCorner(Alignment.bottomRight),

                  Positioned(
                    top: 18,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.55),
                          borderRadius: BorderRadius.circular(40),
                          border: Border.all(
                            color: detectedColor.withOpacity(0.4),
                          ),
                        ),
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
                            const SizedBox(width: 10),
                            Text(
                              isScanning ? "AI" : detectedConfidence,
                              style: TextStyle(
                                color: detectedColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  if (isScanning)
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: 320),
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

          if (isScanning)
            Positioned(
              bottom: 220,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  const CircularProgressIndicator(
                    color: Color(0xFF6BFB9A),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    "AI analyzing object...",
                    style: TextStyle(
                      color: detectedColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                GestureDetector(
                  onTap: isScanning || !isCameraReady ? null : startDetection,
                  child: Container(
                    width: 95,
                    height: 95,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: detectedColor,
                        width: 4,
                      ),
                    ),
                    child: Center(
                      child: Container(
                        width: 72,
                        height: 72,
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

                const SizedBox(height: 20),

                Text(
                  isScanning ? "Scanning..." : "Tap to start AI detection",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}