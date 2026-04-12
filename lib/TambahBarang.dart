import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // 1. Tambahkan import ini
import 'package:postman/models/model_toko.dart';
import 'package:postman/services/Toko.dart';
import 'package:postman/view/alert.dart';

class Tambahbarang extends StatefulWidget {
  final String title; // Gunakan final untuk variabel di widget
  final TokoModel? item;
  Tambahbarang(this.title, this.item, {super.key});

  @override
  State<Tambahbarang> createState() => _TambahbarangState();
}

class _TambahbarangState extends State<Tambahbarang> {
  TokoService service = TokoService();
  final formKey = GlobalKey<FormState>();

  TextEditingController id = TextEditingController();
  TextEditingController nama_barang = TextEditingController();
  TextEditingController deskripsi = TextEditingController();
  TextEditingController stok = TextEditingController();
  TextEditingController image = TextEditingController();
  TextEditingController harga = TextEditingController();

  File? selectedImage;
  bool isLoading = false; // Gunakan bool biasa, jangan bool?

  // 2. Perbaiki fungsi getImage (tidak menumpuk)
  Future getImage() async {
    final ImagePicker picker = ImagePicker();

    // Pick an image
    final XFile? img = await picker.pickImage(source: ImageSource.gallery);

    if (img != null) {
      // 3. Cek null agar tidak crash
      setState(() {
        selectedImage = File(img.path);
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.item != null) {
      id.text = widget.item!.id!.toString();
      nama_barang.text = widget.item!.nama_barang!;
      deskripsi.text = widget.item!.deskripsi!;
      stok.text = widget.item!.stok!.toString();
      image.text = widget.item!.image!;
      harga.text = widget.item!.harga!.toString();
      selectedImage = null;
    } else {
      id.clear();
      nama_barang.clear();
      deskripsi.clear();
      stok.clear();
      image.clear();
      harga.clear();
      selectedImage = null;
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
        child: Container(
          margin: EdgeInsets.all(10),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: id,
                  decoration: InputDecoration(label: Text("id")),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'harus diisi';
                    } else {
                      return null;
                    }
                  },
                ),
                TextFormField(
                  controller: nama_barang,
                  decoration: InputDecoration(label: Text("Nama Barang")),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'harus diisi';
                    } else {
                      return null;
                    }
                  },
                ),
                TextFormField(
                  controller: deskripsi,
                  decoration: InputDecoration(label: Text("Deskripsi")),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'harus diisi';
                    } else {
                      return null;
                    }
                  },
                ),
                TextFormField(
                  controller: stok,
                  decoration: InputDecoration(label: Text("Stok")),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'harus diisi';
                    } else {
                      return null;
                    }
                  },
                ),
                TextFormField(
                  controller: harga,
                  decoration: InputDecoration(label: Text("Harga")),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'harus diisi';
                    } else {
                      return null;
                    }
                  },
                ),
                TextButton(
                  onPressed: () {
                    getImage();
                  },
                  child: Text("Select Picture"),
                ),  
                selectedImage != null
                    ? Container(
                        width: MediaQuery.of(context).size.width,
                        child: Image.file(selectedImage!),
                      )
                    : isLoading == true
                    ? CircularProgressIndicator()
                    : Center(child: Text("Please Get the Images")),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      var data = {
                        "title": nama_barang.text,
                        "deskripsi": deskripsi.text,
                        "stok": stok.text,
                        "harga": harga.text,
                      };
                      var result;
                      if (widget.item != null) {
                        result = await service.insertToko(
                          data,
                          selectedImage,
                          widget.item!.id,
                        );
                      } else {
                        result = await service.insertToko(
                          data,
                          selectedImage,
                          null,
                        );
                      }

                      if (result.status == true) {
                        AlertMessage().showAlert(context, result.message, true);
                        Navigator.pop(context);
                        Navigator.pushReplacementNamed(context, '/TokoView');
                      } else {
                        AlertMessage().showAlert(
                          context,
                          result.message,
                          false,
                        );
                      }
                    }
                  },
                  child: Text("Simpan"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
