import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:postman/models/model_toko.dart';
import 'package:postman/models/response_data_list.dart';
import 'package:postman/models/response_data_map.dart';
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
    } else {
      ResponseDataList response = ResponseDataList(
        status: false,
        message: "Gagal Load Toko dengan Code Eror${getToko.statusCode}",
      );
      return response;
    }
  }

  Future insertToko(request, image, id) async {
    var user = await UserLogin().getUserLogin();
    if (user.status == false) {
      ResponseDataList response = ResponseDataList(
        status: false,
        message: 'anda belum login / token invalid',
      );
      return response;
    }
    Map<String, String> headers = {
      "Authorization": 'Bearer ${user.token}',
      "Content-type": "multipart/form-data",
    };
    var response;
    if (id == null) {
      response = http.MultipartRequest(
        'POST',
        Uri.parse("${url.BaseUrl}/admin/insertbarang"),
      );
    } else {
      response = http.MultipartRequest(
        'POST',
        Uri.parse("${url.BaseUrl}/admin/updatebarang/$id"),
      );
    }
    if (image != null) {
      response.files.add(
        http.MultipartFile(
          'image',
          image.readAsBytes().asStream(),
          image.lengthSync(),
          filename: image.path.split('/').last,
        ),
      );
    }
    response.headers.addAll(headers);
    response.fields['nama_barang'] = request["title"];
    response.fields['deskripsi'] = request["deskripsi"];
    response.fields['stok'] = request["stok"];
    response.fields['harga'] = request["harga"];

    var res = await response.send();
    var result = await http.Response.fromStream(res);
    if (res.statusCode == 200) {
      var data = json.decode(result.body);
      if (data["status"] == true) {
        ResponseDataMap response = ResponseDataMap(
          status: true,
          message: 'success insert / update data',
        );
        return response;
      } else {
        ResponseDataMap response = ResponseDataMap(
          status: false,
          message: 'Failed insert / update data',
        );
        return response;
      }
    } else {
      ResponseDataMap response = ResponseDataMap(
        status: false,
        message: "gagal load movie dengan code error ${res.statusCode}",
      );
      return response;
    }
  }

  Future insertMovie(request, image, id) async {
    var user = await UserLogin().getUserLogin();
    if (user.status == false) {
      ResponseDataList response = ResponseDataList(
        status: false,
        message: 'anda belum login / token invalid',
      );
      return response;
    }
    Map<String, String> headers = {
      "Authorization": 'Bearer ${user.token}',
      "Content-type": "multipart/form-data",
    };
    var response;
    if (id == null) {
      response = http.MultipartRequest(
        'POST',
        Uri.parse("${url.BaseUrl}/admin/insertmovie"),
      );
    } else {
      response = http.MultipartRequest(
        'POST',
        Uri.parse("${url.BaseUrl}/admin/updatemovie/$id"),
      );
    }
    if (image != null) {
      response.files.add(
        http.MultipartFile(
          'posterpath',
          image.readAsBytes().asStream(),
          image.lengthSync(),
          filename: image.path.split('/').last,
        ),
      );
    }
    response.headers.addAll(headers);
    response.fields['title'] = request["title"];
    response.fields['voteaverage'] = request["voteaverage"];
    response.fields['overview'] = request["overview"];

    var res = await response.send();
    var result = await http.Response.fromStream(res);

    if (res.statusCode == 200) {
      var data = json.decode(result.body);
      if (data["status"] == true) {
        ResponseDataMap response = ResponseDataMap(
          status: true,
          message: 'success insert / update data',
        );
        return response;
      } else {
        ResponseDataMap response = ResponseDataMap(
          status: false,
          message: 'Failed insert / update data',
        );
        return response;
      }
    } else {
      ResponseDataMap response = ResponseDataMap(
        status: false,
        message: "gagal load movie dengan code error ${res.statusCode}",
      );
      return response;
    }
  }

  Future hapusMovie(context, id) async {
    var user = await UserLogin().getUserLogin();
    var uri = Uri.parse(url.BaseUrl + "/admin/hapusbarang/$id");
    if (user.status == false) {
      ResponseDataList response = ResponseDataList(
        status: false,
        message: 'anda belum login / token invalid',
      );
      return response;
    }
    Map<String, String> headers = {
      "Authorization": 'Bearer ${user.token}',
      "content-type": "multipart/form-data",
    };
    var hapusMovie = await http.delete(uri, headers: headers);

    if (hapusMovie.statusCode == 200) {
      var result = json.decode(hapusMovie.body);
      if (result["status"] == true) {
        ResponseDataList response = ResponseDataList(
          status: true,
          message: 'success hapus data',
        );
        return response;
      } else {
        ResponseDataList response = ResponseDataList(
          status: false,
          message: 'Failed hapus data',
        );  
        return response;
      }
    } else {
      ResponseDataList response = ResponseDataList(
        status: false,
        message: "gagal hapus movie dengan code error ${hapusMovie.statusCode}",
      );
      return response;
    }
  }
}
