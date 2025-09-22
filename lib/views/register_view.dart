// lib/views/register_view.dart
import 'package:flutter/material.dart';
import '../controllers/app_controller.dart';

class RegisterView extends StatefulWidget {
  final AppController controller;

  const RegisterView({super.key, required this.controller});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _hidePassword = true;
  bool _hideConfirm = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _register() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.controller.login(_emailController.text, _passwordController.text);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: 20),
                Icon(Icons.person_add, size: 80, color: Theme.of(context).colorScheme.primary),
                SizedBox(height: 20),
                Text('Join Watch Store', style: Theme.of(context).textTheme.headlineMedium),
                SizedBox(height: 40),
                
                // Name Field
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value?.isEmpty == true ? 'Enter name' : null,
                ),
                SizedBox(height: 16),
                
                // Email Field
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value?.isEmpty == true ? 'Enter email' : null,
                ),
                SizedBox(height: 16),
                
                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _hidePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_hidePassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _hidePassword = !_hidePassword),
                    ),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value?.isEmpty == true ? 'Enter password' : null,
                ),
                SizedBox(height: 16),
                
                // Confirm Password Field
                TextFormField(
                  controller: _confirmController,
                  obscureText: _hideConfirm,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_hideConfirm ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _hideConfirm = !_hideConfirm),
                    ),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value?.isEmpty == true) return 'Confirm password';
                    if (value != _passwordController.text) return 'Passwords do not match';
                    return null;
                  },
                ),
                SizedBox(height: 32),
                
                // Register Button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _register,
                    child: Text('Create Account'),
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