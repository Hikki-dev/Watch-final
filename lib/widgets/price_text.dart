import 'package:flutter/material.dart';

class PriceText extends StatelessWidget {
  const PriceText(this.value, {super.key});
  final double value;
  @override
  Widget build(BuildContext context) {
    return Text('\$${value.toStringAsFixed(2)}',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.primary,
        ));
  }
}
