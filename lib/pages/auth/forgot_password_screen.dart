import 'package:course_app/constant/constant.dart';
import 'package:flutter/material.dart';
import 'package:course_app/constants/color.dart';
import 'package:iconly/iconly.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/style.dart';
import 'package:course_app/pages/auth/reset_password_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  // ---------------------- Controllers + Form Key ----------------------
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  String _otpCode = "";

  // Condition pour activer/désactiver bouton
  bool get isButtonEnabled {
    return _emailController.text.isNotEmpty &&
        _emailController.text.length >= 6 &&
        _otpCode.length >= 6;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      body: SafeArea(
        child: Stack(
          children: [
            // Vague rose en haut
            Align(
              alignment: Alignment.topCenter,
              child: ClipPath(
                clipper: _TopWaveClipperForgot(),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.4,
                  width: double.infinity,
                  color: const Color(0xFFFF4B8B),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: _back(context),
                      ),
                      const SizedBox(height: 16),
                      Center(child: _title()),
                      const SizedBox(height: 8),
                      Center(child: _subTitle()),
                    ],
                  ),
                ),
              ),
            ),

            // Contenu principal
            Align(
              alignment: Alignment.center,
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
                child: Form(
                  key: _formKey,
                  child: _form(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------- Widgets ----------------------

  Widget _back(context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            IconlyLight.arrow_left,
            color: Colors.white,
          ),
          const SizedBox(width: 8),
          Text(
            "Back",
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _image() {
    return Image.asset(
      "assets/FORGET.jpg",
      width: 300,
    );
  }

  Widget _title() {
    return Text(
      "Forgot Password?",
      textAlign: TextAlign.center,
      style: Theme.of(context)
          .textTheme
          .bodyLarge
          ?.copyWith(fontSize: 24, color: Colors.white),
    );
  }

  Widget _subTitle() {
    return const Text(
      "Don't worry! Input your email for reset password",
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.white70),
    );
  }

  // ---------------------- FORM ----------------------

  Widget _form() {
    const SizedBox gap = SizedBox(height: 10);
    const SizedBox gap2 = SizedBox(height: 20);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label("Email Address"),
        gap,
        _emailField(),
        gap2,
        _label("OTP Code"),
        gap,
        _otpField(),
        gap2,
        _sentButton(),
      ],
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
          fontWeight: FontWeight.w600, color: Colors.white70),
    );
  }

  // ---------------- EMAIL FIELD ------------------

  Widget _emailField() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: TextFormField(
            controller: _emailController,
            onChanged: (value) {
              setState(() {}); // Update validation
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Email obligatoire";
              }
              if (!value.contains("@")) {
                return "Format email incorrect";
              }
              if (value.length < 6) {
                return "Minimum 6 caractères";
              }
              return null;
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              label: const Text("Email"),
              labelStyle: const TextStyle(color: Colors.white70),
              hintText: 'Enter Email',
              hintStyle: const TextStyle(color: Colors.white38),
            ),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              elevation: 0,
              backgroundColor: const Color(0xFFFF4B8B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {},
            child: Icon(IconlyLight.arrow_right),
          ),
        ),
      ],
    );
  }

  // ---------------- OTP FIELD ------------------

  Widget _otpField() {
    return OTPTextField(
      contentPadding: const EdgeInsets.symmetric(vertical: 20),
      length: 6,
      width: MediaQuery.of(context).size.width,
      textFieldAlignment: MainAxisAlignment.spaceAround,
      fieldWidth: 50,
      fieldStyle: FieldStyle.box,
      outlineBorderRadius: 15,
      style: TextStyle(fontSize: 17),
      onChanged: (pin) {
        setState(() {
          _otpCode = pin;
        });
      },
      onCompleted: (pin) {
        setState(() {
          _otpCode = pin;
        });
      },
    );
  }

  // ---------------- BUTTON SEND ------------------

  Widget _sentButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFF4B8B),
        fixedSize: Size.fromWidth(MediaQuery.of(context).size.width),
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      onPressed: isButtonEnabled
          ? () {
              if (_formKey.currentState!.validate()) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ResetPasswordScreen(),
                  ),
                );
              }
            }
          : null,
      child: const Text("Send"),
    );
  }

}

class _TopWaveClipperForgot extends CustomClipper<Path> {
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
