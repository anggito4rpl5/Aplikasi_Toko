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
  static const Color darkBlue = Color(0xFF0288D1);

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
      debugPrint("Error: $e");
      setState(() {
        toko = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAFD),
      appBar: AppBar(
        title: const Text(
          "Daftar Toko",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: skyBlue,
        elevation: 0,
      ),
      body: toko == null
          ? const Center(
              child: CircularProgressIndicator(color: skyBlue),
            )
          : toko!.isEmpty
              ? const Center(
                  child: Text(
                    "Data toko kosong",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: toko!.length,
                  itemBuilder: (context, index) {
                    final item = toko![index];

                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // IMAGE
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(18),
                            ),
                            child: Image.network(
                              item.image ?? "",
                              height: 130,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                height: 130,
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.image_not_supported,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),

                          // CONTENT
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.nama_barang ?? "Tanpa Nama",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.storefront,
                                      size: 16,
                                      color: skyBlue,
                                    ),
                                    const SizedBox(width: 6),
                                    const Text(
                                      "Detail toko",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: skyBlue.withOpacity(0.15),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 14,
                                        color: darkBlue,
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}