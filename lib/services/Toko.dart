import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:postman/models/Cart.dart';
import 'package:postman/models/model_toko.dart';
import 'package:postman/models/response_data_list.dart';
import 'package:postman/models/response_data_map.dart';
import 'package:postman/models/user_login.dart';
import 'package:postman/services/url.dart' as url;

class TokoService {
  // ─── GET TOKO ───────────────────────────────────────────────
  Future<ResponseDataList> getToko() async {
    try {
      final user = await UserLogin().getUserLogin();
      if (user.status == false) {
        return ResponseDataList(status: false, message: 'Anda belum login');
      }

      final uri = Uri.parse("${url.BaseUrl}/admin/getbarang");
      final headers = {"Authorization": 'Bearer ${user.token}'};
      final res = await http.get(uri, headers: headers);

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data["status"] == true) {
          final List items = data["data"]
              .map((r) => TokoModel.fromJson(r))
              .toList();
          return ResponseDataList(
            status: true,
            message: 'Berhasil load data',
            data: items,
          );
        }
        return ResponseDataList(status: false, message: 'Gagal load data');
      }
      return ResponseDataList(
        status: false,
        message: 'Gagal dengan kode error ${res.statusCode}',
      );
    } catch (e) {
      return ResponseDataList(status: false, message: 'Koneksi gagal: $e');
    }
  }

  // ─── INSERT / UPDATE TOKO ───────────────────────────────────
  Future<dynamic> insertToko(
    Map<String, dynamic> request,
    File? image,
    String? id,
  ) async {
    try {
      final user = await UserLogin().getUserLogin();
      if (user.status == false) {
        return ResponseDataMap(
          status: false,
          message: 'Anda belum login / token invalid',
        );
      }

      final endpoint = id == null
          ? Uri.parse("${url.BaseUrl}/admin/insertbarang")
          : Uri.parse("${url.BaseUrl}/admin/updatebarang/$id");

      final req = http.MultipartRequest('POST', endpoint);
      req.headers.addAll({"Authorization": 'Bearer ${user.token}'});

      req.fields['nama_barang'] = request["nama_barang"]?.toString() ?? '';
      req.fields['deskripsi'] = request["deskripsi"]?.toString() ?? '';
      req.fields['stok'] = request["stok"]?.toString() ?? '';
      req.fields['harga'] = request["harga"]?.toString() ?? '';

      // fix: pakai fromPath agar tidak hang saat upload gambar besar
      if (image != null) {
        req.files.add(await http.MultipartFile.fromPath('image', image.path));
      }

      final streamedRes = await req.send();
      final result = await http.Response.fromStream(streamedRes);

      if (streamedRes.statusCode == 200) {
        final data = json.decode(result.body);
        if (data["status"] == true) {
          return ResponseDataMap(
            status: true,
            message: data["message"] ?? 'Berhasil simpan data',
          );
        }
        return ResponseDataMap(
          status: false,
          message: data["message"] ?? 'Gagal simpan data',
        );
      }
      return ResponseDataMap(
        status: false,
        message: 'Gagal dengan kode error ${streamedRes.statusCode}',
      );
    } catch (e) {
      return ResponseDataMap(status: false, message: 'Koneksi gagal: $e');
    }
  }

  // ─── INSERT / UPDATE MOVIE ──────────────────────────────────
  Future<dynamic> insertMovie(
    Map<String, dynamic> request,
    File? image,
    String? id,
  ) async {
    try {
      final user = await UserLogin().getUserLogin();
      if (user.status == false) {
        return ResponseDataMap(
          status: false,
          message: 'Anda belum login / token invalid',
        );
      }

      final endpoint = id == null
          ? Uri.parse("${url.BaseUrl}/admin/insertbarang")
          : Uri.parse("${url.BaseUrl}/admin/updatebarang/$id");

      final req = http.MultipartRequest('POST', endpoint);
      req.headers.addAll({"Authorization": 'Bearer ${user.token}'});

      req.fields['nama_barang'] = request["nama_barang"]?.toString() ?? '';
      req.fields['deskripsi'] = request["deskripsi"]?.toString() ?? '';
      req.fields['stok'] = request["stok"]?.toString() ?? '';
      req.fields['harga'] = request["harga"]?.toString() ?? '';

      // fix: pakai fromPath agar tidak hang saat upload gambar besar
      if (image != null) {
        req.files.add(await http.MultipartFile.fromPath('image', image.path));
      }

      final streamedRes = await req.send();
      final result = await http.Response.fromStream(streamedRes);

      if (streamedRes.statusCode == 200) {
        final data = json.decode(result.body);
        if (data["status"] == true) {
          return ResponseDataMap(
            status: true,
            message: data["message"] ?? 'Berhasil simpan movie',
          );
        }
        return ResponseDataMap(
          status: false,
          message: data["message"] ?? 'Gagal simpan movie',
        );
      }
      return ResponseDataMap(
        status: false,
        message: 'Gagal dengan kode error ${streamedRes.statusCode}',
      );
    } catch (e) {
      return ResponseDataMap(status: false, message: 'Koneksi gagal: $e');
    }
  }

  // ─── HAPUS BARANG ───────────────────────────────────────────
  Future<dynamic> hapusBarang(String id) async {
    try {
      debugPrint("Menghapus barang dengan ID: $id"); // Debug

      final user = await UserLogin().getUserLogin();
      if (user.status == false) {
        return ResponseDataList(
          status: false,
          message: 'Anda belum login / token invalid',
        );
      }

      final uri = Uri.parse("${url.BaseUrl}/admin/hapusbarang/$id");
      debugPrint("URL Delete: $uri"); // Debug

      final headers = {"Authorization": 'Bearer ${user.token}'};
      final res = await http.delete(uri, headers: headers);

      debugPrint("Response status: ${res.statusCode}"); // Debug
      debugPrint("Response body: ${res.body}"); // Debug

      if (res.statusCode == 200) {
        final result = json.decode(res.body);
        if (result["status"] == true) {
          return ResponseDataList(
            status: true,
            message: result["message"] ?? 'Berhasil hapus data',
          );
        }
        return ResponseDataList(
          status: false,
          message: result["message"] ?? 'Gagal hapus data',
        );
      }
      return ResponseDataList(
        status: false,
        message: 'Gagal hapus dengan kode error ${res.statusCode}',
      );
    } catch (e) {
      debugPrint("Error hapusBarang: $e");
      return ResponseDataList(status: false, message: 'Koneksi gagal: $e');
    }
  }
  Future getBaranguUser () async {
   
  var uri = Uri.parse(url.BaseUrl + "/user/getbarang");
  var user = await UserLogin().getUserLogin();
  if (user.status == false) {
    ResponseDataList response = ResponseDataList(
      status: false,
      message: 'anda belum login / token invalid',
    );
    return response;
  }
  Map<String, String> headers = {"Authorization": 'Bearer ${user.token}'};
  var getBarang = await http.get(uri, headers: headers);


  if (getBarang.statusCode == 200) {
    var data = json.decode(getBarang.body);
    if (data["status"] == true) {
      List cart = data["data"].map((r) => Cart.fromMap(r)).toList();
      ResponseDataList response = ResponseDataList(
        status: true,
        message: 'success load data',
        data: cart,
      );
      return response;
    } else {
      ResponseDataList response = ResponseDataList(
        status: false,
        message: 'Failed load data',
      );
      return response;
    }
  } else {
    ResponseDataList response = ResponseDataList(
      status: false,
      message: "gagal load barang dengan code error ${getBarang.statusCode}",
    );
    return response;
  }
}

Future getBarang() async {
  var uri = Uri.parse(url.BaseUrl + "/user/getbarang");
  final userLogin = UserLogin();
  final user = await userLogin.getUserLogin();
  if (user.status == false) {
    ResponseDataList response = ResponseDataList(
      status: false,  
      message: 'anda belum login / token invalid',
    );
    return response;
  }
  Map<String, String> headers = {"Authorization": 'Bearer ${user.token}'};
  var getBarang = await http.get(uri, headers: headers);


  if (getBarang.statusCode == 200) {
    var data = json.decode(getBarang.body);
    if (data["status"] == true) {
      List barang = data["data"].map((r) => TokoModel.fromJson(r)).toList();
      ResponseDataList response = ResponseDataList(
        status: true,
        message: 'Berhasil load data',
        data: barang,
      );
      return response;
    } else {
      ResponseDataList response = ResponseDataList(
        status: false,
        message: 'gagal load data',
      );
      return response;
    }
  } else {
    ResponseDataList response = ResponseDataList(
      status: false,
      message: "gagal load barang dengan code error ${getBarang.statusCode}",
    );
    return response;
  }
}


    
}



