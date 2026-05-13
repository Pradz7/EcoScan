import 'package:flutter/material.dart';

// note: This page explains the project for portfolio purpose.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  // note: This widget creates reusable information cards.
  Widget _infoCard(
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.grey,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // note: This widget shows one supported trash category.
  Widget _categoryChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      margin: const EdgeInsets.only(right: 8, bottom: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        centerTitle: true,
        title: const Text(
          "About Project",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF16A34A),
                    Color(0xFF0F766E),
                  ],
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.recycling,
                    size: 80,
                    color: Colors.white,
                  ),
                  SizedBox(height: 15),
                  Text(
                    "Smart Trash Detection",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "AI-based waste classification app using Flutter, phone camera, and a Roboflow object detection model.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            _infoCard(
              "Project Goal",
              "To classify trash automatically using the phone camera and help users understand the correct disposal category.",
              Icons.flag,
              Colors.green,
            ),

            _infoCard(
              "How It Works",
              "The phone camera captures trash objects, then the AI model predicts the category, confidence score, suggested bin, and disposal tip.",
              Icons.settings,
              Colors.blue,
            ),

            _infoCard(
              "Technology Used",
              "Flutter for the mobile interface, phone camera for image input, Roboflow for dataset training, and object detection for classification.",
              Icons.memory,
              Colors.orange,
            ),

            _infoCard(
              "Supported Categories",
              "The model is prepared for six categories: biodegradable, cardboard, glass, metal, paper, and plastic.",
              Icons.category,
              Colors.teal,
            ),

            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 15),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Wrap(
                children: [
                  _categoryChip("BIODEGRADABLE", Colors.lightGreen),
                  _categoryChip("CARDBOARD", Colors.brown),
                  _categoryChip("GLASS", Colors.orange),
                  _categoryChip("METAL", Colors.blueGrey),
                  _categoryChip("PAPER", Colors.teal),
                  _categoryChip("PLASTIC", Colors.deepPurple),
                ],
              ),
            ),

            _infoCard(
              "Portfolio Value",
              "This project shows mobile app development, computer vision, AI model training, dataset preparation, and real-world environmental impact.",
              Icons.work,
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }
}