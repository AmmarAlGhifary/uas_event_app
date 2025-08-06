import 'package:flutter/material.dart';
import 'package:uas_event_app/api/api_service.dart'; // Sesuaikan path jika perlu

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // --- State Variables ---
  final _nameController = TextEditingController();
  final _studentNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  // --- API Service Instance ---
  final ApiService _apiService = ApiService();

  @override
  void dispose() {
    _nameController.dispose();
    _studentNumberController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Handles the entire registration logic, including UI updates and API calls.
  void _handleRegister() async {
    // Basic validation
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password dan Konfirmasi Password tidak cocok!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show loading indicator
    setState(() {
      _isLoading = true;
    });

    try {
      await _apiService.registerUser(
        name: _nameController.text,
        studentNumber: _studentNumberController.text,
        password: _passwordController.text,
      );

      // On success, show a green SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registrasi berhasil! Silakan login.'),
          backgroundColor: Colors.green,
        ),
      );

      // After a short delay, pop back to the login screen
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.of(context).pop();
        }
      });
    } catch (e) {
      // On failure, show a red SnackBar with the error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst("Exception: ", "")), // Clean up message
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // Hide loading indicator, whether success or failure
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.primary,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Header Section ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Buat Akun Baru',
                    style: TextStyle(
                      color: colors.onPrimary,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Daftar untuk menemukan event-event menarik.',
                    style: TextStyle(
                      color: colors.onPrimary.withOpacity(0.8),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            // --- Form Section ---
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
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Registrasi',
                        style: TextStyle(
                          color: colors.onSurface,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // All TextFormFields remain the same...
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Nama Lengkap', prefixIcon: Icon(Icons.badge_outlined), border: OutlineInputBorder()),
                        keyboardType: TextInputType.name,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _studentNumberController,
                        decoration: const InputDecoration(labelText: 'NIM / Nomor Mahasiswa', prefixIcon: Icon(Icons.person_outline), border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: !_isConfirmPasswordVisible,
                        decoration: InputDecoration(
                          labelText: 'Konfirmasi Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(_isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Upgraded Register Button
                      FilledButton(
                        onPressed: _isLoading ? null : _handleRegister, // Disable button when loading
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: _isLoading
                            ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: colors.onPrimary,
                            strokeWidth: 3,
                          ),
                        )
                            : const Text('Daftar'),
                      ),
                      const SizedBox(height: 24),

                      // Link back to Login
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Sudah punya akun?'),
                          TextButton(
                            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                            child: const Text('Masuk di sini'),
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
