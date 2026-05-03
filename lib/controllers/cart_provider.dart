import 'package:flutter/material.dart';
import 'package:postman/models/Cart.dart';
import 'package:postman/services/DBHelper.dart';

class CartProvider extends ChangeNotifier {
  int counter = 0;
  final dBHelper = DBHelper();
  List<Cart> cart = [];

  // ─── GET DATA ─────────────────────────────────────────────
  Future<List<Cart>> getData() async {
    cart = await dBHelper.getCartList();
    counter = cart.length;
    notifyListeners();
    return cart;
  }

  // ─── COUNTER HELPERS ──────────────────────────────────────
  Future<void> addCounter() async {
    await getData();
  }

  Future<void> removeCounter() async {
    await getData();
  }

  Future<void> getCounter() async {
    await getData();
  }

  // ─── TAMBAH QUANTITY ──────────────────────────────────────
  Future<void> addQuantity(int id) async {
    final index = cart.indexWhere((element) => element.id == id);
    if (index == -1) return;

    cart[index].quantity = cart[index].quantity! + 1;

    await dBHelper.updateQuantity(
      cart[index].id!,
      cart[index].quantity!,
    );
    notifyListeners();
  }

  // ─── KURANGI QUANTITY ─────────────────────────────────────
  Future<void> deleteQuantity(int id) async {
    final index = cart.indexWhere((element) => element.id == id);
    if (index == -1) return;

    final currentQty = cart[index].quantity!;

    if (currentQty <= 1) {
      await removeItem(id);
      return;
    }

    cart[index].quantity = currentQty - 1;
    await dBHelper.updateQuantity(
      cart[index].id!,
      cart[index].quantity!,
    );
    notifyListeners();
  }

  // ─── HAPUS ITEM ───────────────────────────────────────────
  Future<void> removeItem(int id) async {
    await dBHelper.delete(id);

    final index = cart.indexWhere((element) => element.id == id);
    if (index != -1) {
      cart.removeAt(index);
    }

    counter = cart.length;
    notifyListeners();
  }

  // ─── CLEAR ALL CART ✅ ────────────────────────────────────
  Future<void> clearCart() async {
    await dBHelper.deleteAll();
    cart.clear();
    counter = 0;
    notifyListeners();
  }
}