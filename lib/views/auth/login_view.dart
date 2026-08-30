import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../widgets/custom_button.dart';
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

class _LoginViewState extends State<LoginView>
    with SingleTickerProviderStateMixin {
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
        .animate(
            CurvedAnimation(parent: _entrance, curve: Curves.easeOutCubic));
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(28, 40, 28, 32),
          child: FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slide,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Ilustrasi karakter/sekolah, senada referensi (flat,
                  // di atas judul). Ganti asset sesuai role kalau login
                  // dipisah per tema (lihat LoginTheme).
                  Center(
                    child: SizedBox(
                      height: 150,
                      child: Image.asset(
                        'assets/images/login_illustration.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.textPrimary.withOpacity(0.06),
                                offset: const Offset(0, 6),
                                blurRadius: 16,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Image.asset('assets/images/tutwuri.png',
                                fit: BoxFit.contain),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    "SIMAS Login",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Belum punya akun? ",
                        style: TextStyle(
                            fontSize: 12.5, color: AppColors.textMuted),
                      ),
                      Text(
                        "Hubungi admin",
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accentGreen,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 36),

                  _buildLabel("Username"),
                  const SizedBox(height: 6),
                  _UnderlineField(
                    controller: _usernameController,
                    icon: Icons.person_outline_rounded,
                    hint: "Masukkan username",
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) =>
                        FocusScope.of(context).requestFocus(_passwordFocus),
                  ),
                  const SizedBox(height: 22),

                  _buildLabel("Password"),
                  const SizedBox(height: 6),
                  _UnderlineField(
                    controller: _passwordController,
                    focusNode: _passwordFocus,
                    icon: Icons.lock_outline_rounded,
                    hint: "Masukkan password",
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _handleLogin(),
                    suffixIcon: IconButton(
                      splashRadius: 20,
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        color: AppColors.textMuted,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),

                  const SizedBox(height: 12),
                  Text(
                    "Lupa password? Hubungi admin sekolah",
                    textAlign: TextAlign.right,
                    style:
                        TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                  ),

                  const SizedBox(height: 30),
                  CustomButton(
                    label: "Masuk",
                    isLoading: authProvider.isLoading,
                    onPressed: _handleLogin,
                    color: AppColors.accentGreen,
                  ),
                ],
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
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
    );
  }
}

/// Field underline flat (bukan pressed/neomorphism), senada referensi:
/// ikon kecil di kiri, garis tipis di bawah, hijau saat fokus.
class _UnderlineField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final IconData icon;
  final String hint;
  final bool obscureText;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final Widget? suffixIcon;

  const _UnderlineField({
    required this.controller,
    required this.icon,
    required this.hint,
    this.focusNode,
    this.obscureText = false,
    this.textInputAction,
    this.onSubmitted,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      style: const TextStyle(fontSize: 14.5, color: AppColors.textPrimary),
      cursorColor: AppColors.accentGreen,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
        prefixIcon: Icon(icon, color: AppColors.textMuted, size: 20),
        suffixIcon: suffixIcon,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.fieldLine, width: 1),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.accentGreen, width: 1.6),
        ),
        border: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.fieldLine, width: 1),
        ),
      ),
    );
  }
}
