import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:postman/BottomNavbar.dart';
import 'package:postman/services/DBHelper.dart';
import 'package:postman/models/Cart.dart';
import 'package:postman/services/toko.dart';
import 'package:postman/controllers/cart_provider.dart';
import 'package:intl/intl.dart';

class PesanView extends StatefulWidget {
  const PesanView({super.key});
  @override
  State<PesanView> createState() => _PesanViewState();
}

class _PesanViewState extends State<PesanView> {
  var dBHelper = DBHelper();
  final cartProvider = CartProvider();
  List? barang;
  List? filteredBarang;
  TextEditingController searchController = TextEditingController();

  double totalHarga = 0;
  bool showTotalBar = false;

  @override
  void initState() {
    super.initState();
    getBarang();
    updateCount();
  }

  Future<void> getBarang() async {
    var result = await TokoService().getBarang();
    if (!mounted) return;
    setState(() {
      if (result.status == true) {
        barang = result.data;
        filteredBarang = result.data;
      }
    });
  }

  void filterSearch(String query) {
    setState(() {
      filteredBarang = barang!
          .where((item) =>
              item.nama_barang.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  // ✅ updateCount selalu reset total & showTotalBar
  Future<void> updateCount() async {
    await cartProvider.getData();
    double total = 0;
    for (var item in cartProvider.cart) {
      total += (item.harga ?? 0) * (item.quantity ?? 1);
    }
    if (!mounted) return;
    setState(() {
      cartProvider.counter = cartProvider.cart.length;
      totalHarga = total;
      showTotalBar = cartProvider.cart.isNotEmpty;
    });
  }

  Future<void> saveData(int index) async {
    var item = filteredBarang![index];

    if ((item.stok ?? 0) <= 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item.nama_barang} stok habis'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    var detail = await dBHelper.getCartListDetail(item.id);
    var qty =
        (detail != null && detail.isNotEmpty) ? detail[0].quantity ?? 0 : 0;

    await dBHelper.insert(
      Cart(
        id: item.id,
        nama_barang: item.nama_barang,
        deskripsi: item.deskripsi,
        harga: item.harga,
        image: item.image,
        quantity: qty + 1,
      ),
    );

    await updateCount();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
                child: Text('${item.nama_barang} ditambah ke keranjang ✓')),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(15, 0, 15, 80),
        backgroundColor: Colors.green,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ✅ Navigasi ke cart + refresh setelah kembali
  Future<void> bukaCart() async {
    await Navigator.pushNamed(context, '/cart');
    if (mounted) updateCount();
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF0D1B3E);
    final currencyFormatter =
        NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text('Toko Taka',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
        actions: [
          badges.Badge(
            position: badges.BadgePosition.topEnd(top: 0, end: 2),
            badgeContent: ListenableBuilder(
              listenable: cartProvider,
              builder: (context, child) {
                return Text(
                  '${cartProvider.counter}',
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                );
              },
            ),
            // ✅ Pakai bukaCart() agar refresh setelah balik
            child: IconButton(
              onPressed: bukaCart,
              icon: const Icon(Icons.shopping_bag_outlined),
            ),
          ),
          const SizedBox(width: 15),
        ],
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [primaryBlue, Color(0xFF1A237E), Colors.black],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: kToolbarHeight + 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: searchController,
                onChanged: filterSearch,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Cari produk kesukaanmu...",
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(Icons.search, color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
        Expanded(
  child: filteredBarang != null
      ? GridView.builder(
          padding: const EdgeInsets.fromLTRB(15, 0, 15, 100),
          // Mengatur jumlah kolom dan jarak antar card
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 kolom seperti website mobile
            childAspectRatio: 0.68, // Mengatur tinggi card (sesuaikan jika teks terpotong)
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: filteredBarang!.length,
          itemBuilder: (context, index) {
            final item = filteredBarang![index];
            final bool habis = (item.stok ?? 0) <= 0;

            return Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bagian Gambar
                  Expanded(
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                          child: Image.network(
                            item.image,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => const Center(
                              child: Icon(Icons.image_not_supported, color: Colors.white24),
                            ),
                          ),
                        ),
                        if (habis)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                            ),
                            child: const Center(
                              child: Text("STOK HABIS", 
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Bagian Detail Produk
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.nama_barang,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currencyFormatter.format(item.harga),
                          style: const TextStyle(
                              color: Colors.lightBlueAccent,
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              habis ? "Habis" : "Stok: ${item.stok}",
                              style: TextStyle(
                                  color: habis ? Colors.redAccent : Colors.white54,
                                  fontSize: 11),
                            ),
                            GestureDetector(
                              onTap: habis ? null : () => saveData(index),
                              child: Icon(
                                Icons.add_circle,
                                color: habis ? Colors.white24 : Colors.blueAccent,
                                size: 30,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        )
      : const Center(
          child: CircularProgressIndicator(color: Colors.white)),
),

            // ✅ Popup total harga — onTap pakai bukaCart()
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: showTotalBar ? 60 : 0,
              child: showTotalBar
                  ? GestureDetector(
                      onTap: bukaCart, // ✅ refresh setelah balik
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(15, 0, 15, 8),
                        padding:
                            const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF1565C0),
                              Color(0xFF0D47A1)
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.shopping_cart,
                                    color: Colors.white, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  '${cartProvider.counter} item',
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 13),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  currencyFormatter.format(totalHarga),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward_ios,
                                    color: Colors.white70, size: 14),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNav(1),
    );
  }
}