import 'package:flutter/material.dart';
import 'package:postman/view/login_view.dart';

class DashboardView extends StatelessWidget {
  // Jika Anda mengirim data dari halaman sebelumnya, tambahkan parameter di sini
  final String? userName;
  final String? userRole;

  const DashboardView({
    super.key, 
    this.userName = "User", // Default jika data kosong
    this.userRole = "Guest", 
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SKY STORE DASHBOARD", 
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF0288D1),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0288D1), Color(0xFFE0F7FA)],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 40),
            
            // Profil Section
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 60, color: Color(0xFF0288D1)),
            ),
            const SizedBox(height: 20),

            // Menampilkan Nama
            Text(
              "Welcome, $userName!",
              style: const TextStyle(
                fontSize: 24, 
                fontWeight: FontWeight.bold, 
                color: Colors.white
              ),
            ),
            const SizedBox(height: 8),

            // Menampilkan Role dengan Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white),
              ),
              child: Text(
                "Role: ${userRole?.toUpperCase()}",
                style: const TextStyle(
                  fontWeight: FontWeight.w600, 
                  color: Color(0xFF01579B)
                ),
              ),
            ),

            const SizedBox(height: 50),

            // Isi Dashboard (Contoh)
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Your Activity",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    _buildMenuTile(Icons.shopping_bag, "My Orders"),
                    _buildMenuTile(Icons.favorite, "Wishlist"),
                    _buildMenuTile(Icons.settings, "Account Settings"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Helper untuk Menu
  Widget _buildMenuTile(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF0288D1)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {},
    );
  }

  // LOGIKA LOGOUT
  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Apakah Anda yakin ingin keluar dari aplikasi?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () {
              // Menghapus semua riwayat halaman dan kembali ke Login
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginView()),
                (route) => false,
              );
            },
            child: const Text("Ya, Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}