import 'package:flutter/material.dart';
import 'package:postman/BottomNavbar.dart';
import 'package:postman/view/login_view.dart';

class DashboardView extends StatelessWidget {
  final String? userName;
  final String? userRole;

  const DashboardView({
    super.key,
    this.userName = "User",
    this.userRole = "Guest",
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Ultra light grey-blue
      body: Stack(
        children: [
          // 1. Latar Belakang Dekoratif (Lingkaran Gradasi)
          Positioned(
            top: -100,
            right: -50,
            child: _buildCircle(300, const Color(0xFF0EA5E9).withOpacity(0.2)),
          ),
          Positioned(
            top: 200,
            left: -80,
            child: _buildCircle(200, const Color(0xFF38BDF8).withOpacity(0.1)),
          ),

          // 2. Konten Utama
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCustomAppBar(context),
                _buildHeroSection(),
                const SizedBox(height: 30),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(50),
                        topRight: Radius.circular(50),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x0D000000),
                          blurRadius: 30,
                          offset: Offset(0, -10),
                        )
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(50),
                        topRight: Radius.circular(50),
                      ),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(30, 40, 30, 100),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle("Market Insights"),
                            const SizedBox(height: 20),
                            _buildHighlightCard(),
                            const SizedBox(height: 35),
                            _buildSectionTitle("Main Services"),
                            const SizedBox(height: 20),
                            _buildModernGrid(),
                            const SizedBox(height: 35),
                            _buildSectionTitle("System Preferences"),
                            _buildSettingsList(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNav(0),
    );
  }

  // --- SUB WIDGETS ---

  Widget _buildCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _buildCustomAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("SKY STORE", 
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: Color(0xFF0369A1), letterSpacing: 1.5)),
              Text("Official Management", style: TextStyle(fontSize: 10, color: Colors.blueGrey, fontWeight: FontWeight.w600)),
            ],
          ),
          GestureDetector(
            onTap: () => _handleLogout(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [Color(0xFF38BDF8), Color(0xFF0369A1)]),
            ),
            child: const CircleAvatar(
              radius: 35,
              backgroundColor: Colors.white,
              child: Icon(Icons.person_3_rounded, size: 40, color: Color(0xFF0288D1)),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Welcome back,", style: TextStyle(color: Colors.blueGrey[400], fontSize: 14)),
                Text("$userName!", style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0284C7), Color(0xFF38BDF8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(color: const Color(0xFF0284C7).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Monthly Revenue", style: TextStyle(color: Colors.white70, fontSize: 14)),
          SizedBox(height: 5),
          Text("Rp 14.250.000", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Target: Rp 20jt", style: TextStyle(color: Colors.white60, fontSize: 12)),
              Icon(Icons.trending_up_rounded, color: Colors.white, size: 30),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      childAspectRatio: 1.1,
      children: [
        _buildGridItem(Icons.analytics_rounded, "Analytics", "Data report", Colors.purple),
        _buildGridItem(Icons.inventory_2_rounded, "Inventory", "Stock check", Colors.orange),
        _buildGridItem(Icons.people_alt_rounded, "Customers", "Loyalty info", Colors.blue),
        _buildGridItem(Icons.campaign_rounded, "Campaign", "Active ads", Colors.pink),
      ],
    );
  }

  Widget _buildGridItem(IconData icon, String title, String sub, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const Spacer(),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(sub, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, 
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)));
  }

  Widget _buildSettingsList() {
    return Column(
      children: [
        _tileItem(Icons.security_rounded, "System Security", "Protected"),
        _tileItem(Icons.notifications_active_rounded, "Notification Settings", "All on"),
      ],
    );
  }

  Widget _tileItem(IconData icon, String title, String status) {
    return Container(
      margin: const EdgeInsets.only(top: 15),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: Colors.blue[50], child: Icon(icon, color: Colors.blue[700], size: 20)),
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        trailing: Text(status, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 10)),
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        title: const Text("Log Out"),
        content: const Text("Are you sure you want to end this session?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
            onPressed: () => Navigator.pushAndRemoveUntil(
                context, MaterialPageRoute(builder: (context) => const LoginView()), (route) => false),
            child: const Text("Yes, Exit", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}