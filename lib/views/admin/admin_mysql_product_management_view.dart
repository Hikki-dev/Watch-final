import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:watch_store/models/mysql_product.dart';
import 'package:watch_store/services/api_service.dart';

class AdminMysqlProductManagementView extends StatefulWidget {
  const AdminMysqlProductManagementView({super.key});

  @override
  State<AdminMysqlProductManagementView> createState() =>
      _AdminMysqlProductManagementViewState();
}

class _AdminMysqlProductManagementViewState
    extends State<AdminMysqlProductManagementView> {
  late Future<List<MysqlProduct>> _productsFuture;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _productsFuture = _fetchProducts();
  }

  Future<List<MysqlProduct>> _fetchProducts() async {
    try {
      final data = await ApiService.getProducts();
      return data.map((json) => MysqlProduct.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error loading products: $e');
      throw Exception('Failed to load products');
    }
  }

  Future<void> _deleteProduct(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product?'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ApiService.deleteProduct(id);
        setState(() {
          _productsFuture = _fetchProducts();
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error deleting product: $e')));
        }
      }
    }
  }

  Future<void> _showProductDialog({MysqlProduct? product}) async {
    final isEditing = product != null;

    // Form Controllers
    final nameController = TextEditingController(text: product?.name ?? '');
    final descController = TextEditingController(
      text: product?.description ?? '',
    );
    final priceController = TextEditingController(
      text: product?.price.toString() ?? '',
    );
    final stockController = TextEditingController(
      text: product?.stock.toString() ?? '',
    );
    final brandController = TextEditingController(
      text: 'Rolex',
    ); // Default or extract if model supports
    final modelController = TextEditingController(
      text: 'Submariner',
    ); // Default
    int categoryId = 1; // Default

    // Image State
    File? selectedImage;
    String? existingImageUrl = product?.imageUrl;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          Future<void> pickImage() async {
            final XFile? image = await _picker.pickImage(
              source: ImageSource.gallery,
            );
            if (image != null) {
              setState(() {
                selectedImage = File(image.path);
              });
            }
          }

          return AlertDialog(
            title: Text(isEditing ? 'Edit Product' : 'Add Product'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Image Picker UI
                  GestureDetector(
                    onTap: pickImage,
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: selectedImage != null
                          ? Image.file(selectedImage!, fit: BoxFit.cover)
                          : (existingImageUrl != null
                                ? Image.network(
                                    existingImageUrl,
                                    fit: BoxFit.cover,
                                  )
                                : const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_a_photo,
                                        size: 40,
                                        color: Colors.grey,
                                      ),
                                      Text(
                                        'Tap to select image',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  )),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Text Fields
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: priceController,
                          decoration: const InputDecoration(
                            labelText: 'Price',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: stockController,
                          decoration: const InputDecoration(
                            labelText: 'Stock',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: brandController,
                          decoration: const InputDecoration(
                            labelText: 'Brand',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: modelController,
                          decoration: const InputDecoration(
                            labelText: 'Model',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    initialValue: categoryId,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('Luxury')),
                      DropdownMenuItem(value: 2, child: Text('Sports')),
                      DropdownMenuItem(value: 3, child: Text('Classic')),
                      DropdownMenuItem(value: 4, child: Text('Smart')),
                      DropdownMenuItem(value: 5, child: Text('Other')),
                    ],
                    onChanged: (val) => setState(() => categoryId = val!),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  final messenger = ScaffoldMessenger.of(context);

                  try {
                    // Prepare Data Map (Strings for Multipart)
                    final fields = {
                      'name': nameController.text,
                      'description': descController.text,
                      'price': priceController.text,
                      'stock_quantity': stockController.text,
                      'category_id': categoryId.toString(),
                      'brand': brandController.text,
                      'model': modelController.text,
                    };

                    bool useMultipart = selectedImage != null;

                    if (isEditing) {
                      if (useMultipart) {
                        await ApiService.updateProductMultipart(
                          product.id,
                          fields,
                          selectedImage!.path,
                        );
                      } else {
                        await ApiService.updateProductMultipart(
                          product.id,
                          fields,
                          null,
                        );
                      }
                    } else {
                      await ApiService.createProductMultipart(
                        fields,
                        selectedImage?.path,
                      );
                    }

                    if (mounted) {
                      navigator.pop();
                      setState(() {
                        _productsFuture = _fetchProducts();
                      });
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            isEditing ? 'Product updated' : 'Product created',
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    messenger.showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                },
                child: Text(isEditing ? 'Save' : 'Create'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage MySQL Products'),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {
              _productsFuture = _fetchProducts();
            }),
          ),
        ],
      ),
      body: FutureBuilder<List<MysqlProduct>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading products:\n${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                  ElevatedButton(
                    onPressed: () =>
                        setState(() => _productsFuture = _fetchProducts()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No products found.'));
          }

          final products = snapshot.data!;
          return ListView.builder(
            itemCount: products.length,
            padding: const EdgeInsets.only(bottom: 80),
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: product.imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(
                            product.imageUrl!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.watch),
                          ),
                        )
                      : const Icon(Icons.watch),
                  title: Text(product.name),
                  subtitle: Text(
                    '\$${product.price} | ${product.stock} in stock',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showProductDialog(product: product),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteProduct(product.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProductDialog(),
        backgroundColor: Colors.amber,
        child: const Icon(Icons.add),
      ),
    );
  }
}
