// lib/views/login_view.dart
import 'package:flutter/material.dart';
import '../controllers/app_controller.dart';
import 'register_view.dart';

class LoginView extends StatefulWidget {
  final AppController controller;

  const LoginView({super.key, required this.controller});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _hidePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.controller.login(_emailController.text, _passwordController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Icon(Icons.watch, size: 80, color: Theme.of(context).colorScheme.primary),
                SizedBox(height: 20),
                Text('Welcome Back', style: Theme.of(context).textTheme.headlineMedium),
                SizedBox(height: 40),
                
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
                SizedBox(height: 24),
                
                // Login Button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _login,
                    child: Text('Login'),
                  ),
                ),
                SizedBox(height: 16),
                
                // Register Link
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RegisterView(controller: widget.controller),
                    ),
                  ),
                  child: Text('Create Account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}