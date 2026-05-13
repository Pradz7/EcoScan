import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'camera_screen.dart';
import 'about_screen.dart';
import 'detection_data.dart';

// note: This is the main navigation page with bottom navigation bar.
class HomeNavigation extends StatefulWidget {
  const HomeNavigation({super.key});

  @override
  State<HomeNavigation> createState() => _HomeNavigationState();
}

class _HomeNavigationState extends State<HomeNavigation> {
  int selectedIndex = 0;

  final List<Widget> pages = const [
    DashboardPage(),
    CameraScreen(),
    HistoryPage(),
    AboutScreen(),
    ProfilePage(),
  ];

  void changePage(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: changePage,
        backgroundColor: const Color(0xFF1E293B),
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: "Camera"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: "About"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

// note: This is the dashboard page.
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  int _countCategory(String category) {
    return detectionHistory.where((item) => item.category == category).length;
  }

  Widget _glassCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF161B26),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _statCard(
  String title,
  String value,
  String subtitle,
  IconData icon,
  Color color,
) {
  return _glassCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: const Color(0xFF9CA3AF),
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE5E7EB),
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  subtitle,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

  Widget _recentCard(DetectionItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161B26),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              item.icon,
              color: item.color,
              size: 30,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.objectName,
                  style: const TextStyle(
                    color: Color(0xFFE5E7EB),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  item.category,
                  style: TextStyle(
                    color: item.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          Text(
            item.confidence,
            style: const TextStyle(
              color: Color(0xFF6BFB9A),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
  final Map<String, int> categoryCount = {
    "BIODEGRADABLE": 0,
    "CARDBOARD": 0,
    "GLASS": 0,
    "METAL": 0,
    "PAPER": 0,
    "PLASTIC": 0,
  };

  for (final item in detectionHistory) {
    if (categoryCount.containsKey(item.category)) {
      categoryCount[item.category] = categoryCount[item.category]! + 1;
    }
  }

  final int total = categoryCount.values.fold(0, (sum, value) => sum + value);

  if (total == 0) {
    return _glassCard(
      child: const Text(
        "No category analytics yet. Start scanning to generate chart data.",
        style: TextStyle(color: Color(0xFF9CA3AF)),
      ),
    );
  }

  return _glassCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Waste Category Analytics",
          style: TextStyle(
            color: Color(0xFF9CA3AF),
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),

        const SizedBox(height: 24),

        SizedBox(
          height: 220,
          child: PieChart(
            PieChartData(
              centerSpaceRadius: 52,
              sectionsSpace: 4,
              sections: [
                PieChartSectionData(
                  value: categoryCount["BIODEGRADABLE"]!.toDouble(),
                  title: "BIO",
                  color: const Color(0xFF6BFB9A),
                  radius: 68,
                  titleStyle: const TextStyle(
                    color: Color(0xFF0B101B),
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
                PieChartSectionData(
                  value: categoryCount["CARDBOARD"]!.toDouble(),
                  title: "CARD",
                  color: const Color(0xFFFFB47F),
                  radius: 64,
                  titleStyle: const TextStyle(
                    color: Color(0xFF0B101B),
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
                PieChartSectionData(
                  value: categoryCount["GLASS"]!.toDouble(),
                  title: "GLASS",
                  color: const Color(0xFF44E2CD),
                  radius: 62,
                  titleStyle: const TextStyle(
                    color: Color(0xFF0B101B),
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
                PieChartSectionData(
                  value: categoryCount["METAL"]!.toDouble(),
                  title: "METAL",
                  color: const Color(0xFF94A3B8),
                  radius: 60,
                  titleStyle: const TextStyle(
                    color: Color(0xFF0B101B),
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
                PieChartSectionData(
                  value: categoryCount["PAPER"]!.toDouble(),
                  title: "PAPER",
                  color: const Color(0xFFFACC15),
                  radius: 58,
                  titleStyle: const TextStyle(
                    color: Color(0xFF0B101B),
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
                PieChartSectionData(
                  value: categoryCount["PLASTIC"]!.toDouble(),
                  title: "PLASTIC",
                  color: const Color(0xFF8B5CF6),
                  radius: 56,
                  titleStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 18),

        Text(
          "Total scanned items: $total",
          style: const TextStyle(color: Color(0xFF9CA3AF)),
        ),
      ],
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final total = detectionHistory.length;
    final latest = detectionHistory.take(2).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0B101B),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0B101B),
        elevation: 0,

        title: const Text(
          "EcoScan",
          style: TextStyle(
            color: Color(0xFF6BFB9A),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),

        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 14),
            child: Icon(
              Icons.settings,
              color: Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Hello, User",
              style: TextStyle(
                color: Color(0xFFE5E7EB),
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              "You've successfully diverted ${(total * 0.3).toStringAsFixed(1)}kg of waste this month.",
              style: const TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 16,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 28),

            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CameraScreen(),
                  ),
                );
              },

              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: const Color(0xFF161B26),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: const Color(0xFF44E2CD).withOpacity(0.15),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF44E2CD).withOpacity(0.08),
                      blurRadius: 24,
                    ),
                  ],
                ),

                child: Column(
                  children: [
                    Container(
                      width: 74,
                      height: 74,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF44E2CD).withOpacity(0.12),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Color(0xFF6BFB9A),
                        size: 36,
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      "Scan New Object",
                      style: TextStyle(
                        color: Color(0xFFE5E7EB),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      "AI-powered classification in seconds",
                      style: TextStyle(
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: _statCard(
                    "Waste Sorted",
                    "$total",
                    "items",
                    Icons.recycling,
                    const Color(0xFF6BFB9A),
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: _statCard(
                    "Detection Accuracy",
                    total == 0 ? "0" : "96",
                    "%",
                    Icons.track_changes,
                    const Color(0xFF44E2CD),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            _buildPieChart(),

            const SizedBox(height: 32),

            const Text(
              "Recent Detection",
              style: TextStyle(
                color: Color(0xFFE5E7EB),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 18),

            if (latest.isEmpty)
              const Text(
                "No recent detection yet.",
                style: TextStyle(
                  color: Color(0xFF9CA3AF),
                ),
              )
            else
              ...latest.map(
                (item) => _recentCard(item),
              ),
          ],
        ),
      ),
    );
  }
}

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String searchQuery = "";

  final Set<int> selectedIndexes = {};

  List<DetectionItem> get filteredHistory {
    if (searchQuery.isEmpty) return detectionHistory;

    return detectionHistory.where((item) {
      final query = searchQuery.toLowerCase();

      return item.objectName.toLowerCase().contains(query) ||
          item.category.toLowerCase().contains(query);
    }).toList();
  }

  bool get isSelectionMode => selectedIndexes.isNotEmpty;

  Future<void> _deleteSelected() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF161B26),

          title: const Text("Delete Selected?"),

          content: Text(
            "Delete ${selectedIndexes.length} selected item(s)?",
            style: const TextStyle(color: Colors.grey),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text("Cancel"),
            ),

            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      final sortedIndexes = selectedIndexes.toList()
        ..sort((a, b) => b.compareTo(a));

      for (final index in sortedIndexes) {
        detectionHistory.removeAt(index);
      }

      selectedIndexes.clear();

      await saveDetectionHistoryToStorage();

      setState(() {});
    }
  }

  Widget _historyItem(DetectionItem item, int index) {
    final isSelected = selectedIndexes.contains(index);

    return GestureDetector(
      onLongPress: () {
        setState(() {
          selectedIndexes.add(index);
        });
      },

      onTap: () {
        if (isSelectionMode) {
          setState(() {
            if (isSelected) {
              selectedIndexes.remove(index);
            } else {
              selectedIndexes.add(index);
            }
          });
        }
      },

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),

        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF1E293B)
              : const Color(0xFF161B26),

          borderRadius: BorderRadius.circular(20),

          border: Border.all(
            color: isSelected
                ? const Color(0xFF6BFB9A)
                : Colors.white.withOpacity(0.08),
            width: isSelected ? 2 : 1,
          ),
        ),

        child: Row(
          children: [
            if (isSelectionMode)
              Padding(
                padding: const EdgeInsets.only(right: 14),
                child: Icon(
                  isSelected
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: isSelected
                      ? const Color(0xFF6BFB9A)
                      : Colors.grey,
                ),
              ),

            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: item.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),

              child: Icon(
                item.icon,
                color: item.color,
                size: 34,
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.category,
                    style: TextStyle(
                      color: item.color,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    item.objectName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFE5E7EB),
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "${item.date} • ${item.time}",
                    style: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            Text(
              item.confidence,
              style: const TextStyle(
                color: Color(0xFF6BFB9A),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = filteredHistory;

    return Scaffold(
      backgroundColor: const Color(0xFF0B101B),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0B101B),
        elevation: 0,

        centerTitle: true,

        title: Text(
          isSelectionMode
              ? "${selectedIndexes.length} Selected"
              : "EcoScan",

          style: const TextStyle(
            color: Color(0xFF6BFB9A),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),

        actions: [
          if (isSelectionMode)
            IconButton(
              onPressed: _deleteSelected,
              icon: const Icon(
                Icons.delete,
                color: Colors.redAccent,
              ),
            ),

          if (isSelectionMode)
            IconButton(
              onPressed: () {
                setState(() {
                  selectedIndexes.clear();
                });
              },
              icon: const Icon(
                Icons.close,
                color: Colors.white,
              ),
            ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },

              style: const TextStyle(color: Colors.white),

              decoration: InputDecoration(
                hintText: "Search history...",
                hintStyle: const TextStyle(
                  color: Color(0xFF9CA3AF),
                ),

                prefixIcon: const Icon(
                  Icons.search,
                  color: Color(0xFF9CA3AF),
                ),

                filled: true,
                fillColor: const Color(0xFF161B26),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 24),

            Expanded(
              child: items.isEmpty
                  ? const Center(
                      child: Text(
                        "No detection history found.",
                        style: TextStyle(
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        return _historyItem(items[index], index);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// note: This is the profile page.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  int _countCategory(String category) {
    return detectionHistory.where((item) => item.category == category).length;
  }

  Widget _glassCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF161B26),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _impactCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return _glassCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE5E7EB),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _achievementItem(
    String title,
    String description,
    IconData icon,
    Color color,
    String time,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFF263241),
            width: 0.6,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF222A36),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFE5E7EB),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalScans = detectionHistory.length;
    final plasticCount = _countCategory("PLASTIC");
    final paperCount = _countCategory("PAPER");
    final estimatedCo2Saved = (totalScans * 0.12).toStringAsFixed(1);

    return Scaffold(
      backgroundColor: const Color(0xFF0B101B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B101B),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "EcoScan",
          style: TextStyle(
            color: Color(0xFF6BFB9A),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 14),
            child: Icon(
              Icons.settings,
              color: Color(0xFF6BFB9A),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),

            Stack(
              children: [
                const CircleAvatar(
                  radius: 52,
                  backgroundColor: Color(0xFF6BFB9A),
                  child: Icon(
                    Icons.person,
                    size: 62,
                    color: Color(0xFF0B101B),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6BFB9A),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF0B101B),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.verified,
                      size: 17,
                      color: Color(0xFF0B101B),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            const Text(
              "Smart Trash User",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE5E7EB),
              ),
            ),

            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFF44E2CD).withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF44E2CD).withOpacity(0.35),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.eco, color: Color(0xFF44E2CD), size: 16),
                  SizedBox(width: 6),
                  Text(
                    "PRO MEMBER",
                    style: TextStyle(
                      color: Color(0xFF44E2CD),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            const Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Icon(Icons.public, color: Color(0xFF6BFB9A)),
                  SizedBox(width: 8),
                  Text(
                    "Environmental Impact",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFBCCABB),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            _impactCard(
              "CO2 Saved",
              "$estimatedCo2Saved kg",
              "+${(totalScans * 0.03).toStringAsFixed(1)}kg this week",
              Icons.co2,
              const Color(0xFF6BFB9A),
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: _impactCard(
                    "Plastic Diverted",
                    "$plasticCount",
                    "items",
                    Icons.recycling,
                    const Color(0xFF44E2CD),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _impactCard(
                    "Paper Saved",
                    "$paperCount",
                    "items",
                    Icons.forest,
                    Colors.orange,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            const Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Icon(Icons.workspace_premium, color: Color(0xFF44E2CD)),
                  SizedBox(width: 8),
                  Text(
                    "Recent Achievements",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFBCCABB),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF161B26),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
              child: Column(
                children: [
                  _achievementItem(
                    "AI Scanner",
                    "You have scanned $totalScans trash items using the phone camera.",
                    Icons.center_focus_strong,
                    const Color(0xFFFFB47F),
                    "Today",
                  ),
                  _achievementItem(
                    "Plastic Watcher",
                    "You detected $plasticCount plastic waste items.",
                    Icons.water_drop,
                    const Color(0xFF6BFB9A),
                    "2d ago",
                  ),
                  _achievementItem(
                    "Forest Guardian",
                    "You detected $paperCount paper waste items.",
                    Icons.forest,
                    const Color(0xFF44E2CD),
                    "1w ago",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}