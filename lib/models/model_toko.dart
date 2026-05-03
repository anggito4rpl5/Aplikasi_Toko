import 'package:postman/services/url.dart' as url;

class TokoModel {
  int? id;
  String? nama_barang;
  String? deskripsi;
  int? stok;
  int? harga;
  String? image;

  TokoModel({
    required this.id,
    required this.nama_barang,
    this.deskripsi,
    this.stok,
    this.harga,
    this.image,
  });

  TokoModel.fromJson(Map<String, dynamic> parsedJson) {
    id = parsedJson["id"];
    nama_barang = parsedJson["nama_barang"];
    deskripsi = parsedJson["deskripsi"];
    stok = int.tryParse(parsedJson["stok"].toString());
    harga = int.tryParse(parsedJson["harga"].toString());
    image = "${url.BaseUrlTanpaApi}/${parsedJson["image"]}";
 
  }
  Map<String, dynamic> toMap()  {
  return {
      "id": id,
      "nama_barang": nama_barang,
      "deskripsi": deskripsi,
      "stok": stok,
      "harga": harga,
      "image": image,
};

}
}

