import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:postman/models/model_toko.dart';
import 'package:postman/services/Toko.dart';
import 'package:postman/view/alert.dart';

class Tambahbarang extends StatefulWidget {
  final String title;
  final TokoModel? item;
  const Tambahbarang(this.title, this.item, {super.key});

  @override
  State<Tambahbarang> createState() => _TambahbarangState();
}

class _TambahbarangState extends State<Tambahbarang> {
  TokoService service = TokoService();
  final formKey = GlobalKey<FormState>();

  final TextEditingController namaBarangCtrl = TextEditingController();
  final TextEditingController deskripsiCtrl = TextEditingController();
  final TextEditingController stokCtrl = TextEditingController();
  final TextEditingController hargaCtrl = TextEditingController();

  File? selectedImage;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      namaBarangCtrl.text = widget.item!.nama_barang ?? '';
      deskripsiCtrl.text = widget.item!.deskripsi ?? '';
      stokCtrl.text = widget.item!.stok?.toString() ?? '';
      hargaCtrl.text = widget.item!.harga?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    namaBarangCtrl.dispose();
    deskripsiCtrl.dispose();
    stokCtrl.dispose();
    hargaCtrl.dispose();
    super.dispose();
  }

  Future<void> getImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? img = await picker.pickImage(source: ImageSource.gallery);
    if (img != null) {
      setState(() {
        selectedImage = File(img.path);
      });
    }
  }

  Future<void> simpanData() async {
    if (!formKey.currentState!.validate()) return;

    // Validasi gambar untuk tambah baru
    if (widget.item == null && selectedImage == null) {
      AlertMessage().showAlert(context, "Silakan pilih gambar terlebih dahulu", false);
      return;
    }

    final data = {
      "nama_barang": namaBarangCtrl.text.trim(),
      "deskripsi": deskripsiCtrl.text.trim(),
      "stok": stokCtrl.text.trim(),
      "harga": hargaCtrl.text.trim(),
    };

    setState(() => isLoading = true);

    try {
      final String? id = widget.item?.id?.toString();
      
      debugPrint("=== SIMPAN DATA ===");
      debugPrint("ID: $id");
      debugPrint("Nama Barang: ${data['nama_barang']}");
      debugPrint("Deskripsi: ${data['deskripsi']}");
      debugPrint("Stok: ${data['stok']}");
      debugPrint("Harga: ${data['harga']}");
      debugPrint("Ada gambar: ${selectedImage != null}");
      
      final result = await service.insertToko(
        data,
        selectedImage,
        id,
      );

      if (!mounted) return;
      setState(() => isLoading = false);

      if (result.status == true) {
        AlertMessage().showAlert(context, result.message, true);
        Navigator.pop(context, true);
      } else {
        AlertMessage().showAlert(context, result.message, false);
      }
    } catch (e) {
      debugPrint("Error simpanData: $e");
      if (!mounted) return;
      setState(() => isLoading = false);
      AlertMessage().showAlert(context, 'Terjadi kesalahan: $e', false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                controller: namaBarangCtrl,
                decoration: const InputDecoration(
                  labelText: "Nama Barang",
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Harus diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: deskripsiCtrl,
                decoration: const InputDecoration(
                  labelText: "Deskripsi",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (v) => v == null || v.isEmpty ? 'Harus diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: stokCtrl,
                decoration: const InputDecoration(
                  labelText: "Stok",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'Harus diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: hargaCtrl,
                decoration: const InputDecoration(
                  labelText: "Harga",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'Harus diisi' : null,
              ),
              const SizedBox(height: 16),

              // Pilih gambar
              Container(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: getImage,
                  icon: const Icon(Icons.image),
                  label: const Text("Pilih Gambar"),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.all(12),
                    backgroundColor: Colors.grey[100],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              
              // Preview gambar
              if (selectedImage != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    selectedImage!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                )
              else if (widget.item?.image != null && widget.item!.image!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    widget.item!.image!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 200,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported, size: 60),
                    ),
                  ),
                )
              else
                Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: const Center(
                    child: Text(
                      "Belum ada gambar dipilih",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              // Tombol simpan
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 66, 140, 68),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: isLoading ? null : simpanData,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text("Simpan"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}