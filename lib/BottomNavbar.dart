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
    if (role == "admin") {
      if (index == 0) Navigator.pushReplacementNamed(context, '/dashboard');
      if (index == 1) Navigator.pushReplacementNamed(context, '/Toko');
    } else if (role == "user") {
      if (index == 0) Navigator.pushReplacementNamed(context, '/dashboard');
      if (index == 1) Navigator.pushReplacementNamed(context, '/pesan');
      if (index == 2) Navigator.pushReplacementNamed(context, '/history');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || role == null) return const SizedBox.shrink();

    List<Map<String, dynamic>> items = [];
    if (role == "admin") {
      items = [
        {'label': 'Home', 'icon': Icons.home_outlined, 'activeIcon': Icons.home},
        {'label': 'Toko', 'icon': Icons.storefront_outlined, 'activeIcon': Icons.storefront_rounded},
      ];
    } else {
      items = [
        {'label': 'Home', 'icon': Icons.home_outlined, 'activeIcon': Icons.home},
        {'label': 'Pesan', 'icon': Icons.shopping_bag_outlined, 'activeIcon': Icons.shopping_bag_rounded},
        {'label': 'History', 'icon': Icons.receipt_long_outlined, 'activeIcon': Icons.receipt_long_rounded},
      ];
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(items.length, (idx) {
          final bool isSelected = widget.activePage == idx;
          return GestureDetector(
            onTap: () => getLink(idx),
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 72,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isSelected ? items[idx]['activeIcon'] : items[idx]['icon'],
                    color: isSelected
                        ? const Color.fromARGB(255, 33, 38, 182)
                        : const Color.fromARGB(255, 28, 28, 30),
                    size: 26,
                  ),
                  if (isSelected) ...[
                    const SizedBox(height: 4),
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 33, 38, 182),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}