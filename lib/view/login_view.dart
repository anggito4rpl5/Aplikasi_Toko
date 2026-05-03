import 'dart:math';
import 'package:flutter/material.dart';
import 'package:postman/services/user.dart';
import 'package:postman/view/alert.dart';
import 'package:postman/view/dashboard.dart';
import 'package:postman/view/register_user_view.dart';

// ─── WARNA TEMA ───────────────────────────────────────────
class UC {
  static const bg1      = Color(0xFF091429);
  static const bg2      = Color(0xFF0D1F3C);
  static const heroTop  = Color(0xFF0A1628);
  static const heroMid  = Color(0xFF0D2A4E);
  static const heroBot  = Color(0xFF2563A8);
  static const ocean    = Color(0xFF1D4ED8);
  static const deepBlue = Color(0xFF1E3A8A);
  static const sky      = Color(0xFF60A5FA);
  static const foam     = Color(0xFF93C5FD);
  static const moonBlue = Color(0xFFB8D4F0);
  static const textW    = Color(0xFFE8F4FF);
  static const textMuted= Color(0xFFB4D2F0);
}

class LoginView extends StatefulWidget {
  const LoginView({super.key});
  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> with TickerProviderStateMixin {
  final UserService _userService  = UserService();
  final _formKey      = GlobalKey<FormState>();
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _isLoading   = false;
  bool _obscurePass = true;
  String? _focusedField;

  late AnimationController _waveCtrl;
  late AnimationController _fadeCtrl;
  late Animation<double>   _fadeAnim;

  final Map<String, AnimationController> _popCtrl  = {};
  final Map<String, Animation<double>>   _popAnim  = {};
  final Map<String, String>              _popMsg   = {};
  final Map<String, Color>               _popColor = {};

  @override
  void initState() {
    super.initState();
    _waveCtrl = AnimationController(
      vsync: this, duration: const Duration(seconds: 4))..repeat();
    _fadeCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();

    for (final key in ['email', 'password']) {
      final c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 260));
      _popCtrl[key] = c;
      _popAnim[key] = CurvedAnimation(parent: c, curve: Curves.easeOutBack);
      _popMsg[key]  = '';
      _popColor[key]= UC.ocean;
    }
  }

  @override
  void dispose() {
    _waveCtrl.dispose(); _fadeCtrl.dispose();
    _emailCtrl.dispose(); _passwordCtrl.dispose();
    for (final c in _popCtrl.values) c.dispose();
    super.dispose();
  }

  void _showPopup(String field, String msg, {Color? color}) {
    setState(() { _popMsg[field] = msg; _popColor[field] = color ?? UC.ocean; });
    _popCtrl[field]?.forward(from: 0);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) _popCtrl[field]?.reverse();
    });
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);
    try {
      final result = await _userService.loginUser({
        "email":    _emailCtrl.text.trim(),
        "password": _passwordCtrl.text,
      }).timeout(const Duration(seconds: 15));

      if (!mounted) return;
      if (result.status == true) {
        AlertMessage().showAlert(context, "Selamat datang!", true);
        setState(() => _isLoading = false);
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => DashboardView(
              userName: result.data?['name'] ?? '',
              userRole: result.data?['role'])),
            (r) => false,
          );
        });
      } else {
        setState(() => _isLoading = false);
        AlertMessage().showAlert(context, result.message.toString(), false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AlertMessage().showAlert(context, "Koneksi gagal / timeout", false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UC.bg1,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(children: [_buildHero(), _buildForm()]),
        ),
      ),
    );
  }

  Widget _buildHero() {
    return SizedBox(
      height: 220,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [UC.heroTop, UC.heroMid, UC.heroBot],
                stops: [0.0, 0.45, 1.0],
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _waveCtrl,
            builder: (_, __) => CustomPaint(
              size: Size.infinite,
              painter: WavePainter(_waveCtrl.value)),
          ),
          Positioned(
            top: 42, left: 0, right: 0,
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    center: Alignment(-0.3, -0.3),
                    colors: [Color(0xFFE8F4FF), UC.moonBlue],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: UC.moonBlue.withValues(alpha: 0.35),
                      blurRadius: 18, spreadRadius: 2),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 30, right: 20,
            child: Opacity(opacity: 0.55,
              child: CustomPaint(
                size: const Size(44, 48), painter: ToriiPainter())),
          ),
          const Positioned(
            top: 0, left: 0, right: 0, bottom: 0,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.only(left: 20, top: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 2),
                    Text("Toko Taka",
                      style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900,
                        color: UC.textW, letterSpacing: 3,
                        shadows: [Shadow(color: Color(0xFF1D4ED8), blurRadius: 14)])),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [UC.bg2, UC.bg1],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 50),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Selamat Datang",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900,
                color: UC.textW, letterSpacing: .3)),
            const SizedBox(height: 26),

            _popField(key: 'email', ctrl: _emailCtrl,
              label: 'ALAMAT EMAIL', hint: 'contoh@email.com',
              icon: Icons.mail_outline_rounded,
              kb: TextInputType.emailAddress,
              focusMsg: 'Masukkan email terdaftar',
              check: (v) => v != null && v.contains('@'),
              okMsg: 'Email terdeteksi ✓', warnMsg: 'Format email tidak valid',
              formVal: (v) => (v==null||!v.contains('@')) ? 'Email tidak valid' : null),
            const SizedBox(height: 13),

            _popField(key: 'password', ctrl: _passwordCtrl,
              label: 'KATA SANDI', hint: '••••••••',
              icon: Icons.lock_outline_rounded,
              isPass: true,
              focusMsg: 'Masukkan kata sandi kamu',
              check: (v) => v != null && v.length >= 6,
              okMsg: 'Siap masuk ✓', warnMsg: 'Kata sandi terlalu pendek',
              formVal: (v) => (v==null||v.isEmpty) ? 'Kata sandi tidak boleh kosong' : null),

            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text("Lupa kata sandi?",
                style: TextStyle(fontSize: 11,
                  color: UC.sky.withValues(alpha: 0.65),
                  fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 26),

            SizedBox(
              width: double.infinity, height: 50,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [UC.ocean, UC.deepBlue]),
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: [
                    BoxShadow(color: UC.ocean.withValues(alpha: 0.3),
                      blurRadius: 18, offset: const Offset(0, 7)),
                  ],
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13))),
                  onPressed: _isLoading ? null : _handleLogin,
                  child: _isLoading
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Masuk",
                            style: TextStyle(color: Colors.white,
                              fontWeight: FontWeight.w800, fontSize: 14,
                              letterSpacing: .5)),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded,
                            color: Colors.white, size: 16),
                        ],
                      ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: Divider(color: UC.ocean.withValues(alpha: 0.18))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text("atau",
                    style: TextStyle(
                      fontSize: 11, color: Colors.white.withValues(alpha: 0.18)))),
                Expanded(child: Divider(color: UC.ocean.withValues(alpha: 0.18))),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Belum punya akun? ",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.28), fontSize: 11)),
                GestureDetector(
                  onTap: () => Navigator.pushReplacement(context,
                    MaterialPageRoute(
                      builder: (_) => const RegisterUserView())),
                  child: const Text("Daftar di sini",
                    style: TextStyle(color: UC.sky,
                      fontWeight: FontWeight.w700, fontSize: 11)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _popField({
    required String key,
    required TextEditingController ctrl,
    required String label,
    required String hint,
    required IconData icon,
    required String focusMsg,
    required bool Function(String?) check,
    required String okMsg,
    required String warnMsg,
    required String? Function(String?) formVal,
    bool isPass = false,
    TextInputType kb = TextInputType.text,
  }) {
    final focused = _focusedField == key;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
              style: TextStyle(
                fontSize: 9, letterSpacing: 2, fontWeight: FontWeight.w700,
                color: focused ? UC.textMuted : UC.textMuted.withValues(alpha: 0.45))),
            const SizedBox(height: 5),
            Focus(
              onFocusChange: (f) {
                if (f) {
                  setState(() => _focusedField = key);
                  _showPopup(key, focusMsg, color: UC.ocean);
                } else {
                  setState(() => _focusedField = null);
                }
              },
              child: TextFormField(
                controller: ctrl,
                keyboardType: kb,
                obscureText: isPass && _obscurePass,
                style: const TextStyle(color: UC.textW, fontSize: 13),
                onChanged: (v) {
                  if (v.isEmpty) return;
                  if (check(v)) {
                    _showPopup(key, okMsg, color: const Color(0xFF059669));
                  } else if (v.length >= 2) {
                    _showPopup(key, warnMsg, color: const Color(0xFFF59E0B));
                  }
                },
                validator: formVal,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.18), fontSize: 13),
                  prefixIcon: Icon(icon,
                    color: focused ? UC.sky : UC.sky.withValues(alpha: 0.4),
                    size: 17),
                  suffixIcon: isPass
                    ? IconButton(
                        icon: Icon(
                          _obscurePass
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                          color: Colors.white.withValues(alpha: 0.28), size: 17),
                        onPressed: () =>
                          setState(() => _obscurePass = !_obscurePass))
                    : null,
                  filled: true,
                  fillColor: focused
                    ? UC.ocean.withValues(alpha: 0.1)
                    : Colors.white.withValues(alpha: 0.04),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 13),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11),
                    borderSide: BorderSide(color: UC.ocean.withValues(alpha: 0.18))),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11),
                    borderSide: const BorderSide(color: UC.ocean, width: 1.5)),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11),
                    borderSide: const BorderSide(color: Colors.red)),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11),
                    borderSide: const BorderSide(color: Colors.red, width: 1.5)),
                ),
              ),
            ),
          ],
        ),
        Positioned(
          top: -32, left: 0,
          child: ScaleTransition(
            scale: _popAnim[key]!,
            alignment: Alignment.bottomLeft,
            child: FadeTransition(
              opacity: _popAnim[key]!,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _popColor[key],
                  borderRadius: const BorderRadius.only(
                    topLeft:     Radius.circular(8),
                    topRight:    Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                  border: Border.all(
                    color: (_popColor[key] ?? UC.ocean).withValues(alpha: 0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: (_popColor[key] ?? UC.ocean).withValues(alpha: 0.25),
                      blurRadius: 10, offset: const Offset(0, 2)),
                  ],
                ),
                child: Text(_popMsg[key] ?? '',
                  style: const TextStyle(color: Colors.white,
                    fontSize: 10, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}