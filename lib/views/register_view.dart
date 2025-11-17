// lib/views/register_view.dart
import 'package:flutter/material.dart';
import '../controllers/app_controller.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class RegisterView extends StatefulWidget {
  // ... (constructor) ...
  final AppController controller;
  const RegisterView({super.key, required this.controller});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  // ... (controllers & state variables) ...
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _addressController = TextEditingController();

  bool _hidePassword = true;
  String _selectedCountry = 'United States';
  String _selectedGender = 'Male';
  DateTime? _birthDate;
  bool _agreeTerms = false;
  bool _newsletter = false;
  final Set<String> _interests = {};

  final List<String> _countries = [
    'United States',
    'United Kingdom',
    'Canada',
    'Australia',
  ];
  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _interestList = ['Luxury', 'Sport', 'Smart', 'Vintage'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // ... (Name, Email, Phone, Date fields) ...
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
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
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime(2000),
                  firstDate: DateTime(1950),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() => _birthDate = date);
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Birth Date',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  _birthDate == null
                      ? 'Select date'
                      : '${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}',
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ... (Gender, Country dropdowns) ...
            DropdownButtonFormField<String>(
              // --- FIX: Use initialValue ---
              initialValue: _selectedGender,
              decoration: const InputDecoration(
                labelText: 'Gender',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
              items: _genders
                  .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedGender = val!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              // --- FIX: Use initialValue ---
              initialValue: _selectedCountry,
              decoration: const InputDecoration(
                labelText: 'Country',
                prefixIcon: Icon(Icons.public),
                border: OutlineInputBorder(),
              ),
              items: _countries
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedCountry = val!),
            ),
            const SizedBox(height: 16),

            // ... (Address field with Geolocation) ...
            TextField(
              controller: _addressController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Address',
                prefixIcon: const Icon(Icons.home),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.location_searching),
                  onPressed: () async {
                    // Use controller from the widget
                    final address = await widget.controller
                        .getCurrentLocationAddress();
                    setState(() {
                      _addressController.text = address;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ... (Password field) ...
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

            // ... (Filter chips, Slider, Switch, Checkbox) ...
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Interests', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _interestList.map((interest) {
                return FilterChip(
                  label: Text(interest),
                  selected: _interests.contains(interest),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _interests.add(interest);
                      } else {
                        _interests.remove(interest);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            SliderTheme(
              data: SliderTheme.of(context),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Preferred Watch Price Range'),
                  Slider(
                    value: 5000,
                    min: 0,
                    max: 50000,
                    divisions: 100,
                    label: '\$5000',
                    onChanged: null, // (val) {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              value: _newsletter,
              onChanged: (val) => setState(() => _newsletter = val),
              title: const Text('Subscribe to Newsletter'),
              secondary: const Icon(Icons.email_outlined),
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              value: _agreeTerms,
              onChanged: (val) => setState(() => _agreeTerms = val ?? false),
              title: const Text('I agree to Terms & Conditions'),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: 32),

            // ... (Register Button) ...
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

                  final authService = context.read<AuthService>();

                  // This line is causing the "undefined parameter 'name'" error
                  // We will fix it in the next step.
                  final userCredential = await authService.signUpWithEmail(
                    email: _emailController.text,
                    password: _passwordController.text,
                    name: _nameController.text, // Pass the name
                  );

                  // --- FIX: Add mounted checks ---
                  if (!context.mounted) return;

                  if (userCredential != null) {
                    // Pass the name to the controller
                    widget.controller.setUserFullName(_nameController.text);
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Registration failed.')),
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
