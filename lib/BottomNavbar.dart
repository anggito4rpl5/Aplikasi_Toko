import 'package:flutter/material.dart';
import 'package:postman/models/user_login.dart';
import 'package:postman/services/user.dart';

class BottomNav extends StatefulWidget {
  final int activePage;
  const BottomNav(this.activePage, {super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  final UserService userService = UserService();
  String? role;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getDataLogin();
  }

  Future<void> getDataLogin() async {
    try {
      UserLogin? user = await userService.getUserLogin();
      if (!mounted) return;
      if (user != null && user.status != false) {
        setState(() {
          role = user.role;
          isLoading = false;
        });
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      if (mounted) Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void getLink(int index) {
    if (index == widget.activePage) return;
    
    // Logika Navigasi Persis Sesuai Modul
    if (role == "admin") {
      if (index == 0) Navigator.pushReplacementNamed(context, '/dashboard');
      else if (index == 1) Navigator.pushReplacementNamed(context, '/Toko'); 
    } else if (role == "user") {
      if (index == 0) Navigator.pushReplacementNamed(context, '/dashboard');
      else if (index == 1) Navigator.pushReplacementNamed(context, '/pesan');
   
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || role == null) return const SizedBox.shrink();

    // Menentukan daftar item berdasarkan role (Seperti logika Modul)
    List<Map<String, dynamic>> items = [];
    if (role == "admin") {
      items = [
        {'label': 'Home', 'icon': Icons.grid_view_rounded},
        {'label': 'Toko', 'icon': Icons.storefront_rounded},
      ];
    } else if (role == "kasir") {
      items = [
        {'label': 'Home', 'icon': Icons.grid_view_rounded},
        {'label': 'Pesan', 'icon': Icons.receipt_long_rounded},
      ];
    } else {
      // Default untuk role user atau lainnya
      items = [
        {'label': 'Home', 'icon': Icons.grid_view_rounded},
        {'label': 'Katalog', 'icon': Icons.beach_access_rounded},
      ];
    }

    double screenWidth = MediaQuery.of(context).size.width;
    double navWidth = screenWidth - 60;
    double itemWidth = navWidth / items.length;

    // Render UI Premium dengan Logika Role
    return Container(
      margin: const EdgeInsets.fromLTRB(30, 0, 30, 35),
      height: 65,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0EA5E9).withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // HIGHLIGHT CAPSULE
          AnimatedPositioned(
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            left: (widget.activePage * itemWidth) + (itemWidth / 2) - 45,
            child: Container(
              width: 90,
              height: 42,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
                ),
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
          
          // ICONS
          Row(
            children: List.generate(items.length, (idx) {
              bool isSelected = widget.activePage == idx;
              return Expanded(
                child: GestureDetector(
                  onTap: () => getLink(idx),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        items[idx]['icon'],
                        color: isSelected ? Colors.white : const Color(0xFF0369A1).withOpacity(0.4),
                        size: 24,
                      ),
                      if (isSelected)
                        Text(
                          items[idx]['label'],
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}