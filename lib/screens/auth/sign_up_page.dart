import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final email = TextEditingController();
  final username = TextEditingController();
  final pass = TextEditingController();
  final confirm = TextEditingController();

  bool loading = false;
  bool obscure1 = true;
  bool obscure2 = true;

  static const primaryColor = Color(0xFF4C7FFF);
  static const errorColor = Colors.redAccent;

  Future<void> register() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please fill in all fields correctly to continue.",
          ),
          backgroundColor: errorColor,
        ),
      );
      return;
    }

    if (pass.text.trim() != confirm.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Passwords do not match"),
          backgroundColor: errorColor,
        ),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.text.trim(),
        password: pass.text.trim(),
      );

      final uid = cred.user!.uid;

      final bytes = utf8.encode(pass.text.trim());
      final passwordHash = md5.convert(bytes).toString();

      final ref = FirebaseDatabase.instance.ref('accounts/$uid');
      await ref.set({
        "email": email.text.trim(),
        "username": username.text.trim(),
        "password_hash_md5_rtdb": passwordHash,
        "role": "user",
      });

      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Registration successful! Please log in."),
          backgroundColor: primaryColor,
        ),
      );

      Navigator.pushReplacementNamed(context, "/");
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'weak-password') {
        errorMessage = 'Password is too weak (minimum 6 characters).';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'Email already registered.';
      } else {
        errorMessage = 'Authentication error: ${e.message}';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: errorColor),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("An unexpected error occurred: ${e.toString()}"),
          backgroundColor: errorColor,
        ),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Widget customField({
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool password = false,
    bool second = false,
  }) {
    final bool currentObscure = second ? obscure2 : obscure1;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: primaryColor.withValues(alpha: 0.5)),
        color: Colors.white,
      ),

      child: TextFormField(
        controller: controller,

        obscureText: password ? currentObscure : false,
        style: const TextStyle(color: Colors.black87),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade500),

          prefixIcon: Icon(icon, color: primaryColor),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 15,
          ),
          border: InputBorder.none,
          suffixIcon: password
              ? IconButton(
                  icon: Icon(
                    currentObscure ? Icons.visibility_off : Icons.visibility,
                    color: primaryColor,
                  ),
                  onPressed: () => setState(() {
                    if (second) {
                      obscure2 = !obscure2;
                    } else {
                      obscure1 = !obscure1;
                    }
                  }),
                )
              : null,
        ),

        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'This field cannot be empty';
          }
          if (password && !second && value.length < 6) {
            return 'Password must be at least 6 characters';
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.3),
              spreadRadius: 3,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                customField(
                  hint: "Full Name",
                  icon: Icons.person,
                  controller: username,
                ),

                const SizedBox(height: 15),

                customField(
                  hint: "Email",
                  icon: Icons.email,
                  controller: email,
                ),

                const SizedBox(height: 15),

                customField(
                  hint: "Password (Min 6 Characters)",
                  icon: Icons.lock,
                  controller: pass,
                  password: true,
                ),

                const SizedBox(height: 15),

                customField(
                  hint: "Confirm Password",
                  icon: Icons.lock_outline,
                  controller: confirm,
                  password: true,
                  second: true,
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton(
                    onPressed: loading ? null : register,
                    style: FilledButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: loading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            "Register",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
