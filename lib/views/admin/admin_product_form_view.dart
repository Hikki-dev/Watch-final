import 'dart:convert'; // for base64Encode
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../services/image_service.dart';

import '../../models/watch.dart';
import '../../services/data_service.dart';

class AdminProductFormView extends StatefulWidget {
  final Watch? watch; // If null, we are adding a new product

  const AdminProductFormView({super.key, this.watch});

  @override
  State<AdminProductFormView> createState() => _AdminProductFormViewState();
}

class _AdminProductFormViewState extends State<AdminProductFormView> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();

  // Comptrollers
  late TextEditingController _nameController;
  late TextEditingController _brandController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  late TextEditingController _categoryController;
  late TextEditingController _stockController;

  // State

  Uint8List? _pickedImageBytes; // For preview
  String? _currentImageUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final w = widget.watch;
    _nameController = TextEditingController(text: w?.name ?? '');
    _brandController = TextEditingController(text: w?.brand ?? '');
    _priceController = TextEditingController(text: w?.price.toString() ?? '');
    _descriptionController = TextEditingController(text: w?.description ?? '');
    _categoryController = TextEditingController(text: w?.category ?? '');
    _stockController = TextEditingController(text: w?.stock.toString() ?? '10');
    _currentImageUrl = w?.imagePath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final imageService = ImageService();
    final picked = await imageService.pickImage(source: source);

    if (picked != null) {
      // We actually need the bytes for the UI preview (Image.memory)
      // and the string for saving.
      final bytes = await picked.readAsBytes();

      setState(() {
        _pickedImageBytes = bytes;
      });
    }
  }

  Future<String?> _processImage() async {
    // If no new image picked, return existing URL/Base64
    if (_pickedImageBytes == null) return _currentImageUrl;

    try {
      // Re-use logic: bytes to base64
      // We can use the service helper if we had XFile kept, but we only kept bytes.
      // So we can just encode manually or add a bytesToBase64 to service.
      // Adding it to service is cleaner.
      return 'data:image/jpeg;base64,${base64Encode(_pickedImageBytes!)}';
    } catch (e) {
      debugPrint('Error encoding image: $e');
      return null;
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // 1. Process Image
      final imageString = await _processImage();
      if (!mounted) return;
      if (imageString == null && _currentImageUrl == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Please select an image')));
        setState(() => _isLoading = false);
        return;
      }

      // 2. Create Watch Object
      final id = widget.watch?.id ?? _uuid.v4();
      final newWatch = Watch(
        id: id,
        name: _nameController.text.trim(),
        brand: _brandController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        category: _categoryController.text.trim(),
        description: _descriptionController.text.trim(),
        imagePath: imageString!,
        stock: int.parse(_stockController.text.trim()),
      );

      // 3. Save to Firestore
      final dataService = DataService();

      if (widget.watch == null) {
        await dataService.addWatch(newWatch);
      } else {
        await dataService.updateWatch(newWatch);
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Product Saved!')));
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Error saving product: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.watch == null ? 'Add Product' : 'Edit Product'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // --- Image Picker ---
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (c) => Wrap(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.photo),
                                title: const Text('Gallery'),
                                onTap: () {
                                  Navigator.pop(c);
                                  _pickImage(ImageSource.gallery);
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.camera_alt),
                                title: const Text('Camera'),
                                onTap: () {
                                  Navigator.pop(c);
                                  _pickImage(ImageSource.camera);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _pickedImageBytes != null
                            ? Image.memory(
                                _pickedImageBytes!,
                                fit: BoxFit.cover,
                              )
                            : (_currentImageUrl != null
                                  ? Image.network(
                                      _currentImageUrl!,
                                      fit: BoxFit.cover,
                                    )
                                  : const Icon(
                                      Icons.add_a_photo,
                                      size: 50,
                                      color: Colors.grey,
                                    )),
                      ),
                    ),
                    // Just a quick fix for the preview widget above to be actually correct:
                    if (_pickedImageBytes != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: const Text(
                          'New image selected',
                          style: TextStyle(color: Colors.green),
                        ),
                      ),

                    const SizedBox(height: 16),

                    // --- Fields ---
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Product Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _brandController,
                      decoration: const InputDecoration(
                        labelText: 'Brand',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Price',
                              border: OutlineInputBorder(),
                              prefixText: '\$',
                            ),
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _stockController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Stock',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _categoryController,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton(
                        onPressed: _save,
                        child: const Text('Save Product'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
