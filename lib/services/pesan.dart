import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:postman/models/response_data_map.dart';
import 'package:postman/models/user_login.dart';
import 'package:postman/services/url.dart' as url;
import 'package:postman/models/History.dart';

class Pesan {
  UserLogin userLogin = UserLogin();

  // ─── CHECKOUT ─────────────────────────────────────────────
  Future saveToDB(dataRequest) async {
    var uri = Uri.parse(url.BaseUrl + "/user/transaksi");
    var user = await userLogin.getUserLogin();
    if (user.status == false) {
      return ResponseDataMap(
        status: false,
        message: 'anda belum login / token invalid',
      );
    }
    Map<String, String> headers = {
      "Authorization": 'Bearer ${user.token}',
      'Content-Type': "application/json",
    };
    try {
      var simpanPesan = await http.post(
        uri,
        body: json.encode(dataRequest),
        headers: headers,
      );
      var data = json.decode(simpanPesan.body);
      if (simpanPesan.statusCode == 200) {
        if (data["status"] == true) {
          return ResponseDataMap(status: true, message: "Sukses checkout");
        } else {
          return ResponseDataMap(status: false, message: data["message"]);
        }
      } else {
        return ResponseDataMap(
          status: false,
          message: "gagal dengan code error ${simpanPesan.statusCode}",
        );
      }
    } catch (e) {
      return ResponseDataMap(status: false, message: "fatal error $e");
    }
  }

  // ─── GET HISTORY ─────────────────────────────────────────
  Future<List<HistoryModel>> getHistory() async {
    var uri = Uri.parse(url.BaseUrl + "/user/history_trans");
    var user = await userLogin.getUserLogin();
    if (user.status == false) return [];

    Map<String, String> headers = {
      "Authorization": 'Bearer ${user.token}',
      'Content-Type': "application/json",
    };

    try {
      var response = await http.get(uri, headers: headers);
      var data = json.decode(response.body);
      if (response.statusCode == 200 && data["status"] == true) {
        List list = data["data"] ?? [];
        return list.map((e) => HistoryModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print("getHistory error: $e");
      return [];
    }
  }
}