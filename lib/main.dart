import 'package:flutter/material.dart';
import 'package:postman/view/dashboard.dart';
import 'package:postman/view/login_view.dart';
import 'package:postman/view/register_user_view.dart';

void main() {
  
  runApp(
    MaterialApp(
    initialRoute: '/login',
    routes: {
      '/': (context) => RegisterUserView(),
      '/login': (context) => LoginView(),
      '/dashboard': (context) => DashboardView(),    
    },
    debugShowCheckedModeBanner: false,
  ),
  );
}

  