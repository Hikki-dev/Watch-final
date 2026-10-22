// lib/widgets/lux_widgets.dart
import 'package:flutter/material.dart';

import '../models/brand.dart';
import '../theme/lux_theme.dart';
import 'universal_image.dart';

/// Small uppercase label, used above headings and in metadata rows.
class Eyebrow extends StatelessWidget {
  final String text;
  final Color? color;
  const Eyebrow(this.text, {super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
    );
  }
}

/// Prices and references are set in a monospaced face.
class PriceText extends StatelessWidget {
  final String text;
  final double size;
  final Color? color;
  const PriceText(this.text, {super.key, this.size = 15, this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: LuxFonts.mono,
        fontSize: size,
        color: color ?? context.lux.text,
      ),
    );
  }
}

/// Soft studio backdrop behind photography.
class LuxStage extends StatelessWidget {
  final Widget child;
  final double? height;
  final BorderRadius? radius;
  const LuxStage({super.key, required this.child, this.height, this.radius});

  @override
  Widget build(BuildContext context) {
    final c = context.lux;
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: c.stage,
        borderRadius: radius,
        border: Border.all(color: c.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

/// Brand logos arrive as opaque white PNGs, so they always sit on a white plate.
class BrandLogoPlate extends StatelessWidget {
  final String brand;
  final double height;
  final double? width;
  const BrandLogoPlate({
    super.key,
    required this.brand,
    this.height = 48,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final path = Brand.getLogoForBrand(brand);
    return Container(
      height: height,
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: context.lux.line),
        borderRadius: BorderRadius.circular(2),
      ),
      alignment: Alignment.center,
      child: path == null
          ? Text(
              brand.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: LuxFonts.sans,
                fontSize: 11,
                letterSpacing: 2,
                color: Color(0xFF121315),
              ),
            )
          : UniversalImage(
              imagePath: path,
              fit: BoxFit.contain,
              errorWidget: const SizedBox.shrink(),
            ),
    );
  }
}

/// Round light/dark switch used in app bars.
class ThemeToggleButton extends StatelessWidget {
  final ThemeMode mode;
  final ValueChanged<ThemeMode> onChanged;
  const ThemeToggleButton({
    super.key,
    required this.mode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.lux;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Semantics(
      button: true,
      label: 'Switch colour mode',
      child: InkResponse(
        onTap: () => onChanged(isDark ? ThemeMode.light : ThemeMode.dark),
        radius: 26,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: c.panel,
            border: Border.all(color: c.line),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, anim) => RotationTransition(
              turns: Tween<double>(begin: 0.85, end: 1).animate(anim),
              child: FadeTransition(opacity: anim, child: child),
            ),
            child: Icon(
              isDark ? Icons.wb_sunny_outlined : Icons.dark_mode_outlined,
              key: ValueKey(isDark),
              size: 20,
              color: c.text,
            ),
          ),
        ),
      ),
    );
  }
}

enum PillKind { live, review, rejected }

class StatusPill extends StatelessWidget {
  final String label;
  final PillKind kind;
  const StatusPill(this.label, {super.key, required this.kind});

  @override
  Widget build(BuildContext context) {
    final c = context.lux;
    final color = switch (kind) {
      PillKind.live => c.ok,
      PillKind.review => c.warn,
      PillKind.rejected => c.bad,
    };
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontFamily: LuxFonts.sans,
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.1,
          color: color,
        ),
      ),
    );
  }
}

/// Fades and rises its child into place. Used for staggered entrances.
class Reveal extends StatelessWidget {
  final Widget child;
  final int index;
  const Reveal({super.key, required this.child, this.index = 0});

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 700 + index * 120),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, (1 - t) * 18), child: child),
      ),
      child: child,
    );
  }
}
