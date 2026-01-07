import 'package:flutter/services.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/brand.dart';
import '../models/watch.dart';

class AdminSeeder {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- SEED DATA ---

  // Brands
  final List<Brand> _seedBrands = const [
    Brand(
      id: 'ap',
      name: 'Audemars Piguet',
      logoPath: 'assets/images/brands/ap.png',
    ),
    Brand(
      id: 'casio',
      name: 'Casio',
      logoPath: 'assets/images/brands/casio.png',
    ),
    Brand(
      id: 'citizen',
      name: 'Citizen',
      logoPath: 'assets/images/brands/citizen.png',
    ),
    Brand(
      id: 'omega',
      name: 'Omega',
      logoPath: 'assets/images/brands/omega.png',
    ),
    Brand(
      id: 'patek',
      name: 'Patek Philippe',
      logoPath: 'assets/images/brands/patek.png',
    ),
    Brand(
      id: 'richard_mille',
      name: 'Richard Mille',
      logoPath: 'assets/images/brands/richard_mille.png',
    ),
    Brand(
      id: 'rolex',
      name: 'Rolex',
      logoPath: 'assets/images/brands/rolex.png',
    ),
    Brand(
      id: 'seiko',
      name: 'Seiko',
      logoPath: 'assets/images/brands/seiko.png',
    ),
    Brand(
      id: 'swatch',
      name: 'Swatch',
      logoPath: 'assets/images/brands/swatch.png',
    ),
    Brand(
      id: 'tag_heuer',
      name: 'TAG Heuer',
      logoPath: 'assets/images/brands/tag_heuer.png',
    ),
  ];

  // Watches
  List<Watch> get _seedWatches => [
    Watch(
      id: 'ap_royal_oak_1',
      name: 'Royal Oak',
      brand: 'Audemars Piguet',
      price: 45000.0,
      category: 'Luxury',
      description: 'The legendary Royal Oak, designed by Gerald Genta.',
      imagePath: 'assets/images/watches/ap-royal-oak-1.jpg',
      stock: 5,
    ),
    Watch(
      id: 'ap_royal_oak_2',
      name: 'Royal Oak Chronograph',
      brand: 'Audemars Piguet',
      price: 55000.0,
      category: 'Luxury',
      description:
          'The Royal Oak Chronograph features a larger case and sporty aesthetic.',
      imagePath: 'assets/images/watches/ap-royal-oak-2.jpg',
      stock: 3,
    ),
    Watch(
      id: 'casio_gshock',
      name: 'G-Shock',
      brand: 'Casio',
      price: 150.0,
      category: 'Sport',
      description: 'The toughest watch of all time.',
      imagePath: 'assets/images/watches/casio-gshock.jpg',
      stock: 50,
    ),
    Watch(
      id: 'citizen_eco',
      name: 'Eco-Drive',
      brand: 'Citizen',
      price: 250.0,
      category: 'Casual',
      description: 'Powered by light, never needs a battery.',
      imagePath: 'assets/images/watches/citizen-watch.jpg',
      stock: 25,
    ),
    Watch(
      id: 'omega_seamaster',
      name: 'Seamaster',
      brand: 'Omega',
      price: 5200.0,
      category: 'Diver',
      description: 'The choice of James Bond.',
      imagePath: 'assets/images/watches/omega-seamaster-1.jpg',
      stock: 12,
    ),
    Watch(
      id: 'omega_speedmaster_1',
      name: 'Speedmaster Pro',
      brand: 'Omega',
      price: 6400.0,
      category: 'Chronograph',
      description: 'The first watch on the moon.',
      imagePath: 'assets/images/watches/omega-speedmaster-1.jpg',
      stock: 8,
    ),
    Watch(
      id: 'omega_speedmaster_2',
      name: 'Speedmaster Racing',
      brand: 'Omega',
      price: 6000.0,
      category: 'Chronograph',
      description: 'A racing inspired Speedmaster.',
      imagePath: 'assets/images/watches/omega-speedmaster-2.jpg',
      stock: 0, // EXAMPLE OUT OF STOCK
    ),
    Watch(
      id: 'patek_nautilus_1',
      name: 'Nautilus',
      brand: 'Patek Philippe',
      price: 120000.0,
      category: 'Luxury',
      description: 'The most coveted steel sports watch.',
      imagePath: 'assets/images/watches/patek-nautilus-1.jpg',
      stock: 1,
    ),
    Watch(
      id: 'patek_nautilus_2',
      name: 'Nautilus Date',
      brand: 'Patek Philippe',
      price: 130000.0,
      category: 'Luxury',
      description: 'Elegant version of the Nautilus.',
      imagePath: 'assets/images/watches/patek-nautilus-2.jpg',
      stock: 2,
    ),
    Watch(
      id: 'patek_calatrava',
      name: 'Calatrava',
      brand: 'Patek Philippe',
      price: 30000.0,
      category: 'Dress',
      description: 'The essence of the round wristwatch.',
      imagePath: 'assets/images/watches/patek-calatrava-1.jpg',
      stock: 5,
    ),
    Watch(
      id: 'rm_1',
      name: 'RM 11-03',
      brand: 'Richard Mille',
      price: 250000.0,
      category: 'Luxury Sport',
      description: 'A racing machine on the wrist.',
      imagePath: 'assets/images/watches/richard-mille-1.jpg',
      stock: 1,
    ),
    Watch(
      id: 'rm_2',
      name: 'RM 35-02',
      brand: 'Richard Mille',
      price: 300000.0,
      category: 'Luxury Sport',
      description: 'Designed for Rafael Nadal.',
      imagePath: 'assets/images/watches/richard-mille-2.jpg',
      stock: 0,
    ),
    Watch(
      id: 'rolex_sub_1',
      name: 'Submariner Date',
      brand: 'Rolex',
      price: 10500.0,
      category: 'Diver',
      description: 'The archetype of the diver\'s watch.',
      imagePath: 'assets/images/watches/rolex-submariner-1.jpg',
      stock: 15,
    ),
    Watch(
      id: 'rolex_sub_2',
      name: 'Submariner No Date',
      brand: 'Rolex',
      price: 9500.0,
      category: 'Diver',
      description: 'Symmetrical dial layout.',
      imagePath: 'assets/images/watches/rolex-submariner-2.jpg',
      stock: 10,
    ),
    Watch(
      id: 'rolex_gmt',
      name: 'GMT-Master II',
      brand: 'Rolex',
      price: 11000.0,
      category: 'Travel',
      description: 'Designed for international pilots.',
      imagePath: 'assets/images/watches/rolex-gmt-1.jpg',
      stock: 8,
    ),
    Watch(
      id: 'seiko_prospex',
      name: 'Prospex',
      brand: 'Seiko',
      price: 1200.0,
      category: 'Diver',
      description: 'Professional specifications.',
      imagePath: 'assets/images/watches/seiko-watch.jpg',
      stock: 30,
    ),
    Watch(
      id: 'swatch_sistem51',
      name: 'Sistem51',
      brand: 'Swatch',
      price: 150.0,
      category: 'Automatic',
      description: 'Automatic movement made entirely by robots.',
      imagePath: 'assets/images/watches/swatch-sistem51-irony-1.jpg',
      stock: 40,
    ),
    Watch(
      id: 'swatch_scuba',
      name: 'Scuba Libre',
      brand: 'Swatch',
      price: 100.0,
      category: 'Diver',
      description: 'Fun and colorful diver.',
      imagePath: 'assets/images/watches/swatch-scubaqua.jpg',
      stock: 20,
    ),
    Watch(
      id: 'tag_carrera',
      name: 'Carrera',
      brand: 'TAG Heuer',
      price: 4500.0,
      category: 'Racing',
      description: 'Born on the track.',
      imagePath: 'assets/images/watches/tag-heur-watch.jpg',
      stock: 10,
    ),
  ];

