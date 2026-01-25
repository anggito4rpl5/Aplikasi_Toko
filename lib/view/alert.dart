import 'package:flutter/material.dart';

class AlertMessage {
  showAlert(BuildContext context, dynamic message, bool status) {
    // 1. Definisikan warna yang lebih modern dan lembut (Soft Palette)
    final Color primaryColor = status ? const Color(0xFF2E7D32) : const Color(0xFFD32F2F);
    final Color backgroundColor = status ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE);

    SnackBar snackBar = SnackBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      behavior: SnackBarBehavior.floating, // Membuat snackbar melayang
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20), // Memberi jarak dari pinggir layar
      duration: const Duration(seconds: 4),
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16), // Sudut lebih membulat (Modern)
          border: Border.all(color: primaryColor.withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            // 2. Icon yang berubah sesuai status
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                status ? Icons.check_circle_rounded : Icons.error_rounded,
                color: primaryColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            // 3. Pesan dengan Expanded agar tidak overflow (rusak layout)
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    status ? "Success" : "Error",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    message.toString(),
                    style: const TextStyle(
                      color: Color(0xFF455A64), // Grey tua yang lembut
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            // 4. Tombol Close yang minimalis
            IconButton(
              onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
              icon: Icon(Icons.close_rounded, color: primaryColor.withOpacity(0.5), size: 18),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );

    // Hapus snackbar yang sedang tampil sebelum menampilkan yang baru
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}