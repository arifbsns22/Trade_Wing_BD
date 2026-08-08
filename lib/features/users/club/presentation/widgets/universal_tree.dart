import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'package:get/get.dart' hide Node;

class UniversalTreeWidget extends StatefulWidget {
  final String rootReferralCode;

  const UniversalTreeWidget({super.key, required this.rootReferralCode});

  @override
  State<UniversalTreeWidget> createState() => _UniversalTreeWidgetState();
}

class _UniversalTreeWidgetState extends State<UniversalTreeWidget> {
  final Graph graph = Graph()..isTree = true;
  final BuchheimWalkerConfiguration builder = BuchheimWalkerConfiguration();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = true;
  String? _errorMessage;
  int _totalDownlineCount = 0;

  // Maps to store nodes and user data
  final Map<String, Node> _nodeMap = {};
  final Map<String, Map<String, dynamic>> _userDataMap = {};

  // For zoom/pan controller
  final TransformationController _transformationController = TransformationController();

  @override
  void initState() {
    super.initState();
    // Configure tree layout spacing and orientation
    builder
      ..siblingSeparation = 40
      ..levelSeparation = 100
      ..subtreeSeparation = 40
      ..orientation = BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM;

    _loadTreeData();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  Future<void> _loadTreeData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _totalDownlineCount = 0;
        _nodeMap.clear();
        _userDataMap.clear();
        graph.nodes.clear();
      });

      // 1. Fetch all users from Firestore
      final querySnapshot = await _firestore.collection('users').get();
      final usersDocs = querySnapshot.docs;

      // Map users by their referralCode for fast O(1) lookups
      final Map<String, Map<String, dynamic>> allUsersMap = {};
      for (var doc in usersDocs) {
        final data = doc.data();
        final code = data['referralCode'] as String?;
        if (code != null && code.trim().isNotEmpty) {
          allUsersMap[code.trim()] = data;
        }
      }

      // Check if root user exists
      final trimmedRootCode = widget.rootReferralCode.trim();
      if (!allUsersMap.containsKey(trimmedRootCode)) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'আপনার অ্যাকাউন্টটির জন্য কোনো রেফারেল কোড পাওয়া যায়নি।';
        });
        return;
      }

      // 2. Add root node
      final rootData = allUsersMap[trimmedRootCode]!;
      _userDataMap[trimmedRootCode] = rootData;
      final rootNode = Node.Id(trimmedRootCode);
      _nodeMap[trimmedRootCode] = rootNode;
      graph.addNode(rootNode);

      // 3. Build tree recursively to avoid infinite cycles
      final Set<String> visited = {trimmedRootCode};
      _buildTree(trimmedRootCode, rootNode, allUsersMap, visited);

      setState(() {
        _isLoading = false;
      });
      _centerRootNode(delay: true);
    } catch (e) {
      debugPrint('Error loading MLM tree: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'নেটওয়ার্ক সংযোগে সমস্যা হয়েছে। আবার চেষ্টা করুন।';
      });
    }
  }

  void _buildTree(
    String parentCode,
    Node parentNode,
    Map<String, Map<String, dynamic>> allUsersMap,
    Set<String> visited,
  ) {
    // Find all children where referredBy equals the parentCode
    final children = allUsersMap.values.where((user) {
      final referredBy = user['referredBy'] as String?;
      return referredBy != null && referredBy.trim() == parentCode;
    }).toList();

    for (var child in children) {
      final childCode = (child['referralCode'] as String).trim();

      // Avoid cyclic loops in network graph
      if (visited.contains(childCode)) continue;
      visited.add(childCode);

      // Save user details
      _userDataMap[childCode] = child;
      _totalDownlineCount++;

      // Create and map node
      final childNode = Node.Id(childCode);
      _nodeMap[childCode] = childNode;

      // Add edge from parent to child
      graph.addEdge(parentNode, childNode);

      // Recurse down
      _buildTree(childCode, childNode, allUsersMap, visited);
    }
  }

  // Mask mobile number for privacy
  String _maskMobile(String mobile) {
    if (mobile.length >= 11) {
      return '${mobile.substring(0, 3)}****${mobile.substring(7)}';
    }
    return mobile;
  }

  // Center the root node in the middle of the viewport horizontally
  void _centerRootNode({bool delay = false}) {
    void action() {
      if (!mounted) return;

      final double screenWidth = MediaQuery.of(context).size.width;

      double minX = double.infinity;
      double maxX = -double.infinity;

      for (var node in graph.nodes) {
        final x = node.position.dx;
        if (x < minX) minX = x;
        if (x > maxX) maxX = x;
      }

      if (minX == double.infinity || maxX == -double.infinity) return;

      final double treeWidth = maxX - minX + 240; // 240 is card width
      final double treeCenter = minX + (treeWidth / 2);
      final double screenCenter = screenWidth / 2;

      // Calculate horizontal offset to center the tree
      final double translationX = screenCenter - treeCenter;

      _transformationController.value = Matrix4.translationValues(translationX, 20.0, 0.0);
    }

    if (delay) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 200), action);
      });
    } else {
      action();
    }
  }

  // Reset zoom and center tree
  void _resetZoom() {
    _centerRootNode();
  }

  // Zoom In
  void _zoomIn() {
    _transformationController.value = _transformationController.value.clone()..multiply(Matrix4.diagonal3Values(1.2, 1.2, 1.0));
  }

  // Zoom Out
  void _zoomOut() {
    _transformationController.value = _transformationController.value.clone()..multiply(Matrix4.diagonal3Values(0.85, 0.85, 1.0));
  }

  // Show detailed bottom sheet for user node
  void _showNodeDetail(Map<String, dynamic> userData, int directCount) {
    final name = userData['name'] ?? 'নামবিহীন';
    final mobile = userData['mobile'] ?? 'N/A';
    final email = userData['email'] ?? 'N/A';
    final code = userData['referralCode'] ?? 'N/A';
    final role = userData['role'] ?? 'Customer';
    final bool isActive = userData['isActive'] ?? true;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isActive ? Colors.green.shade50 : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isActive ? 'সক্রিয়' : 'অকার্যকর',
                      style: TextStyle(
                        color: isActive ? Colors.green.shade700 : Colors.red.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'বিজনেজ কোড: $code',
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const Divider(height: 30),
              _buildDetailRow(Icons.phone_android, 'মোবাইল নম্বর', _maskMobile(mobile)),
              _buildDetailRow(Icons.email_outlined, 'ইমেইল', email),
              _buildDetailRow(Icons.badge_outlined, 'পদবী/ব্যাজ', role),
              _buildDetailRow(Icons.people_outline, 'সরাসরি রেফারেল', '$directCount জন'),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF08B3AC),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => Get.back(),
                  child: const Text('বন্ধ করুন', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF08B3AC), size: 22),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF08B3AC),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF08B3AC),
                ),
                onPressed: _loadTreeData,
                child: const Text('আবার চেষ্টা করুন', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    if (graph.nodes.isEmpty) {
      return const Center(
        child: Text('কোনো রেফারেল তথ্য পাওয়া যায়নি।'),
      );
    }

    return Stack(
      children: [
        // 1. Zoomable / Pannable canvas
        InteractiveViewer(
          constrained: false,
          boundaryMargin: const EdgeInsets.all(350),
          minScale: 0.1,
          maxScale: 3.0,
          transformationController: _transformationController,
          child: CustomPaint(
            painter: DottedBackgroundPainter(),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 80.0, horizontal: 80.0),
              child: GraphView(
                graph: graph,
                algorithm: BuchheimWalkerAlgorithm(builder, TreeEdgeRenderer(builder)),
                paint: Paint()
                  ..color = const Color(0xFF94A3B8).withValues(alpha: 0.4)
                  ..strokeWidth = 1.5
                  ..style = PaintingStyle.stroke,
                builder: (Node node) {
                  final userCode = node.key!.value as String;
                  final userData = _userDataMap[userCode] ?? {};
                  return _buildNodeCard(userCode, userData);
                },
              ),
            ),
          ),
        ),

        // 2. Tree Statistics overlay
        Positioned(
          top: 16,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF08B3AC),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'সর্বমোট ডাউনলাইন',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '$_totalDownlineCount জন',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
        ),

        // 3. Zoom Controls
        Positioned(
          bottom: 24,
          right: 24,
          child: Column(
            children: [
              FloatingActionButton.small(
                heroTag: 'zoom_in',
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF334155),
                onPressed: _zoomIn,
                child: const Icon(Icons.add),
              ),
              const SizedBox(height: 8),
              FloatingActionButton.small(
                heroTag: 'zoom_out',
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF334155),
                onPressed: _zoomOut,
                child: const Icon(Icons.remove),
              ),
              const SizedBox(height: 8),
              FloatingActionButton.small(
                heroTag: 'zoom_reset',
                backgroundColor: const Color(0xFF08B3AC),
                foregroundColor: Colors.white,
                onPressed: _resetZoom,
                child: const Icon(Icons.center_focus_strong),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Design each User Node beautifully
  Widget _buildNodeCard(String code, Map<String, dynamic> userData) {
    final name = userData['name'] ?? 'নামবিহীন';
    final mobile = userData['mobile'] ?? 'N/A';
    final role = userData['role'] ?? 'Customer';
    final bool isActive = userData['isActive'] ?? true;
    final String profilePicture = userData['profilePicture'] ?? '';
    final isRoot = code.trim() == widget.rootReferralCode.trim();

    // Check how many direct members this user referred
    final int directCount = _userDataMap.values.where((user) {
      final referredBy = user['referredBy'] as String?;
      return referredBy != null && referredBy.trim() == code;
    }).length;

    // Premium styling based on role and position (soft pastel colors)
    Color cardColor = Colors.white;
    Color borderColor = const Color(0xFFE2E8F0);
    Color roleColor = const Color(0xFF0EA5E9); // default soft blue
    IconData roleIcon = Icons.person_outline;

    if (role == 'Super Admin' || role == 'Admin') {
      roleColor = const Color(0xFF9333EA); // soft purple
      roleIcon = Icons.admin_panel_settings_outlined;
    } else if (role == 'Customer' || role == 'Active Customer') {
      roleColor = const Color(0xFF0D9488); // soft green-teal
      roleIcon = Icons.shopping_bag_outlined;
    }

    if (isRoot) {
      cardColor = const Color(0xFFF8FAFC);
      borderColor = roleColor.withValues(alpha: 0.4);
    } else {
      cardColor = Colors.white;
      borderColor = const Color(0xFFE2E8F0);
    }

    return GestureDetector(
      onTap: () => _showNodeDetail(userData, directCount),
      child: Container(
        width: 240, // Wider to support rich horizontal layout
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: isRoot ? 2.0 : 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Section: Icon container + Info + Status Dot
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon or Profile picture container
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: roleColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: profilePicture.isNotEmpty
                        ? Image.network(
                            profilePicture,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(roleIcon, color: roleColor, size: 20),
                          )
                        : Icon(roleIcon, color: roleColor, size: 20),
                  ),
                ),
                const SizedBox(width: 12),
                // Name & Role Title
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        role,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: roleColor,
                        ),
                      ),
                    ],
                  ),
                ),
                // Status indicator dot
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.green.shade500 : Colors.red.shade500,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Middle section: Referral Code and Mobile
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'কোড: $code',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _maskMobile(mobile),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const Divider(height: 20, color: Color(0xFFF1F5F9)),

            // Bottom Section: Color-coded stats matching the reference design
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Direct Downlines
                _buildStatIcon(Icons.people_outline, '$directCount', Colors.blue.shade600),
                // Reward Points
                _buildStatIcon(Icons.star_outline, '${userData['totalRewardPoints'] ?? 0}', Colors.orange.shade600),
                // Orders count
                _buildStatIcon(Icons.shopping_cart_outlined, '${userData['totalOrders'] ?? 0}', Colors.green.shade600),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatIcon(IconData icon, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

// Custom Painter to draw a clean, premium dotted canvas background
class DottedBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF94A3B8).withValues(alpha: 0.15)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    const double spacing = 24.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.0, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
