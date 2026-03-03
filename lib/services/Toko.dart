import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:postman/models/model_toko.dart';
import 'package:postman/models/response_data_list.dart';
import 'package:postman/models/user_login.dart';
import 'package:postman/services/url.dart' as url;

class TokoService {
  Future getToko() async {
    UserLogin userLogin = UserLogin();
    var user = await userLogin.getUserLogin();
    if (user.status == false) {
      ResponseDataList response = ResponseDataList(
        status: false,
        message: "Anda belum Login",
      );
      return response;
    }
    var uri = Uri.parse(url.BaseUrl + "/admin/getbarang");
    Map<String, String> headers = {"Authorization": 'Bearer ${user.token}'};
    var getToko = await http.get(uri, headers: headers);
    if (getToko.statusCode == 200) {
      var data = json.decode(getToko.body);
      if (data["status"] == true) {
        List movie = data["data"].map((r) => TokoModel.fromJson(r)).toList();
        ResponseDataList response = ResponseDataList(
          status: true,
          message: 'success load data',
          data: movie,
        );
        return response;
      } else {
        ResponseDataList response = ResponseDataList(
          status: false,
          message: 'Failed load data',
        );
        return response;
      }
    }else {
      ResponseDataList response = ResponseDataList(
        status: false,
        message: "Gagal Load Toko dengan Code Eror${getToko.statusCode}",
      );
      return response;

    
    }
  }
}
