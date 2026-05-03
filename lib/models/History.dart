class HistoryModel {
  final int? id;
  final String? namaUser;
  final String? tanggal;
  final String? status;
  final int? totalHarga;
  final List<HistoryDetailModel>? details;

  HistoryModel({
    this.id,
    this.namaUser,
    this.tanggal,
    this.status,
    this.totalHarga,
    this.details,
  });

  factory HistoryModel.fromJson(Map<String, dynamic> json) {
    return HistoryModel(
      id: json['id_transaksi'],
      namaUser: json['nama_user'],
      tanggal: json['tgl_transaksi'],
      status: json['status'],
      totalHarga: json['total_harga'],
      details: json['detail'] != null
          ? List<HistoryDetailModel>.from(
              json['detail'].map((e) => HistoryDetailModel.fromJson(e)))
          : [],
    );
  }
}

class HistoryDetailModel {
  final int? id;
  final int? barangId;
  final String? namaBarang;
  final int? harga;
  final int? qty;
  final String? image;

  HistoryDetailModel({
    this.id,
    this.barangId,
    this.namaBarang,
    this.harga,
    this.qty,
    this.image,
  });

  factory HistoryDetailModel.fromJson(Map<String, dynamic> json) {
    return HistoryDetailModel(
      id: json['id_detail_transaksi'],
      barangId: json['barang_id'],
      namaBarang: json['nama_barang'],
      harga: json['harga_beli'],
      qty: json['quantity'],
      image: json['image'],
    );
  }
}