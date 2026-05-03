import 'dart:math';
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

class _RegisterUserViewState extends State<RegisterUserView>
    with TickerProviderStateMixin {
  final UserService _userService = UserService();
  final _formKey      = GlobalKey<FormState>();
  final _nameCtrl     = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();

  final List<String> _roles = ["admin", "user"];
  String? _role       = "user";
  bool _isLoading     = false;
  bool _obscurePass   = true;
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

    for (final key in ['name', 'email', 'password', 'role']) {
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
    _nameCtrl.dispose(); _emailCtrl.dispose(); _passwordCtrl.dispose();
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

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (_role == null) {
      _showPopup('role', 'Pilih peran akun terlebih dahulu',
        color: const Color(0xFFF59E0B));
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);
    try {
      final result = await _userService.registerUser({
        "name":     _nameCtrl.text,
        "email":    _emailCtrl.text.trim(),
        "role":     _role,
        "password": _passwordCtrl.text,
      }).timeout(const Duration(seconds: 15));

      if (!mounted) return;
      if (result.status == true) {
        AlertMessage().showAlert(context, "Pendaftaran berhasil!", true);
        final savedName = _nameCtrl.text;
        final savedRole = _role;
        _nameCtrl.clear(); _emailCtrl.clear(); _passwordCtrl.clear();
        setState(() { _role = null; _isLoading = false; });
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) =>
              DashboardView(userName: savedName, userRole: savedRole)),
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
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 44),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Daftar Akun",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900,
                color: UC.textW, letterSpacing: .3)),
            const SizedBox(height: 22),

            _popField(key: 'name', ctrl: _nameCtrl,
              label: 'NAMA LENGKAP', hint: 'Masukkan nama',
              icon: Icons.person_outline_rounded,
              focusMsg: 'Nama minimal 3 karakter',
              check: (v) => v != null && v.length >= 3,
              okMsg: 'Nama valid ✓', warnMsg: 'Nama terlalu pendek',
              formVal: (v) => (v==null||v.isEmpty) ? 'Nama tidak boleh kosong' : null),
            const SizedBox(height: 13),

            _popField(key: 'email', ctrl: _emailCtrl,
              label: 'ALAMAT EMAIL', hint: 'contoh@email.com',
              icon: Icons.mail_outline_rounded,
              kb: TextInputType.emailAddress,
              focusMsg: 'Gunakan format email valid',
              check: (v) => v != null && v.contains('@') && v.contains('.'),
              okMsg: 'Email valid ✓', warnMsg: 'Format email tidak valid',
              formVal: (v) => (v==null||!v.contains('@')) ? 'Email tidak valid' : null),
            const SizedBox(height: 13),

            _popField(key: 'password', ctrl: _passwordCtrl,
              label: 'KATA SANDI', hint: '••••••••',
              icon: Icons.lock_outline_rounded,
              isPass: true,
              focusMsg: 'Minimal 8 karakter',
              check: (v) => v != null && v.length >= 8,
              okMsg: 'Kata sandi kuat ✓', warnMsg: 'Minimal 8 karakter',
              formVal: (v) => (v==null||v.length<8) ? 'Password minimal 8 karakter' : null),
            const SizedBox(height: 16),

            // Role selector
            Stack(
              clipBehavior: Clip.none,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("PERAN AKUN",
                      style: TextStyle(fontSize: 9, color: UC.textMuted,
                        letterSpacing: 2, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 7),
                    Row(
                      children: _roles.map((r) {
                        final sel = _role == r;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _role = r);
                              _showPopup('role', 'Peran $r dipilih ✓',
                                color: const Color(0xFF059669));
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 260),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(vertical: 11),
                              decoration: BoxDecoration(
                                gradient: sel
                                  ? const LinearGradient(
                                      colors: [UC.ocean, UC.deepBlue])
                                  : null,
                                color: sel ? null : Colors.white.withValues(alpha: 0.03),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: sel
                                    ? UC.ocean
                                    : UC.ocean.withValues(alpha: 0.18)),
                                boxShadow: sel ? [
                                  BoxShadow(
                                    color: UC.ocean.withValues(alpha: 0.3),
                                    blurRadius: 12, offset: const Offset(0, 4))
                                ] : [],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    r == "admin"
                                      ? Icons.admin_panel_settings_outlined
                                      : Icons.person_outline_rounded,
                                    size: 13,
                                    color: sel
                                      ? Colors.white
                                      : UC.sky.withValues(alpha: 0.4)),
                                  const SizedBox(width: 5),
                                  Text(r.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 10, fontWeight: FontWeight.w800,
                                      letterSpacing: 1.5,
                                      color: sel
                                        ? Colors.white
                                        : UC.sky.withValues(alpha: 0.4))),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                _popWidget('role'),
              ],
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
                  onPressed: _isLoading ? null : _handleRegister,
                  child: _isLoading
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Daftar Sekarang",
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
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Sudah punya akun? ",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.28), fontSize: 11)),
                GestureDetector(
                  onTap: () => Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const LoginView())),
                  child: const Text("Masuk di sini",
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
                color: focused
                  ? UC.textMuted
                  : UC.textMuted.withValues(alpha: 0.45))),
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
                    color: focused
                      ? UC.sky
                      : UC.sky.withValues(alpha: 0.4), size: 17),
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
                    borderSide: BorderSide(
                      color: UC.ocean.withValues(alpha: 0.18))),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11),
                    borderSide: const BorderSide(
                      color: UC.ocean, width: 1.5)),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11),
                    borderSide: const BorderSide(color: Colors.red)),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11),
                    borderSide: const BorderSide(
                      color: Colors.red, width: 1.5)),
                ),
              ),
            ),
          ],
        ),
        _popWidget(key),
      ],
    );
  }

  Widget _popWidget(String key) {
    return Positioned(
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
                  color: (_popColor[key] ?? UC.ocean).withValues(alpha: 0.3),
                  blurRadius: 10, offset: const Offset(0, 2)),
              ],
            ),
            child: Text(_popMsg[key] ?? '',
              style: const TextStyle(color: Colors.white,
                fontSize: 10, fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }
}

