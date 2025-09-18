import 'package:flutter/material.dart';

class ShopPage extends StatelessWidget {
  const ShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.amberAccent,
          child: Image.asset(
            'lib/images/logo.png',
            height: 240,
            color: Colors.amberAccent,
          ),
        ),
      ],
    );
  }
}
