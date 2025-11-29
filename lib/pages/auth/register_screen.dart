import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/auth_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirm = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  String role = "student";
  bool loading = false;
  bool obscurePassword = true;
  bool obscureConfirm = true;

  final AuthService _authService = AuthService();

  Future<void> registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    final result = await _authService.register(
      email.text.trim(),
      password.text.trim(),
      name.text.trim(),
      role,
    );

    setState(() => loading = false);

    if (result == "success") {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': name.text.trim(),
          'email': email.text.trim(),
          'role': role,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827),

      // --- APPBAR BACK BUTTON ---
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      // --- PAGE BODY ---
      body: Stack(
        children: [
          // TOP WAVE (HEADER)
          Align(
            alignment: Alignment.topCenter,
            child: ClipPath(
              clipper: _TopWaveClipperRegister(),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.38,
                width: double.infinity,
                color: const Color(0xFFFF4B8B),
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Welcome",
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Please register to make an account",
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // --- FORMULAIRE ---
          Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                top: 250,   // ⬅⬅ LE FORMULAIRE DESCEND ICI
                left: 40,
                right: 40,
              ),
              child: _form(),
            ),
          ),
        ],
      ),
    );
  }

  // ------- FORM --------
  Widget _form() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _nameField(),
          const SizedBox(height: 20),
          _emailField(),
          const SizedBox(height: 20),
          _passwordField(),
          const SizedBox(height: 20),
          _confirmPassField(),
          const SizedBox(height: 20),
          _roleDropdown(),
          const SizedBox(height: 30),
          _registerButton(),
          const SizedBox(height: 20),
          _loginRedirect(),
        ],
      ),
    );
  }

  // -------- FIELDS --------

  Widget _nameField() {
    return TextFormField(
      controller: name,
      decoration: InputDecoration(
        label: const Text("Full Name"),
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: const Icon(Icons.person, color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      style: const TextStyle(color: Colors.white),
      validator: (v) => v!.isEmpty ? "Name is required" : null,
    );
  }

  Widget _emailField() {
    return TextFormField(
      controller: email,
      decoration: InputDecoration(
        label: const Text("Email"),
        labelStyle: const TextStyle(color: Colors.white70),
        hintText: "user@gmail.com",
        hintStyle: const TextStyle(color: Colors.white38),
        prefixIcon: const Icon(Icons.email, color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      style: const TextStyle(color: Colors.white),
      validator: (value) {
        if (value == null || value.isEmpty) return "Email is required";
        if (!value.contains('@')) return "Email must contain @";
        return null;
      },
    );
  }

  Widget _passwordField() {
    return TextFormField(
      controller: password,
      obscureText: obscurePassword,
      decoration: InputDecoration(
        label: const Text("Password"),
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: const Icon(Icons.key, color: Colors.white70),
        suffixIcon: IconButton(
          icon: Icon(
            obscurePassword ? Icons.visibility : Icons.visibility_off,
            color: Colors.white70,
          ),
          onPressed: () =>
              setState(() => obscurePassword = !obscurePassword),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      style: const TextStyle(color: Colors.white),
      validator: (value) {
        if (value == null || value.isEmpty) return "Password is required";
        if (value.length < 6) return "Password too short";
        return null;
      },
    );
  }

  Widget _confirmPassField() {
    return TextFormField(
      controller: confirm,
      obscureText: obscureConfirm,
      decoration: InputDecoration(
        label: const Text("Confirm Password"),
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: const Icon(Icons.key, color: Colors.white70),
        suffixIcon: IconButton(
          icon: Icon(
              obscureConfirm ? Icons.visibility : Icons.visibility_off),
          onPressed: () =>
              setState(() => obscureConfirm = !obscureConfirm),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      style: const TextStyle(color: Colors.white),
      validator: (value) {
        if (value == null || value.isEmpty) return "Confirm your password";
        if (value != password.text) return "Passwords do not match";
        return null;
      },
    );
  }

  Widget _roleDropdown() {
    return DropdownButtonFormField(
      value: role,
      items: const [
        DropdownMenuItem(value: "student", child: Text("Student")),
        DropdownMenuItem(value: "teacher", child: Text("Teacher")),
      ],
      onChanged: (value) => setState(() => role = value!),
      dropdownColor: const Color(0xFF1F2937),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        label: const Text("Select Role"),
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: const Icon(Icons.people, color: Colors.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }

  Widget _registerButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFF4B8B),
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40),
        ),
      ),
      onPressed: loading ? null : registerUser,
      child: loading
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text("Register"),
    );
  }

  Widget _loginRedirect() {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      },
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Already have an account? ",
            style: TextStyle(color: Colors.white70),
          ),
          Text(
            "Login",
            style: TextStyle(
              color: Color(0xFFFF4B8B),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// --- WAVE CLIPPER ---
class _TopWaveClipperRegister extends CustomClipper<Path> {
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