// ─── PAINTERS (dipakai oleh kedua file via import) ─────────
class WavePainter extends CustomPainter {
  final double tick;
  const WavePainter(this.tick);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    _drawWave(canvas, w, h, yBase: h*0.55, amplitude: 14, freq: 1.5,
      phase: tick*2*pi, color: const Color(0xFF2563A8).withValues(alpha: 0.85), fillBottom: true);
    _drawWave(canvas, w, h, yBase: h*0.65, amplitude: 10, freq: 2.0,
      phase: tick*2*pi+1.2, color: const Color(0xFF1A4A7A).withValues(alpha: 0.9), fillBottom: true);
    _drawWave(canvas, w, h, yBase: h*0.75, amplitude: 7, freq: 2.5,
      phase: tick*2*pi+2.4, color: const Color(0xFF0D2A4E).withValues(alpha: 0.95), fillBottom: true);
    _drawWave(canvas, w, h, yBase: h*0.55, amplitude: 14, freq: 1.5,
      phase: tick*2*pi, color: Colors.white.withValues(alpha: 0.12),
      fillBottom: false, strokeWidth: 1.2);
    _drawWave(canvas, w, h, yBase: h*0.65, amplitude: 10, freq: 2.0,
      phase: tick*2*pi+1.2, color: Colors.white.withValues(alpha: 0.08),
      fillBottom: false, strokeWidth: 0.8);
  }

  void _drawWave(Canvas canvas, double w, double h, {
    required double yBase, required double amplitude, required double freq,
    required double phase, required Color color, required bool fillBottom,
    double strokeWidth = 1.0,
  }) {
    final paint = Paint()..color = color;
    if (!fillBottom) {
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = strokeWidth;
    }
    final path = Path();
    path.moveTo(0, yBase);
    for (double x = 0; x <= w; x += 1) {
      path.lineTo(x, yBase + amplitude * sin((x/w)*freq*2*pi + phase));
    }
    if (fillBottom) {
      path.lineTo(w, h); path.lineTo(0, h); path.close();
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WavePainter old) => old.tick != tick;
}

class ToriiPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF93C5FD).withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 6, size.width, 5), const Radius.circular(2)), paint);
    paint.color = const Color(0xFF93C5FD).withValues(alpha: 0.4);
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(2, 13, size.width-4, 3.5), const Radius.circular(1.5)), paint);
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(6, 16, 5, size.height-16), const Radius.circular(1.5)), paint);
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width-11, 16, 5, size.height-16),
      const Radius.circular(1.5)), paint);
    paint.color = const Color(0xFF93C5FD).withValues(alpha: 0.35);
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(2, 4, 4, 8), const Radius.circular(1.5)), paint);
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width-6, 4, 4, 8), const Radius.circular(1.5)), paint);
  }
  @override
  bool shouldRepaint(_) => false;
}