import 'package:flutter/material.dart';
import '../models/brand.dart';

class BrandCard extends StatelessWidget {
  const BrandCard({super.key, required this.brand, required this.onTap});

  final Brand brand;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: _BrandLogo(asset: brand.logoAsset),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                brand.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _BrandLogo extends StatelessWidget {
  const _BrandLogo({required this.asset});
  final String asset;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _assetExists(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done ||
            snapshot.data == false) {
          return const Center(child: Icon(Icons.watch));
        }
        return Image.asset(asset, fit: BoxFit.contain);
      },
    );
  }

  Future<bool> _assetExists(BuildContext context) async {
    try {
      await DefaultAssetBundle.of(context).load(asset);
      return true;
    } catch (_) {
      return false;
    }
  }
}
