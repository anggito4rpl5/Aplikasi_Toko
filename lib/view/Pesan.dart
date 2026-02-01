import 'package:flutter/material.dart';
import 'package:postman/BottomNavbar.dart';

class PesanView extends StatefulWidget {
  const PesanView({super.key});

  @override
  State<PesanView> createState() => _PesanViewState();
}

class _PesanViewState extends State<PesanView> {
  final Color primaryBlue = const Color(0xFF0288D1);
  final Color skyBlue = const Color(0xFF0EA5E9);
  final Color lightBlueBg = const Color(0xFFF8FAFC);

  List<Map<String, dynamic>> orders = [
    {
      "id": "TRX-003",
      "nama": "Ahmad Fauzi",
      "item": "Jelly Lemon Premium",
      "qty": "2x",
      "harga": "30.000",
      "total": "60.000",
      "status": "Selesai",
      "tanggal": "10 Feb 2026",
    },
    {
      "id": "TRX-004",
      "nama": "Siti Aminah",
      "item": "Jelly Strawberry Glossy",
      "qty": "1x",
      "harga": "25.000",
      "total": "25.000",
      "status": "Belum Dikirim",
      "tanggal": "11 Feb 2026",
    },
    {
      "id": "TRX-005",
      "nama": "Budi Santoso",
      "item": "Jelly Mix Berry",
      "qty": "3x",
      "harga": "30.000",
      "total": "90.000",
      "status": "Dikirim",
      "tanggal": "12 Feb 2026",
    },
  ];

  void updateOrderStatus(int index, String newStatus) {
    setState(() {
      orders[index]['status'] = newStatus;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Status ${orders[index]['id']} diperbarui: $newStatus"),
        backgroundColor: skyBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBlueBg,
      body: Stack(
        children: [
          // Background Gradient Dekoratif agar tidak sepi
          Container(
            height: 220,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryBlue, skyBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildSimpleAppBar(),
                _buildHeaderStats(),
                _buildCategoryFilter(),
                Expanded(
                  child: orders.isEmpty 
                    ? _buildEmptyState() 
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                        itemCount: orders.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) => _buildModernTransactionCard(index, orders[index]),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNav(1),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.white,
        child: Icon(Icons.add_rounded, color: primaryBlue, size: 30),
      ),
    );
  }

  Widget _buildSimpleAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Daftar Pesanan", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              Text("Manajemen transaksi harian", style: TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.search_rounded, color: Colors.white),
          )
        ],
      ),
    );
  }

  Widget _buildHeaderStats() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem("12", "Proses", Icons.sync_rounded, Colors.orange),
          _statItem("Rp 2.4jt", "Omzet", Icons.payments_rounded, Colors.green),
          _statItem("156", "Selesai", Icons.check_circle_rounded, primaryBlue),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(height: 10),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    List<String> categories = ["Semua", "Belum Kirim", "Dikirim", "Selesai"];
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          bool isSelected = index == 0;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(15),
              border: isSelected ? null : Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            alignment: Alignment.center,
            child: Text(
              categories[index],
              style: TextStyle(color: isSelected ? primaryBlue : Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          );
        },
      ),
    );
  }

  Widget _buildModernTransactionCard(int index, Map<String, dynamic> data) {
    Color statusColor = data['status'] == "Selesai" ? Colors.green : data['status'] == "Dikirim" ? Colors.orange : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data['id'], style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
                  Text(data['nama'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              _buildStatusBadge(data['status'], statusColor),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Divider(thickness: 1, height: 1),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: primaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.inventory_2_rounded, color: primaryBlue, size: 20),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data['item'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text("${data['qty']} unit - Rp ${data['harga']}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _actionIcon(Icons.timer_rounded, Colors.red, () => updateOrderStatus(index, "Belum Dikirim")),
                  const SizedBox(width: 10),
                  _actionIcon(Icons.local_shipping_rounded, Colors.orange, () => updateOrderStatus(index, "Dikirim")),
                  const SizedBox(width: 10),
                  _actionIcon(Icons.check_circle_rounded, Colors.green, () => updateOrderStatus(index, "Selesai")),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text("Total Tagihan", style: TextStyle(fontSize: 10, color: Colors.grey)),
                  Text("Rp ${data['total']}", style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _actionIcon(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10)),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.auto_stories_rounded, size: 80, color: primaryBlue.withOpacity(0.2)),
        const SizedBox(height: 20),
        const Text("Belum ada pesanan masuk", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
      ],
    );
  }
}