import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:postman/services/user.dart';
import 'package:postman/view/alert.dart';
import 'package:postman/view/dashboard.dart'; // Import langsung class Dashboard
import 'package:postman/view/register_user_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final UserService user = UserService();
  final formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _showPass = true;
  bool _isHovered = false;

  // --- LOGIC: LOGIN ANTI-FREEZE & DATA TRANSFER ---
  void _handleLogin() async {
    if (formKey.currentState!.validate()) {
      // 1. Tutup keyboard untuk kelancaran UI
      FocusScope.of(context).unfocus();
      
      setState(() => _isLoading = true);
      
      // Menggunakan .trim() untuk menghindari error spasi tak sengaja
      final data = {
        "email": emailController.text.trim(),
        "password": passwordController.text,
      };

      try {
        // Tambahkan timeout agar tidak freeze jika server mati
        final result = await user.loginUser(data).timeout(const Duration(seconds: 15));
        
        if (!mounted) return;

        if (result.status == true || result.status.toString() == "true") {
          AlertMessage().showAlert(context, "Login Berhasil!", true);
          
          // AMBIL DATA DARI API (Sesuaikan key JSON API Anda, misal result.data['name'])
          // Kita asumsikan API mengembalikan objek user di dalam field 'data'
          final String nameFromApi = result.data?['name'] ?? "User";
          final String roleFromApi = result.data?['role'] ?? "user";

          // 2. Reset loading sebelum transisi
          setState(() => _isLoading = false);

          // 3. Navigasi Bersih ke Dashboard
          Future.delayed(const Duration(milliseconds: 800), () {
            if (mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => DashboardView(
                    userName: nameFromApi,
                    userRole: roleFromApi,
                  ),
                ),
                (route) => false,
              );
            }
          });
        } else {
          setState(() => _isLoading = false);
          AlertMessage().showAlert(context, result.message ?? "Email/Password Salah", false);
        }
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) AlertMessage().showAlert(context, "Gagal terhubung ke server", false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background (Tetap sama sesuai keinginan Anda)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFE0F7FA), Color(0xFF81D4FA), Color(0xFF0288D1)],
              ),
            ),
          ),
          Positioned(top: -50, left: -50, child: _buildCircle(200, Colors.white.withOpacity(0.2))),
          Positioned(bottom: -80, right: -80, child: _buildCircle(250, Colors.blue.shade900.withOpacity(0.1))),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _buildLogoSection(),
                    const SizedBox(height: 40),
                    _buildLoginCard(),
                    const SizedBox(height: 30),
                    _buildRegisterLink(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildLoginCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(35),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(35),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text("Welcome Back", textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF01579B))),
                const SizedBox(height: 30),
                _buildInput(
                  controller: emailController,
                  label: "Email Address",
                  icon: Icons.email_rounded,
                  keyboardType: TextInputType.emailAddress,
                ),
                _buildInput(
                  controller: passwordController,
                  label: "Password",
                  icon: Icons.lock_rounded,
                  obscureText: _showPass,
                  isPassword: true,
                  togglePassword: () => setState(() => _showPass = !_showPass),
                ),
                const SizedBox(height: 35),
                _buildLoginButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCircle(double size, Color color) => Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, color: color));

  Widget _buildLogoSection() => Column(children: [
    Container(padding: const EdgeInsets.all(15), decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: const Icon(Icons.login_rounded, size: 50, color: Color(0xFF0288D1))),
    const SizedBox(height: 15),
    const Text("SKY STORE", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 3)),
  ]);

  Widget _buildLoginButton() {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(colors: [Color(0xFF0288D1), Color(0xFF01579B)]),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
        onPressed: _isLoading ? null : _handleLogin,
        child: _isLoading
            ? const SizedBox(height: 25, width: 25, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
            : const Text("LOGIN NOW", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const RegisterUserView())),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(color: _isHovered ? Colors.white : Colors.white70, fontSize: 15, decoration: _isHovered ? TextDecoration.underline : TextDecoration.none),
          child: const Text("Don't have an account? Register here"),
        ),
      ),
    );
  }

  Widget _buildInput({required TextEditingController controller, required String label, required IconData icon, bool obscureText = false, bool isPassword = false, VoidCallback? togglePassword, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF0288D1)),
          suffixIcon: isPassword ? IconButton(icon: Icon(obscureText ? Icons.visibility_off_rounded : Icons.visibility_rounded), onPressed: togglePassword) : null,
          filled: true, fillColor: Colors.white.withOpacity(0.8),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
        ),
        validator: (value) => value == null || value.isEmpty ? '$label cannot be empty' : null,
      ),
    );
  }
}