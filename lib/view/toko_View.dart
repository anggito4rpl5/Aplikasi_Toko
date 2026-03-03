import 'package:flutter/material.dart';
import 'package:postman/services/Toko.dart';

class TokoView extends StatefulWidget {
  const TokoView({super.key});

  @override
  State<TokoView> createState() => _TokoViewState();
}

class _TokoViewState extends State<TokoView> {
  List? toko;
  TokoService service = TokoService();

  static const Color skyBlue = Color(0xFF4FC3F7);

  @override
  void initState() {
    super.initState();
    ambilData();
  }

  Future<void> ambilData() async {
    try {
      final response = await service.getToko();
      setState(() {
        toko = response.data;
      });
    } catch (e) {
      debugPrint("Error saat mengambil data: $e");
      setState(() {
        toko = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Daftar Toko",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: skyBlue,
        centerTitle: true,
        elevation: 0,
      ),
      body: toko != null
          ? toko!.isEmpty
              ? const Center(
                  child: Text(
                    "Data toko kosong",
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: toko!.length,
                  itemBuilder: (context, index) {
                    final item = toko![index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 4,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            item.image ?? "",
                            width: 55,
                            height: 55,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              width: 55,
                              height: 55,
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          item.nama_barang ?? "Tanpa Nama",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: skyBlue,
                        ),
                      ),
                    );
                  },
                )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}