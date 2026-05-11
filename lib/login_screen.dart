import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:recipe_app/main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final confirmPassCtrl = TextEditingController();

  bool isSignup = false;
  bool passHide = true;
  bool confirmPassHide = false;
  bool loading = false;

  Future<void> resetPassword() async {
    if (emailCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Enter your email first")));
      return;
    }
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailCtrl.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Reset link sent to your email")));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> auth() async {
    if (emailCtrl.text.trim().isEmpty || passCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Fill all fields")));
      return;
    }
    if (passCtrl.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password min 6 characters")));
      return;
    }
    if (isSignup && passCtrl.text != confirmPassCtrl.text) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Password not match")));
      return;
    }

    setState(() => loading = true);
    try {
      if (isSignup) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: emailCtrl.text.trim(), password: passCtrl.text.trim());
      } else {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: emailCtrl.text.trim(), password: passCtrl.text.trim());
      }
      if (mounted)
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const AuthWrapper()));
    } on FirebaseAuthException catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.red, content: Text(e.message.toString())));
    }
    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 80),
        child: Column(
          children: [
            const Icon(Icons.restaurant_menu, size: 80, color: Colors.orange),
            const SizedBox(height: 10),
            Text(isSignup ? "Create New Account" : "Welcome Back",
                style:
                    const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            Text(
                isSignup
                    ? "Signup to add your recipes"
                    : "Login to your account",
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 40),
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                  labelText: "Email",
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12))),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: passCtrl,
              obscureText: passHide,
              decoration: InputDecoration(
                labelText: "Password",
                prefixIcon: Icon(Icons.lock),
                suffixIcon: IconButton(
                    onPressed: () => setState(() => passHide = !passHide),
                    icon: Icon(
                        passHide ? Icons.visibility_off : Icons.visibility)),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            if (!isSignup)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                    onPressed: resetPassword, child: Text("Forgot Password?")),
              ),
            if (isSignup)
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: TextField(
                  controller: confirmPassCtrl,
                  obscureText: confirmPassHide,
                  decoration: InputDecoration(
                    labelText: "Confirm Password",
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: IconButton(
                        onPressed: () =>
                            setState(() => confirmPassHide = !confirmPassHide),
                        icon: Icon(confirmPassHide
                            ? Icons.visibility_off
                            : Icons.visibility)),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : auth,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: loading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(isSignup ? "Sign Up" : "Login",
                        style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
            TextButton(
                onPressed: () => setState(() => isSignup = !isSignup),
                child: Text(
                    isSignup
                        ? "Already have account? Login"
                        : "Don't have account? SignUp",
                    style: TextStyle(color: Colors.orange, fontSize: 16)))
          ],
        ),
      ),
    );
  }
}