  // --- METHODS ---

  Future<void> seedAll() async {
    debugPrint("🚀 Starting Seed Process...");

    await seedBrands();
    await seedWatches();

    debugPrint("✅ Database Seeded Successfully!");
  }

  Future<void> seedBrands() async {
    final CollectionReference brandsRef = _firestore.collection('brands');

    for (var brand in _seedBrands) {
      debugPrint("Processing Brand: ${brand.name}");

      // 1. Upload Image
      String? imageUrl = await _uploadAssetToStorage(
        brand.logoPath,
        'brands/${brand.id}.png',
      );

      if (imageUrl != null) {
        // 2. Save to Firestore
        await brandsRef.doc(brand.id).set({
          'id': brand.id,
          'name': brand.name,
          'logoPath': imageUrl, // Save URL instead of local path
        });
        debugPrint("  -> Uploaded & Saved.");
      } else {
        debugPrint("  -> Failed to upload image.");
      }
    }
  }

  Future<void> seedWatches() async {
    final CollectionReference productsRef = _firestore.collection('products');

    for (var watch in _seedWatches) {
      debugPrint("Processing Watch: ${watch.name}");

      // 1. Upload Image
      String? imageUrl = await _uploadAssetToStorage(
        watch.imagePath,
        'watches/${watch.id}.jpg',
      );

      if (imageUrl != null) {
        // 2. Save to Firestore
        // Convert watch to map, but OVERRIDE imagePath with the URL
        final watchData = watch.toJson();
        watchData['imagePath'] = imageUrl;

        await productsRef.doc(watch.id).set(watchData);
        debugPrint("  -> Uploaded & Saved.");
      } else {
        debugPrint("  -> Failed to upload image.");
      }
    }
  }

  Future<String?> _uploadAssetToStorage(
    String assetPath,
    String storagePath,
  ) async {
    try {
      debugPrint("    [1/4] Loading asset: $assetPath");
      // Load asset data as bytes
      final ByteData data = await rootBundle.load(assetPath);
      final Uint8List bytes = data.buffer.asUint8List();
      debugPrint(
        "    [2/4] Asset loaded (${bytes.lengthInBytes} bytes). Creating ref: $storagePath",
      );

      // Create ref
      final Reference ref = _storage.ref().child(storagePath);

      // Upload
      debugPrint("    [3/4] Starting upload...");
      final UploadTask task = ref.putData(
        bytes,
        SettableMetadata(contentType: 'image/jpeg'),
      ); // Assuming jpg/png

      task.snapshotEvents.listen((event) {
        debugPrint(
          '      -> Upload Progress: ${(event.bytesTransferred / event.totalBytes * 100).toStringAsFixed(0)}%',
        );
      });

      final TaskSnapshot snapshot = await task;
      debugPrint("    [4/4] Upload finished. Getting URL...");

      // Get URL
      final url = await snapshot.ref.getDownloadURL();
      debugPrint("    [Success] URL: $url");
      return url;
    } catch (e, stack) {
      debugPrint("❌ Error uploading $assetPath: $e");
      debugPrint("Stack: $stack");
      return null;
    }
  }
}
