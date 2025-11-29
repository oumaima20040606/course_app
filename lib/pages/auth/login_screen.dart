import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

// AUTH SCREENS
import 'forgot_password_screen.dart';
import 'register_screen.dart';

// DASHBOARDS
import '../student/main_page.dart';
import '../teacher/teacher_dashboard.dart';
import '../admin/admin_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;
  bool obscurePassword = true;

  // LOGIN FUNCTION
  Future<void> loginUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    final uid = await AuthService()
        .login(emailController.text.trim(), passwordController.text.trim());

    if (uid == "error") {
      setState(() => loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Invalid email or password")));
      return;
    }

    final role = await AuthService().getUserRole(uid);

    setState(() => loading = false);

    if (role == "student") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainStudentPage()),
      );
    } else if (role == "teacher") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => TeacherDashboard()),
      );
    } else if (role == "admin") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => AdminDashboard()),
      );
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Role not found")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: Stack(
        children: [
          // ===== TOP PINK HEADER WITH BIGGER HEIGHT =====
          Align(
            alignment: Alignment.topCenter,
            child: ClipPath(
              clipper: _TopWaveClipper(),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.42, // ⬅️ Plus grand
                width: double.infinity,
                color: const Color(0xFFFF4B8B),
                padding: const EdgeInsets.symmetric(horizontal: 32),

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 35), // ⬅️ Rend Welcome visible

                    Text(
                      'Welcome!',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 30, // ⬅️ Plus grand
                          ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Create an account to join MyCourse',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white70,
                            fontSize: 15,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ===== FORMULAIRE =====
          Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                top: 300, // ⬅️ Descend le formulaire = parfait visuellement
                left: 32,
                right: 32,
              ),
              child: _form(),
            ),
          ),

          // ===== LOGO BOTTOM =====
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: Container(
                height: 80,
                width: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF4B8B),
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Image.asset(
                    'assets/icons/graduation.jpg',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========== FORM ==========
  Widget _form() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // EMAIL
          TextFormField(
            controller: emailController,
            validator: (v) =>
                v == null || v.isEmpty ? "Email is required" : null,
            style: const TextStyle(color: Colors.white),
            decoration: _inputStyle("Email", Icons.email_outlined),
          ),

          const SizedBox(height: 20),

          // PASSWORD
          TextFormField(
            controller: passwordController,
            obscureText: obscurePassword,
            validator: (v) =>
                v == null || v.isEmpty ? "Password is required" : null,
            style: const TextStyle(color: Colors.white),
            decoration: _inputStyle("Password", Icons.lock_outline).copyWith(
              suffixIcon: IconButton(
                icon: Icon(
                  obscurePassword ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white70,
                ),
                onPressed: () =>
                    setState(() => obscurePassword = !obscurePassword),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // FORGOT PASSWORD
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                ),
                child: const Text(
                  "Forgot Password?",
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // LOGIN BUTTON
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: loading ? null : loginUser,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4B8B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 18),

          // REGISTER REDIRECT
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RegisterScreen()),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Don't have an account? ",
                    style: TextStyle(color: Colors.white70)),
                Text(
                  "Register",
                  style: TextStyle(
                    color: Color(0xFFFF7FBF),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // STYLE DES CHAMPS
  InputDecoration _inputStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: const Color(0xFF18181B),
      prefixIcon: Icon(icon, color: Colors.white70),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(26),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(26),
        borderSide: const BorderSide(color: Color(0xFFFF7FBF)),
      ),
    );
  }
}

// ===== WAVE CLIPPER =====
class _TopWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.lineTo(0, size.height * 0.85);

    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.65,
      size.width * 0.5,
      size.height * 0.7,
    );

    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.75,
      size.width,
      size.height * 0.6,
    );

    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
