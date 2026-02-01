  import 'dart:convert';
  import 'package:postman/models/response_data_map.dart';
  import 'package:postman/models/user_login.dart';
  import 'package:postman/services/url.dart' as url;
  import 'package:http/http.dart' as http;

  class UserService {
    // --- Fungsi Register ---
    Future registerUser(data) async {
      var uri = Uri.parse("${url.BaseUrl}/auth/register"); 
      try {
        var register = await http.post(uri, body: data);
        var responseData = json.decode(register.body);

        if (register.statusCode == 200) {
          if (responseData["status"] == true) {
            return ResponseDataMap(
              status: true,
              message: "Sukses menambah user",
              data: responseData,
            );
          } else {
            var message = '';
            if (responseData["message"] is Map) {
              responseData["message"].forEach((key, value) {
                message += "${value[0]}\n"; 
              });
            } else {
              message = responseData["message"].toString();
            }
            return ResponseDataMap(status: false, message: message.trim());
          }
        } else {
          return ResponseDataMap(status: false, message: "Gagal: Code ${register.statusCode}");
        }
      } catch (e) {
        return ResponseDataMap(status: false, message: "Kesalahan koneksi: $e");
      }
    }

    // --- Fungsi Login ---
    Future loginUser(data) async {
      var uri = Uri.parse("${url.BaseUrl}/auth/login");
      try {
        var response = await http.post(uri, body: data);
        var responseData = json.decode(response.body);

        if (response.statusCode == 200) {
          if (responseData["status"] == true) {
            UserLogin userLogin = UserLogin(
              status: responseData["status"],
              token: responseData["token"],
              message: responseData["message"],
              id: responseData["user"]["id"],
              nama_user: responseData["user"]["nama_user"],
              email: responseData["user"]["email"],
              role: responseData["user"]["role"],
            );

            await userLogin.prefs(); 

            return ResponseDataMap(
              status: true,
              message: "Sukses login user",
              data: responseData,
            );
          } else {
            return ResponseDataMap(status: false, message: responseData["message"] ?? 'Email atau password salah');
          }
        } else {
          return ResponseDataMap(status: false, message: "Error Server: ${response.statusCode}");
        }
      } catch (e) {
        return ResponseDataMap(status: false, message: "Gagal terhubung ke server");
      }
    }

    // PERBAIKAN: Fungsi ini SEKARANG berada di DALAM class UserService
    Future<UserLogin?> getUserLogin() async {
      try {
        // Mengambil data session dari SharedPreferences melalui model UserLogin
        UserLogin user = UserLogin();
        UserLogin? data = await user.getUserLogin(); 
        return data;
      } catch (e) {
        return null;
      }
    }
  } // Kurung kurawal penutup class UserService harus di sini