import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:postman/controllers/cart_provider.dart';
import 'package:postman/services/DBHelper.dart';
import 'package:postman/services/pesan.dart';
import 'package:postman/view/alert.dart';
import 'package:postman/view/plusminus.dart';
import 'package:intl/intl.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  var dBHelper = DBHelper();
  final cartProvider = CartProvider();

  static const Color navyBlue = Color(0xFF0A1628);
  static const Color oceanBlue = Color(0xFF1B3A6B);
  static const Color skyBlue = Color(0xFF2196F3);
  static const Color lightBlue = Color(0xFF64B5F6);

  @override
  void initState() {
    super.initState();
    updateCount();
  }

  Future<void> updateCount() async {
    await cartProvider.getData();
    if (!mounted) return;
    setState(() {
      cartProvider.counter = cartProvider.cart.length;
    });
  }

  Future<void> checkout() async {
    if (cartProvider.cart.isEmpty) {
      AlertMessage().showAlert(context, "Keranjang kosong", false);
      return;
    }

    List dataList = cartProvider.cart.map((i) {
      return {"barang_id": i.id, "qty": i.quantity};
    }).toList();

    var data = {"pesan": dataList};
    var result = await Pesan().saveToDB(data);

    if (!mounted) return;

    if (result.status == true) {
      await cartProvider.clearCart();
      if (!mounted) return;
      AlertMessage().showAlert(context, "Berhasil checkout", true);
      Navigator.pop(context);
    } else {
      AlertMessage().showAlert(context, "Gagal checkout", false);
    }
  }

  double get totalHarga {
    return cartProvider.cart.fold(
      0,
      (sum, item) => sum + ((item.harga ?? 0) * (item.quantity ?? 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter =
        NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: navyBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Keranjang',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [navyBlue, oceanBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          badges.Badge(
            position: badges.BadgePosition.topEnd(top: 2, end: 2),
            badgeStyle: const badges.BadgeStyle(
              badgeColor: skyBlue,
            ),
            badgeContent: ListenableBuilder(
              listenable: cartProvider,
              builder: (context, child) {
                return Text(
                  '${cartProvider.cart.isEmpty ? 0 : cartProvider.counter}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11),
                );
              },
            ),
            child: const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(Icons.shopping_cart_rounded, size: 28),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ─── HEADER INFO ──────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [navyBlue, oceanBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: ListenableBuilder(
              listenable: cartProvider,
              builder: (context, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${cartProvider.cart.length} Item',
                          style: const TextStyle(
                              color: lightBlue,
                              fontSize: 13),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          currencyFormatter.format(totalHarga),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3)),
                      ),
                      child: const Text(
                        'Total Belanja',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // ─── LIST CART ────────────────────────────────────
          Expanded(
            child: ListenableBuilder(
              listenable: cartProvider,
              builder: (context, child) {
                if (cartProvider.cart.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart_outlined,
                            size: 80,
                            color: skyBlue.withValues(alpha: 0.4)),
                        const SizedBox(height: 16),
                        const Text(
                          'Keranjang Kosong',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: oceanBlue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tambahkan barang ke keranjang',
                          style: TextStyle(
                              color: Colors.grey.shade500, fontSize: 14),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  itemCount: cartProvider.cart.length,
                  itemBuilder: (context, index) {
                    final item = cartProvider.cart[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: skyBlue.withValues(alpha: 0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            // Gambar
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.network(
                                item.image ?? '',
                                height: 80,
                                width: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => Container(
                                  height: 80,
                                  width: 80,
                                  decoration: BoxDecoration(
                                    color: lightBlue.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(Icons.broken_image,
                                      color: skyBlue, size: 36),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.nama_barang ?? '-',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: navyBlue,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    currencyFormatter.format(item.harga ?? 0),
                                    style: const TextStyle(
                                      color: skyBlue,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  // Subtotal
                                  Text(
                                    'Subtotal: ${currencyFormatter.format((item.harga ?? 0) * (item.quantity ?? 1))}',
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Kolom kanan: plus minus + delete
                            Column(
                              children: [
                                PlusMinusButtons(
                                  addQuantity: () =>
                                      cartProvider.addQuantity(item.id!),
                                  deleteQuantity: () =>
                                      cartProvider.deleteQuantity(item.id!),
                                  text: '${item.quantity ?? 0}',
                                ),
                                const SizedBox(height: 4),
                                GestureDetector(
                                  onTap: () =>
                                      cartProvider.removeItem(item.id!),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.delete_outline,
                                        color: Colors.red, size: 20),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      // ─── TOMBOL CHECKOUT ──────────────────────────────────
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: skyBlue.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SizedBox(
          height: 54,
          child: ElevatedButton.icon(
            onPressed: checkout,
            icon: const Icon(Icons.shopping_cart_checkout_rounded, size: 22),
            label: const Text(
              'Checkout Sekarang',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: navyBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ),
    );
  }
}