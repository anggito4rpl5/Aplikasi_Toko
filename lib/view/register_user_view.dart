import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:postman/services/user.dart';
import 'package:postman/view/alert.dart';
import 'package:postman/view/dashboard.dart';
import 'package:postman/view/login_view.dart';

class RegisterUserView extends StatefulWidget {
  const RegisterUserView({super.key});

  @override
  State<RegisterUserView> createState() => _RegisterUserViewState();
}

class _RegisterUserViewState extends State<RegisterUserView> {
  final UserService user = UserService();
  final formKey = GlobalKey<FormState>();

  final TextEditingController name = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  final List<String> roleChoice = ["admin", "user"];
  String? role;

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _isHovered = false;

  // --- LOGIC ANTI-FREEZE ---
  void _handleRegister() async {
    if (formKey.currentState!.validate()) {
      if (role == null) {
        AlertMessage().showAlert(context, "Please select a user role", false);
        return;
      }

      // 1. Matikan keyboard segera
      FocusScope.of(context).unfocus();
      
      setState(() => _isLoading = true);

      try {
        // 2. Kirim data ke API dengan Timeout agar tidak gantung selamanya
        final result = await user.registerUser({
          "name": name.text,
          "email": email.text.trim(),
          "role": role,
          "password": password.text,
        }).timeout(const Duration(seconds: 15)); 

        if (!mounted) return;

        // 3. Cek Status Respon
        if (result.status == true || result.status.toString() == "true") {
          
          // Tampilkan Alert SnackBar Anda
          AlertMessage().showAlert(context, "Registration Success!", true);
          
          // Simpan data untuk dikirim ke Dashboard sebelum form di-clear
          String savedName = name.text;
          String? savedRole = role;

          _clearForm();

          // 4. Reset Loading SEBELUM pindah halaman (Kunci agar tidak freeze)
          setState(() => _isLoading = false);

          // Pindah ke Dashboard
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => DashboardView(
                    userName: savedName,
                    userRole: savedRole,
                  ),
                ),
                (route) => false,
              );
            }
          });
        } else {
          // Jika status false dari API
          setState(() => _isLoading = false);
          AlertMessage().showAlert(context, result.message.toString(), false);
        }
      } catch (e) {
        // Jika terjadi error jaringan atau timeout
        if (mounted) {
          setState(() => _isLoading = false);
          AlertMessage().showAlert(context, "Connection Error or Timeout", false);
        }
      }
    }
  }

  void _clearForm() {
    name.clear();
    email.clear();
    password.clear();
    setState(() => role = null);
  }

  // --- TAMPILAN TETAP SAMA (ORIGINAL) ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFE0F7FA), Color(0xFF81D4FA), Color(0xFF0288D1)],
              ),
            ),
          ),
          Positioned(top: -50, right: -50, child: _buildCircle(200, Colors.white.withOpacity(0.2))),
          Positioned(bottom: -80, left: -80, child: _buildCircle(250, Colors.blue.shade900.withOpacity(0.1))),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  children: [
                    _buildLogoSection(),
                    const SizedBox(height: 30),
                    ClipRRect(
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
                                const Text("Create Account", textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF01579B))),
                                const SizedBox(height: 25),
                                _buildInput(controller: name, label: "Full Name", icon: Icons.person_rounded),
                                _buildInput(controller: email, label: "Email Address", icon: Icons.email_rounded, keyboardType: TextInputType.emailAddress),
                                _buildRoleSelector(),
                                const SizedBox(height: 18),
                                _buildInput(
                                  controller: password,
                                  label: "Password",
                                  icon: Icons.lock_rounded,
                                  obscureText: _obscurePassword,
                                  isPassword: true,
                                  togglePassword: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                                const SizedBox(height: 35),
                                _buildSubmitButton(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildLoginLink(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircle(double size, Color color) => Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, color: color));
  Widget _buildLogoSection() => Column(children: [
    Container(padding: const EdgeInsets.all(15), decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: const Icon(Icons.shopping_cart_rounded, size: 50, color: Color(0xFF0288D1))),
    const SizedBox(height: 15),
    const Text("SKY STORE", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 3)),
  ]);

  Widget _buildRoleSelector() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text("  Select Role", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF01579B))),
    const SizedBox(height: 8),
    Row(children: roleChoice.map((r) {
      bool selected = role == r;
      return Expanded(child: GestureDetector(
        onTap: () => setState(() => role = r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(color: selected ? const Color(0xFF0288D1) : Colors.white.withOpacity(0.5), borderRadius: BorderRadius.circular(15)),
          child: Text(r.toUpperCase(), textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: selected ? Colors.white : Colors.blueGrey)),
        ),
      ));
    }).toList()),
  ]);

  Widget _buildSubmitButton() => Container(
    height: 55,
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), gradient: const LinearGradient(colors: [Color(0xFF0288D1), Color(0xFF01579B)])),
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
      onPressed: _isLoading ? null : _handleRegister,
      child: _isLoading 
          ? const SizedBox(height: 25, width: 25, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)) 
          : const Text("SIGN UP NOW", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
    ),
  );

  Widget _buildLoginLink() => MouseRegion(
    onEnter: (_) => setState(() => _isHovered = true),
    onExit: (_) => setState(() => _isHovered = false),
    child: GestureDetector(
      onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginView())),
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 200),
        style: TextStyle(color: _isHovered ? Colors.white : Colors.white70, fontSize: 15, decoration: _isHovered ? TextDecoration.underline : TextDecoration.none),
        child: const Text("Already have an account? Login here"),
      ),
    ),
  );

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