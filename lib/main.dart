  import 'package:flutter/material.dart';
  import 'package:postman/view/dashboard.dart';
  import 'package:postman/view/login_view.dart';
  import 'package:postman/view/register_user_view.dart';
  import 'package:postman/view/toko_View.dart';
  import 'package:postman/view/Pesan.dart';

  void main() {
    
    runApp(
      MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => RegisterUserView(),
        '/login': (context) => LoginView(),
        '/dashboard': (context) => DashboardView(),
        '/Toko': (context) => TokoView(),
        '/pesan': (context) => PesanView(),

          
      
      },
      debugShowCheckedModeBanner: false,
    ),
    );
  }

    