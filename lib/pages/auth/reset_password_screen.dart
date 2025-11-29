import 'package:course_app/constant/constant.dart';
import 'package:flutter/material.dart';
import 'package:course_app/constants/color.dart';
import 'package:iconly/iconly.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {

  // Controllers
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  // Visibility toggles
  bool isPasswordVisible = false;
  bool isConfirmVisible = false;

  // Form key
  final _formKey = GlobalKey<FormState>();

  // Condition bouton activé
  bool get isButtonEnabled {
    return _passwordController.text.length >= 6 &&
        _confirmController.text.length >= 6 &&
        _passwordController.text == _confirmController.text;
  }

  @override
  Widget build(BuildContext context) {
    const SizedBox gap = SizedBox(height: 10);
    const SizedBox gap2 = SizedBox(height: 20);
    const SizedBox gap3 = SizedBox(height: 40);

    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      body: SafeArea(
        child: Stack(
          children: [
            // Vague rose en haut
            Align(
              alignment: Alignment.topCenter,
              child: ClipPath(
                clipper: _TopWaveClipperReset(),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.4,
                  width: double.infinity,
                  color: const Color(0xFFFF4B8B),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _back(context),
                      const SizedBox(height: 12),
                      _title(),
                      _subTitle(),
                    ],
                  ),
                ),
              ),
            ),

            // Formulaire principal
            Align(
              alignment: Alignment.center,
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label("New Password"),
                      gap,
                      _passwordField(),
                      gap2,
                      _label("Confirm New Password"),
                      gap,
                      _confirmPasswordField(),
                      gap3,
                      _saveButton(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Back Button
  Widget _back(context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Row(
          children: [
            const Icon(
              IconlyLight.arrow_left,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Text(
              "Back",
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  // Image
  Widget _image() {
    return Image.asset(
      "assets/REST.jpg",
      width: 300,
    );
  }

  // Title
  Widget _title() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Text(
        "Reset Password?",
        style: Theme.of(context)
            .textTheme
            .bodyLarge
            ?.copyWith(fontSize: 24, color: Colors.white),
      ),
    );
  }

  // Subtitle
  Widget _subTitle() {
    return const Padding(
      padding: EdgeInsets.only(top: 10),
      child: Text(
        "Please enter new password",
        style: TextStyle(color: Colors.white70),
      ),
    );
  }

  // Label text widget
  Widget _label(String text) {
    return Text(
      text,
      style: Theme.of(context)
          .textTheme
          .bodySmall
          ?.copyWith(fontSize: 14, color: Colors.white70),
    );
  }

  // New Password Field
  Widget _passwordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: !isPasswordVisible,
      onChanged: (value) => setState(() {}),
      validator: (value) {
        if (value == null || value.isEmpty) return "Required";
        if (value.length < 6) return "Minimum 6 characters";
        return null;
      },
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        label: const Text("New Password"),
        labelStyle: const TextStyle(color: Colors.white70),
        hintText: "Enter New Password",
        suffixIcon: IconButton(
          icon: Icon(
            isPasswordVisible ? IconlyLight.show : IconlyLight.hide,
            color: Colors.white70,
          ),
          onPressed: () {
            setState(() {
              isPasswordVisible = !isPasswordVisible;
            });
          },
        ),
      ),
      style: const TextStyle(color: Colors.white),
    );
  }

  // Confirm Password Field
  Widget _confirmPasswordField() {
    return TextFormField(
      controller: _confirmController,
      obscureText: !isConfirmVisible,
      onChanged: (value) => setState(() {}),
      validator: (value) {
        if (value == null || value.isEmpty) return "Required";
        if (value.length < 6) return "Minimum 6 characters";
        if (value != _passwordController.text) return "Passwords do not match";
        return null;
      },
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        label: const Text("Confirm New Password"),
        labelStyle: const TextStyle(color: Colors.white70),
        hintText: "Enter New Password",
        suffixIcon: IconButton(
          icon: Icon(
            isConfirmVisible ? IconlyLight.show : IconlyLight.hide,
            color: Colors.white70,
          ),
          onPressed: () {
            setState(() {
              isConfirmVisible = !isConfirmVisible;
            });
          },
        ),
      ),
      style: const TextStyle(color: Colors.white),
    );
  }

  // Save Button
  Widget _saveButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isButtonEnabled ? const Color(0xFFFF4B8B) : Colors.grey.shade400,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        fixedSize: Size.fromWidth(MediaQuery.of(context).size.width),
      ),
      onPressed: isButtonEnabled
          ? () {
        if (_formKey.currentState!.validate()) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Password successfully changed!")),
          );
        }
      }
          : null,
      child: const Text("Save"),
    );
  }

}

class _TopWaveClipperReset extends CustomClipper<Path> {
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
