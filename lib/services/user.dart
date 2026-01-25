import 'dart:convert';
import 'package:postman/models/response_data_map.dart';
import 'package:postman/models/user_login.dart';
import 'package:postman/services/url.dart' as url;
import 'package:http/http.dart' as http;

class UserService {
  Future registerUser(data) async {
    // PERBAIKAN 1: Hapus spasi setelah BaseUrl agar URL valid
    var uri = Uri.parse("${url.BaseUrl}/auth/register"); 
    
    try {
      var register = await http.post(uri, body: data);
      var responseData = json.decode(register.body);

      // Backend Anda tetap mengirim status 200 meskipun data salah (seperti email duplikat)
      if (register.statusCode == 200) {
        if (responseData["status"] == true) {
          return ResponseDataMap(
            status: true,
            message: "Sukses menambah user",
            data: responseData,
          );
        } else {
          // PERBAIKAN 2: Handling pesan error berupa Object (seperti di Postman Anda)
          var message = '';
          if (responseData["message"] is Map) {
            responseData["message"].forEach((key, value) {
              message += "${value[0]}\n"; // Mengambil pesan error pertama dari tiap field
            });
          } else {
            message = responseData["message"].toString();
          }

          return ResponseDataMap(
            status: false,
            message: message.trim(),
          );
        }
      } else {
        return ResponseDataMap(
          status: false,
          message: "Gagal: Code ${register.statusCode}",
        );
      }
    } catch (e) {
      return ResponseDataMap(status: false, message: "Kesalahan koneksi: $e");
    }
  }

  Future loginUser(data) async {
    // PERBAIKAN 3: Sinkronisasi dengan Langkah 3 & 4 (Endpoint /login)
    var uri = Uri.parse("${url.BaseUrl}/auth/login");
    
    try {
      var response = await http.post(uri, body: data);
      var responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        if (responseData["status"] == true) {
          // PERBAIKAN 4: Sesuaikan key dengan JSON asli (Perhatikan besar/kecil huruf)
          // Berdasarkan aturan Langkah 2: Gunakan class UserLogin
          UserLogin userLogin = UserLogin(
            status: responseData["status"],
            token: responseData["token"],
            message: responseData["message"],
            id: responseData["user"]["id"], // Biasanya lowercase 'user'
            nama_user: responseData["user"]["nama_user"], // Sesuaikan dengan Postman: 'name'
            email: responseData["user"]["email"],
            role: responseData["user"]["role"],
          );

          // Langkah 2: Simpan ke SharedPreferences
          await userLogin.prefs(); 

          return ResponseDataMap(
            status: true,
            message: "Sukses login user",
            data: responseData,
          );
        } else {
          return ResponseDataMap(
            status: false,
            message: responseData["message"] ?? 'Email atau password salah',
          );
        }
      } else {
        return ResponseDataMap(
          status: false,
          message: "Error Server: ${response.statusCode}",
        );
      }
    } catch (e) {
      return ResponseDataMap(status: false, message: "Gagal terhubung ke server");
    }
  }
}