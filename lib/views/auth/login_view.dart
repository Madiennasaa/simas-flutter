import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/neumorphic.dart';
import '../admin/admin_dashboard_view.dart';
import '../teacher/teacher_dashboard_view.dart';
import '../student/student_dashboard_view.dart';
import '../parent/parent_dashboard_view.dart';
import '../headmaster/headmaster_dashboard_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> with SingleTickerProviderStateMixin {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocus = FocusNode();
  bool _obscurePassword = true;

  late final AnimationController _entrance;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    )..forward();
    _fade = CurvedAnimation(parent: _entrance, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(CurvedAnimation(parent: _entrance, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _passwordFocus.dispose();
    _entrance.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      _usernameController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      _navigateByRole(authProvider.user!.role);
    } else if (authProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage!),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  // Titik tunggal buat routing berdasarkan role. Kalau nanti nambah role
  // baru atau ganti flow navigasi (misal pindah ke go_router/named routes),
  // cukup ubah di sini.
  void _navigateByRole(String role) {
    late final Widget destination;
    switch (role) {
      case "admin":
        destination = const AdminDashboardView();
        break;
      case "teacher":
        destination = const TeacherDashboardView();
        break;
      case "student":
        destination = const StudentDashboardView();
        break;
      case "parent":
        destination = const ParentDashboardView();
        break;
      case "headmaster":
        destination = const HeadmasterDashboardView();
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Role tidak dikenali")),
        );
        return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => destination),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(28, 48, 28, 32),
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo timbul (raised) — putih, biar pop di atas biru.
                    Center(
                      child: NeuBox(
                        borderRadius: BorderRadius.circular(999),
                        padding: const EdgeInsets.all(18),
                        blur: 8,
                        child: SizedBox(
                          width: 64,
                          height: 64,
                          child: Image.asset('assets/images/tutwuri.png', fit: BoxFit.contain),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "SIMAS",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "SDN Sukorame 1 Kediri",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12.5, color: Colors.white.withOpacity(0.75)),
                    ),

                    const SizedBox(height: 40),
                    const Text(
                      "Masuk ke Akun",
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Selamat datang kembali, silakan masuk untuk melanjutkan",
                      style: TextStyle(fontSize: 12.5, color: Colors.white.withOpacity(0.7), height: 1.4),
                    ),
                    const SizedBox(height: 28),

                    _buildLabel("Username"),
                    const SizedBox(height: 8),
                    NeuPressedBox(
                      child: TextField(
                        controller: _usernameController,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => FocusScope.of(context).requestFocus(_passwordFocus),
                        style: const TextStyle(fontSize: 14.5, color: Colors.white),
                        decoration: _fieldDecoration(
                          hint: "Masukkan username",
                          icon: Icons.person_outline_rounded,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildLabel("Password"),
                    const SizedBox(height: 8),
                    NeuPressedBox(
                      child: TextField(
                        controller: _passwordController,
                        focusNode: _passwordFocus,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        style: const TextStyle(fontSize: 14.5, color: Colors.white),
                        decoration: _fieldDecoration(
                          hint: "Masukkan password",
                          icon: Icons.lock_outline_rounded,
                        ).copyWith(
                          suffixIcon: IconButton(
                            splashRadius: 20,
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                              color: Colors.white.withOpacity(0.75),
                              size: 20,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        onSubmitted: (_) => _handleLogin(),
                      ),
                    ),

                    const SizedBox(height: 30),
                    CustomButton(
                      label: "Masuk",
                      isLoading: authProvider.isLoading,
                      onPressed: _handleLogin,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info_outline_rounded, size: 14, color: Colors.white.withOpacity(0.65)),
                        const SizedBox(width: 6),
                        Text(
                          "Lupa password? Hubungi admin sekolah",
                          style: TextStyle(fontSize: 11.5, color: Colors.white.withOpacity(0.65)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    );
  }

  InputDecoration _fieldDecoration({required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.85), size: 20),
      filled: false,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
    );
  }
}
