import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:postman/models/response_data_list.dart';
import 'package:postman/models/response_data_map.dart';
import 'package:postman/models/user_login.dart';
import 'package:postman/services/url.dart' as url;

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
 