import 'package:flutter/material.dart';
import 'package:uas_event_app/screens/register_screen.dart'; // Adjust import if needed

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _studentNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _studentNumberController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.primary,
      body: SafeArea(
        // The top-level SingleChildScrollView is REMOVED.
        // The main layout is now a Column.
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Header Section (No changes here) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selamat Datang\nKembali',
                    style: TextStyle(
                      color: colors.onPrimary,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Masuk untuk melihat event seru menantimu.',
                    style: TextStyle(
                      color: colors.onPrimary.withOpacity(0.8),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            // --- Form Section ---
            // The Container is now wrapped in an Expanded widget.
            // This forces it to fill all remaining vertical space.
            Expanded(
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                // The SingleChildScrollView is MOVED INSIDE the container.
                // It now only wraps the form fields.
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min, // Important for scroll view content
                    children: [
                      Text(
                        'Login',
                        style: TextStyle(
                          color: colors.onSurface,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Student Number TextField
                      TextFormField(
                        controller: _studentNumberController,
                        decoration: const InputDecoration(
                          labelText: 'NIM / Nomor Mahasiswa',
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),

                      // Password TextField
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Login Button
                      FilledButton(
                        onPressed: () {
                          // TODO: Implement login logic
                          final studentNumber = _studentNumberController.text;
                          final password = _passwordController.text;
                          print('Login attempt: $studentNumber');
                        },
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: const Text('Login'),
                      ),
                      const SizedBox(height: 24),

                      // Link to Register Screen
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Belum punya akun?'),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => const RegisterScreen(),
                              ));
                            },
                            child: const Text('Daftar di sini'),
                          ),
                        ],
                      ),
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
}