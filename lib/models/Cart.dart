class Cart {
  late final int id;
  final String? nama_barang;
  final String? deskripsi;
  final int? harga;
  final String? image;
  int? quantity;

  Cart({
    required this.id,
    this.nama_barang,
    this.deskripsi,
    this.harga,
    this.image,
    this.quantity,
  });

  factory Cart.fromMap(Map<String, dynamic> data) {
    return Cart(
      id:          data['id'],
      nama_barang: data['nama_barang'],
      deskripsi:   data['deskripsi'],
      harga:       data['harga'],
      image:       data['image'],
      quantity:    data['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id':          id,
      'nama_barang': nama_barang,
      'deskripsi':   deskripsi,
      'harga':       harga,
      'image':       image,
      'quantity':    quantity,
    };
  }
}