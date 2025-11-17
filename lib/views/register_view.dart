// lib/views/register_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/app_controller.dart';
import '../services/auth_service.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  // 1. --- Simplified Controllers ---
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _hidePassword = true;
  bool _agreeTerms = false;
  // ---------------------------------

  // 2. --- Removed Unwanted State Variables ---
  // final _phoneController = TextEditingController();
  // final _addressController = TextEditingController();
  // String _selectedCountry = 'United States';
  // String _selectedGender = 'Male';
  // DateTime? _birthDate;
  // bool _newsletter = false;
  // final Set<String> _interests = {};
  // ... and removed the corresponding lists ...
  // ---------------------------------

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.read<AppController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // --- 3. Simplified Form ---

            // 1. TEXT FIELD - Name
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // 2. EMAIL FIELD
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // 3. PASSWORD FIELD
            TextField(
              controller: _passwordController,
              obscureText: _hidePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _hidePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () =>
                      setState(() => _hidePassword = !_hidePassword),
                ),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // 4. CHECKBOX - Terms
            CheckboxListTile(
              value: _agreeTerms,
              onChanged: (val) => setState(() => _agreeTerms = val ?? false),
              title: const Text('I agree to Terms & Conditions'),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: 32),

            // --- All other fields removed ---

            // Register Button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  if (!_agreeTerms) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please agree to terms')),
                    );
                    return;
                  }

                  // Check if essential fields are filled
                  if (_nameController.text.isEmpty ||
                      _emailController.text.isEmpty ||
                      _passwordController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill all fields')),
                    );
                    return;
                  }

                  final authService = context.read<AuthService>();
                  final userCredential = await authService.signUpWithEmail(
                    email: _emailController.text,
                    password: _passwordController.text,
                    name: _nameController.text,
                  );

                  if (!context.mounted) return;

                  if (userCredential != null) {
                    controller.setUserFullName(_nameController.text);
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Registration failed. Try another email.',
                        ),
                      ),
                    );
                  }
                },
                child: const Text('Create Account'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
