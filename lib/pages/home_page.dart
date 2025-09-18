import 'package:flutter/material.dart';
import '../models/brand.dart';
import '../widgets/brand_card.dart';
import 'brand_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Adjust grid columns based on screen width
    final crossAxisCount = screenWidth > 600 ? 3 : 2;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _ScrollingBanner(
              imagePaths: brands.map((b) => b.logoAsset).toList(),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemCount: brands.length,
                itemBuilder: (context, index) {
                  final brand = brands[index];
                  return BrandCard(
                    brand: brand,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BrandPage(
                            brandId: brand.id,
                            brandName: brand.name,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScrollingBanner extends StatefulWidget {
  final List<String> imagePaths;

  const _ScrollingBanner({required this.imagePaths});

  @override
  State<_ScrollingBanner> createState() => _ScrollingBannerState();
}

class _ScrollingBannerState extends State<_ScrollingBanner> {
  final ScrollController _controller = ScrollController();
  double _position = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScrolling());
  }

  void _startScrolling() async {
    while (mounted) {
      await Future.delayed(const Duration(milliseconds: 40));
      if (!_controller.hasClients) continue;
      _position += 1;
      if (_position >= _controller.position.maxScrollExtent) {
        _position = 0;
      }
      _controller.jumpTo(_position);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      height: screenHeight * 0.1,
      child: ListView.builder(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        itemCount: widget.imagePaths.length,
        itemBuilder: (context, i) => Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
          child: Image.asset(
            widget.imagePaths[i],
            height: screenHeight * 0.06,
            width: screenWidth * 0.15,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
