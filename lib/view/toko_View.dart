import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:postman/BottomNavbar.dart';

class TokoView extends StatefulWidget {
  const TokoView({super.key});

  @override
  State<TokoView> createState() => _TokoViewState();
}

class _TokoViewState extends State<TokoView> {
  String selectedCategory = "All";
  final TextEditingController _searchController = TextEditingController();

  final List<String> categories = ["All", "Boards", "Apparel", "Essentials", "Gears"];

  // Data Barang Profesional - Fokus pada High-Quality Beach Products
  final List<Map<String, dynamic>> products = [
    {
      "name": "Hybrid Soft Top Surfboard",
      "price": "5.499.000",
      "tag": "BOARDS",
      "rating": 4.9,
      "img": "https://images.unsplash.com/photo-1531722569936-825d3dd91b15?q=80&w=500&auto=format&fit=crop"
    },
    {
      "name": "Titanium Diver Watch",
      "price": "12.800.000",
      "tag": "ESSENTIALS",
      "rating": 5.0,
      "img": "https://images.unsplash.com/photo-1523170335258-f5ed11844a49?q=80&w=500&auto=format&fit=crop"
    },
    {
      "name": "Quick-Dry Rash Guard",
      "price": "750.000",
      "tag": "APPAREL",
      "rating": 4.7,
      "img": "https://images.unsplash.com/photo-1551537482-f2075a1d41f2?q=80&w=500&auto=format&fit=crop"
    },
    {
       "name": "Casual Beach Sandals", // GANTI DISINI
      "price": "450.000",
      "tag": "GEARS",
      "rating": 4.8,
      "img": "https://images.unsplash.com/photo-1543163521-1bf539c55dd2?q=80&w=500&auto=format&fit=crop"
    },
    {
      "name": "Polarized Azure Shades",
      "price": "2.100.000",
      "tag": "ESSENTIALS",
      "rating": 4.9,
      "img": "https://images.unsplash.com/photo-1572635196237-14b3f281503f?q=80&w=500&auto=format&fit=crop"
    },
    {
      "name": "Heavy Duty Dry Bag",
      "price": "890.000",
      "tag": "GEARS",
      "rating": 4.6,
      "img": "https://images.unsplash.com/photo-1622560480605-d83c853bc5c3?q=80&w=500&auto=format&fit=crop"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFDFF),
      body: Stack(
        children: [
          // Background Aesthetic - Soft Blurs
          Positioned(top: -100, left: -50, child: _buildBlurCircle(Colors.blue[100]!)),
          Positioned(bottom: 100, right: -50, child: _buildBlurCircle(Colors.cyan[50]!)),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(),
              _buildSearchSection(),
              _buildCategories(),
              _buildProductList(),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ],
      ),
      bottomNavigationBar: const BottomNav(1),
      floatingActionButton: _buildProFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildBlurCircle(Color color) {
    return Container(
      width: 300, height: 300,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(0.4)),
      child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80), child: Container()),
    );
  }

  Widget _buildAppBar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(25, 60, 25, 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("DISCOVER", style: TextStyle(letterSpacing: 4, fontSize: 12, fontWeight: FontWeight.w800, color: Colors.blue[300])),
                const Text("Sky Ocean Gear", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1A1C1E))),
              ],
            ),
            _circleActionIcon(Icons.filter_list_rounded),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.blueGrey.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "Find professional equipment...",
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF0288D1)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 18),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return SliverToBoxAdapter(
      child: Container(
        height: 80,
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            bool isSelected = selectedCategory == categories[index];
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ChoiceChip(
                label: Text(categories[index]),
                selected: isSelected,
                onSelected: (val) => setState(() => selectedCategory = categories[index]),
                selectedColor: const Color(0xFF1A1C1E),
                backgroundColor: Colors.white,
                labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.blueGrey, fontWeight: FontWeight.bold, fontSize: 12),
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey[200]!),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProductList() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 25,
          crossAxisSpacing: 20,
          childAspectRatio: 0.65,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final item = products[index];
          return _buildProductCard(item);
        }, childCount: products.length),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              image: DecorationImage(image: NetworkImage(item['img']), fit: BoxFit.cover),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 8))],
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 15, right: 15,
                  child: ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                        child: const Icon(Icons.favorite_border_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(item['tag'], style: TextStyle(color: Colors.blue[400], fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1)),
        const SizedBox(height: 4),
        Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1A1C1E)), maxLines: 1),
        const SizedBox(height: 4),
        Text("Rp ${item['price']}", style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF0288D1))),
      ],
    );
  }

  Widget _circleActionIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Icon(icon, size: 22, color: const Color(0xFF1A1C1E)),
    );
  }

  Widget _buildProFAB() {
    return Container(
      height: 64, width: 64,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: [Color(0xFF1A1C1E), Color(0xFF43474E)], begin: Alignment.topLeft),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 15, offset: Offset(0, 8))],
      ),
      child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
    );
  }
}