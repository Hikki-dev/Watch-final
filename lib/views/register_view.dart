// lib/views/register_view.dart - SIMPLIFIED with 12 field types
import 'package:flutter/material.dart';
import '../controllers/app_controller.dart';

class RegisterView extends StatefulWidget {
  final AppController controller;

  const RegisterView({super.key, required this.controller});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _addressController = TextEditingController();

  // State variables
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
      appBar: AppBar(title: Text('Create Account')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            // 1. TEXT FIELD - Name
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // 2. EMAIL FIELD
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // 3. PHONE FIELD
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Phone',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // 4. DATE PICKER
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
                decoration: InputDecoration(
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
            SizedBox(height: 16),

            // 5. DROPDOWN - Gender
            DropdownButtonFormField<String>(
              initialValue: _selectedGender,
              decoration: InputDecoration(
                labelText: 'Gender',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
              items: _genders
                  .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedGender = val!),
            ),
            SizedBox(height: 16),

            // 6. DROPDOWN - Country
            DropdownButtonFormField<String>(
              initialValue: _selectedCountry,
              decoration: InputDecoration(
                labelText: 'Country',
                prefixIcon: Icon(Icons.public),
                border: OutlineInputBorder(),
              ),
              items: _countries
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedCountry = val!),
            ),
            SizedBox(height: 16),

            // 7. MULTILINE TEXT - Address
            TextField(
              controller: _addressController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Address',
                prefixIcon: Icon(Icons.home),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // 8. PASSWORD FIELD
            TextField(
              controller: _passwordController,
              obscureText: _hidePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _hidePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () =>
                      setState(() => _hidePassword = !_hidePassword),
                ),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 24),

            // 9. FILTER CHIPS - Interests (multi-select)
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Interests', style: TextStyle(fontSize: 16)),
            ),
            SizedBox(height: 8),
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
            SizedBox(height: 16),

            // 10. SLIDER - Age Range
            SliderTheme(
              data: SliderTheme.of(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Preferred Watch Price Range'),
                  Slider(
                    value: 5000,
                    min: 0,
                    max: 50000,
                    divisions: 100,
                    label: '\$5000',
                    onChanged: (val) {},
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            // 11. SWITCH - Newsletter
            SwitchListTile(
              value: _newsletter,
              onChanged: (val) => setState(() => _newsletter = val),
              title: Text('Subscribe to Newsletter'),
              secondary: Icon(Icons.email_outlined),
            ),
            SizedBox(height: 8),

            // 12. CHECKBOX - Terms
            CheckboxListTile(
              value: _agreeTerms,
              onChanged: (val) => setState(() => _agreeTerms = val ?? false),
              title: Text('I agree to Terms & Conditions'),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            SizedBox(height: 32),

            // Register Button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  if (!_agreeTerms) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please agree to terms')),
                    );
                    return;
                  }
                  widget.controller.login(
                    _emailController.text,
                    _passwordController.text,
                  );
                  Navigator.pop(context);
                },
                child: Text('Create Account'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
