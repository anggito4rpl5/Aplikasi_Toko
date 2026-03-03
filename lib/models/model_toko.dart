import 'package:postman/services/url.dart' as url;

class TokoModel {
  int? id;
  String? nama_barang;
  String? deskripsi;
  int? stok;
  String? image;
  int? harga;
  TokoModel({
    required this.id,
    required this.nama_barang,
    this.deskripsi,
    this.stok,
    this.image,
    this.harga,
  });

  TokoModel.fromJson(Map<String, dynamic> parsedJson) {
    id = parsedJson["id"];
    nama_barang = parsedJson["nama_barang"];
    deskripsi = parsedJson["deskripsi"];
    stok = int.tryParse(parsedJson["stok"].toString());
    image = "${url.BaseUrlTanpaApi}/${parsedJson["image"]}";
    harga = int.tryParse(parsedJson["harga"].toString());
  }
}
