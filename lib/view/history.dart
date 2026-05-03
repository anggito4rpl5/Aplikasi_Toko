import 'package:flutter/material.dart';
import 'package:postman/BottomNavbar.dart';
import 'package:postman/models/History.dart';
import 'package:postman/services/pesan.dart';
import 'package:intl/intl.dart';

class HistoryView extends StatefulWidget {
  const HistoryView({super.key});
  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  static const Color navyBlue = Color(0xFF0A1628);
  static const Color oceanBlue = Color(0xFF1B3A6B);
  static const Color skyBlue = Color(0xFF2196F3);
  static const Color lightBlue = Color(0xFF64B5F6);

  List<HistoryModel> historyList = [];
  bool isLoading = true;

  final currencyFormatter =
      NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    ambilHistory();
  }

  Future<void> ambilHistory() async {
    setState(() => isLoading = true);
    final result = await Pesan().getHistory();
    if (!mounted) return;
    setState(() {
      historyList = result;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: navyBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Riwayat Transaksi',
          style: TextStyle(fontWeight: FontWeight.bold),
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
          IconButton(
            onPressed: ambilHistory,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: skyBlue),
            )
          : historyList.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long_outlined,
                          size: 80,
                          color: skyBlue.withValues(alpha: 0.4)),
                      const SizedBox(height: 16),
                      const Text(
                        'Belum Ada Transaksi',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: navyBlue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Riwayat checkout akan muncul di sini',
                        style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 14),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: ambilHistory,
                  color: skyBlue,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                    itemCount: historyList.length,
                    itemBuilder: (context, index) {
                      final item = historyList[index];
                      return _HistoryCard(          // ✅ passing HistoryModel
                        item: item,
                        currencyFormatter: currencyFormatter,
                      );
                    },
                  ),
                ),
      bottomNavigationBar: BottomNav(2),
    );
  }
}

// ─── CARD HISTORY ─────────────────────────────────────────
class _HistoryCard extends StatefulWidget {
  final HistoryModel item;                          // ✅ fix: HistoryModel bukan HistoryDetailModel
  final NumberFormat currencyFormatter;

  const _HistoryCard({required this.item, required this.currencyFormatter});

  @override
  State<_HistoryCard> createState() => _HistoryCardState();
}

class _HistoryCardState extends State<_HistoryCard> {
  bool isExpanded = false;

  static const Color navyBlue = Color(0xFF0A1628);
  static const Color skyBlue = Color(0xFF2196F3);
  static const Color lightBlue = Color(0xFF64B5F6);

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final formatter = widget.currencyFormatter;

    // ✅ hitung total dari details jika totalHarga null
    final int total = item.totalHarga ??
        (item.details ?? []).fold(
            0, (sum, d) => sum + ((d.harga ?? 0) * (d.qty ?? 1)));

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
      child: Column(
        children: [
          // ─── HEADER CARD ──────────────────────────────────
          GestureDetector(
            onTap: () => setState(() => isExpanded = !isExpanded),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [navyBlue, Color(0xFF1B3A6B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isExpanded ? 0 : 20),
                  bottomRight: Radius.circular(isExpanded ? 0 : 20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${item.id}',        // ✅ id_transaksi
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.tanggal ?? '-',         // ✅ tgl_transaksi
                        style: const TextStyle(
                            color: lightBlue, fontSize: 12),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.namaUser ?? '-',         // ✅ nama_user
                        style: const TextStyle(
                            color: lightBlue, fontSize: 12),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _statusColor(item.status)
                              .withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: _statusColor(item.status), width: 1),
                        ),
                        child: Text(
                          item.status ?? 'Proses',
                          style: TextStyle(
                            color: _statusColor(item.status),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: Colors.white70,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ─── DETAIL ITEMS (expandable) ────────────────────
          if (isExpanded) ...[
            if (item.details != null && item.details!.isNotEmpty)
              ...item.details!.map((detail) => Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            detail.image ?? '',
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: skyBlue.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.image_not_supported,
                                  color: skyBlue, size: 28),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                detail.namaBarang ?? '-',   // ✅ nama_barang
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: navyBlue,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${detail.qty}x  ${formatter.format(detail.harga ?? 0)}',  // ✅ quantity & harga_beli
                                style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          formatter.format(
                              (detail.harga ?? 0) * (detail.qty ?? 1)),
                          style: const TextStyle(
                            color: skyBlue,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ))
            else
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Tidak ada detail produk',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),

            // ─── TOTAL ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Pembayaran',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: navyBlue,
                    ),
                  ),
                  Text(
                    formatter.format(total),           // ✅ pakai variabel total
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: skyBlue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _statusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'selesai':
      case 'success':
        return Colors.green;
      case 'proses':
      case 'pending':
        return Colors.orange;
      case 'batal':
      case 'cancelled':
        return Colors.red;
      default:
        return skyBlue;
    }
  }
}