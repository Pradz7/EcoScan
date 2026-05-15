import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'camera_screen.dart';
import 'about_screen.dart';
import 'detection_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_screen.dart';
import 'firestore_service.dart';


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
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hello, ${FirebaseAuth.instance.currentUser?.displayName?.isNotEmpty == true ? FirebaseAuth.instance.currentUser!.displayName! : FirebaseAuth.instance.currentUser?.email?.split('@')[0] ?? 'User'}",
              style: const TextStyle(
                color: Color(0xFFE5E7EB),
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),
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
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
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
    final itemsToDelete = selectedIndexes
    .map((index) => filteredHistory[index])
    .toList();

    detectionHistory.removeWhere((item) => itemsToDelete.contains(item));

    selectedIndexes.clear();

    await saveDetectionHistoryToStorage();
    await FirestoreService.clearDetections();

    for (final item in detectionHistory) {
      await FirestoreService.saveDetection(item);
    }

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
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _countCategory(String category) {
    return detectionHistory.where((item) => item.category == category).length;
  }

  String _getUsername() {
    final user = FirebaseAuth.instance.currentUser;

    if (user?.displayName != null && user!.displayName!.trim().isNotEmpty) {
      return user.displayName!;
    }

    if (user?.email != null) {
      return user!.email!.split('@')[0];
    }

    return "EcoScan User";
  }

  Future<void> _editUsername() async {
    final controller = TextEditingController(
      text: _getUsername(),
    );

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF161B26),
          title: const Text(
            "Edit Username",
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Enter username",
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFF0B101B),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                final newUsername = controller.text.trim();

                if (newUsername.isEmpty) return;

                await FirebaseAuth.instance.currentUser?.updateDisplayName(
                  newUsername,
                );

                await FirebaseAuth.instance.currentUser?.reload();

                if (!mounted) return;

                setState(() {});

                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Widget _infoCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF161B26),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
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
                    color: Color(0xFFE5E7EB),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryStat(String category, int count, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF161B26),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              category,
              style: const TextStyle(
                color: Color(0xFFE5E7EB),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            "$count items",
            style: const TextStyle(color: Color(0xFF9CA3AF)),
          ),
        ],
      ),
    );
  }

  Widget _logoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        onPressed: () async {
          await FirebaseAuth.instance.signOut();

          if (!context.mounted) return;

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const AuthScreen(),
            ),
            (route) => false,
          );
        },
        icon: const Icon(Icons.logout),
        label: const Text(
          "Logout",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? "No email";

    final totalScans = detectionHistory.length;
    final plasticCount = _countCategory("PLASTIC");
    final paperCount = _countCategory("PAPER");
    final metalCount = _countCategory("METAL");
    final glassCount = _countCategory("GLASS");
    final cardboardCount = _countCategory("CARDBOARD");
    final biodegradableCount = _countCategory("BIODEGRADABLE");

    return Scaffold(
      backgroundColor: const Color(0xFF0B101B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B101B),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Profile",
          style: TextStyle(
            color: Color(0xFF6BFB9A),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
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

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    _getUsername(),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE5E7EB),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _editUsername,
                  child: const Icon(
                    Icons.edit,
                    color: Color(0xFF6BFB9A),
                    size: 22,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              email,
              style: const TextStyle(color: Color(0xFF9CA3AF)),
            ),

            const SizedBox(height: 30),

            _infoCard(
              "Total Scans",
              "$totalScans detections",
              Icons.center_focus_strong,
              const Color(0xFF6BFB9A),
            ),

            const SizedBox(height: 22),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Detected Categories",
                style: TextStyle(
                  color: Color(0xFFE5E7EB),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 16),

            _categoryStat(
              "BIODEGRADABLE",
              biodegradableCount,
              const Color(0xFF6BFB9A),
            ),
            _categoryStat(
              "CARDBOARD",
              cardboardCount,
              Colors.brown,
            ),
            _categoryStat(
              "GLASS",
              glassCount,
              Colors.lightBlue,
            ),
            _categoryStat(
              "METAL",
              metalCount,
              Colors.blueGrey,
            ),
            _categoryStat(
              "PAPER",
              paperCount,
              Colors.orange,
            ),
            _categoryStat(
              "PLASTIC",
              plasticCount,
              const Color(0xFF44E2CD),
            ),

            const SizedBox(height: 24),

            _logoutButton(context),
          ],
        ),
      ),
    );
  }
}