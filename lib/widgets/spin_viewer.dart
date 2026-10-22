// lib/widgets/spin_viewer.dart
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'universal_image.dart';

/// Lets the surrounding UI (e.g. Front / Side / Back chips) drive a [SpinViewer].
class SpinController {
  _SpinViewerState? _state;

  /// Eases to a position given as a fraction of a full turn (0 = front, 0.5 = back).
  void goToFraction(double fraction) => _state?._goTo(fraction);
}

/// Drag-to-rotate 360° viewer: scrubs through an ordered set of frames, the way
/// luxury watch sites do. Frames can be bundled assets or network URLs.
/// With fewer than [minFrames] it shows the first image only.
class SpinViewer extends StatefulWidget {
  final List<String> frames;
  final SpinController? controller;
  final bool autoPlay;
  final int minFrames;
  final BoxFit fit;

  const SpinViewer({
    super.key,
    required this.frames,
    this.controller,
    this.autoPlay = true,
    this.minFrames = 8,
    this.fit = BoxFit.contain,
  });

  @override
  State<SpinViewer> createState() => _SpinViewerState();
}

class _SpinViewerState extends State<SpinViewer>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  Duration _last = Duration.zero;
  double _pos = 0; // in frames, wraps
  double _velocity = 0; // frames per tick
  bool _dragging = false;
  bool _auto = false;
  double? _animFrom;
  double? _animTo;
  double _animT = 0;
  int _shown = 0;
  bool _precached = false;

  int get _n => widget.frames.length;
  bool get _spinnable => _n >= widget.minFrames;

  @override
  void initState() {
    super.initState();
    widget.controller?._state = this;
    _auto = widget.autoPlay;
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) _auto = false;
    if (!_precached && _spinnable) {
      _precached = true;
      for (final f in widget.frames) {
        precacheImage(UniversalImage.providerFor(f), context);
      }
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    if (widget.controller?._state == this) widget.controller?._state = null;
    super.dispose();
  }

  void _goTo(double fraction) {
    if (!_spinnable) return;
    final target = fraction * _n;
    final cur = _pos % _n;
    var diff = (target - cur) % _n;
    if (diff > _n / 2) diff -= _n;
    _animFrom = _pos;
    _animTo = _pos + diff;
    _animT = 0;
    _auto = false;
    _velocity = 0;
  }

  void _onTick(Duration elapsed) {
    final dt = math.min(0.05, (elapsed - _last).inMicroseconds / 1e6);
    _last = elapsed;
    if (!_spinnable || _dragging) return;

    if (_animFrom != null) {
      _animT = math.min(1, _animT + dt / 0.9);
      final t = _animT;
      final e = t < .5 ? 4 * t * t * t : 1 - math.pow(-2 * t + 2, 3) / 2;
      _pos = _animFrom! + (_animTo! - _animFrom!) * e;
      if (_animT >= 1) _animFrom = null;
    } else if (_velocity.abs() > 0.01) {
      _pos += _velocity;
      _velocity *= math.pow(0.93, dt * 60).toDouble();
    } else if (_auto) {
      _pos += dt * _n * 0.1;
    } else {
      return;
    }

    final idx = ((_pos.round() % _n) + _n) % _n;
    if (idx != _shown) setState(() => _shown = idx);
  }

  void _onDrag(DragUpdateDetails d, double width) {
    _auto = false;
    _animFrom = null;
    final perPixel = _n / math.max(260, width * 1.1);
    final df = -d.delta.dx * perPixel;
    _pos += df;
    _velocity = df;
    final idx = ((_pos.round() % _n) + _n) % _n;
    if (idx != _shown) setState(() => _shown = idx);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.frames.isEmpty) return const SizedBox.shrink();
    final image = UniversalImage(
      imagePath: widget.frames[_spinnable ? _shown : 0],
      fit: widget.fit,
      gapless: true,
      errorWidget: const SizedBox.shrink(),
    );
    if (!_spinnable) return image;

    return LayoutBuilder(
      builder: (context, box) => Semantics(
        label: '360 degree view, drag to rotate',
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragStart: (_) => _dragging = true,
          onHorizontalDragUpdate: (d) => _onDrag(d, box.maxWidth),
          onHorizontalDragEnd: (_) => _dragging = false,
          onHorizontalDragCancel: () => _dragging = false,
          child: image,
        ),
      ),
    );
  }
}
