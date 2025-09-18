import 'package:flutter/material.dart';

class MarqueeBar extends StatefulWidget {
  const MarqueeBar({super.key, required this.items, this.saleMode = false});

  final List<String> items; // e.g., brand names
  final bool saleMode; // if true, show SALE; else show brand names

  @override
  State<MarqueeBar> createState() => _MarqueeBarState();
}

class _MarqueeBarState extends State<MarqueeBar> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 12))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.saleMode ? List.filled(6, 'SALE').join('   •   ') : widget.items.join('   •   ');

    return SizedBox(
      height: 36,
      child: ClipRect(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, _) {
            final width = MediaQuery.of(context).size.width;
            final dx = (1 - _ctrl.value) * width; // slide right to left
            return Stack(children: [
              Transform.translate(
                offset: Offset(dx, 0),
                child: _buildStrip(text, context),
              ),
              Transform.translate(
                offset: Offset(dx - width, 0),
                child: _buildStrip(text, context),
              ),
            ]);
          },
        ),
      ),
    );
  }

  Widget _buildStrip(String text, BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        color: Theme.of(context).colorScheme.secondaryContainer,
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.visible,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}