// https://frontend.horse/articles/gooey-countdown-svg/ article Flutter implementation

import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';

const numbers = [
  "M87.9,79.2c1.1-0.4,53.7-39.2,54.9-39.1v180.5",
  "M81.7,85.7c-1.4-67,112.3-55.1,90.2,11.6c-12.6,32-70.6,83.7-88.8,113.7h105.8",
  "M74.8,178.5c3,39.4,63.9,46.7,88.6,23.7c34.3-35.1,5.4-75.8-41.7-77c29.9,5.5,68.7-43.1,36.5-73.7 c-23.4-21.5-76.5-11.1-78.6,25",
  "M161.9,220.8 161.9,41 72.6,170.9 208.2,170.9",
  "M183.2,43.7H92.1l-10,88.3c0,0,18.3-21.9,51-21.9s49.4,32.6,49.4,48.2c0,22.2-9.5,57-52.5,57s-51.4-36.7-51.4-36.7",
  "M177.4,71.6c0,0-4.3-30.3-44.9-30.3s-57.9,45.6-57.9,88.8s9,86.5,56.2,86.5c38.9,0,50.9-22.3,50.9-60.9c0-17.6-21-44.9-48.2-44.9c-36.2,0-55.2,29.6-55.2,58.2",
  "M73.3,43.7 177.7,43.7 97.9,220.6",
  "M126.8,122.8c0,0,48.2-1.3,48.2-42.2s-48.2-39.9-48.2-39.9s-45.9,0-45.9,40.9 c0,20.5,18.8,41.2,46.9,41.2c29.6,0,54.9,18,54.9,47.2c0,0,2,44.9-54.2,44.9c-55.5,0-54.2-43.9-54.2-43.9s-0.3-47.9,53.6-47.9",
  "M78.9,186.3c0,0,4.3,30.3,44.9,30.3s57.9-45.6,57.9-88.8s-9-86.5-56.2-86.5 c-38.9,0-50.9,22.3-50.9,60.9c0,17.6,21,44.9,48.2,44.9c36.2,0,55.2-29.6,55.2-58.2",
];

class GooeyNumbersDemo extends StatefulWidget {
  const GooeyNumbersDemo({super.key});
  @override
  State<GooeyNumbersDemo> createState() => _GooeyNumbersDemoState();
}

class _GooeyNumbersDemoState extends State<GooeyNumbersDemo> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _t;

  final _paths = numbers.map(parseSvgPathData).toList();
  late final Rect _referenceBounds;

  int _prevLeft = 0;
  int _left = 1;

  int _prevRight = 0;
  int _right = 2;

  static const _stagger = 1e-2;
  final _rnd = math.Random();

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 999));
    _t = CurvedAnimation(parent: _c, curve: Curves.linearToEaseOut);

    _referenceBounds = _paths.map((p) => p.getBounds()).reduce((a, b) => a.expandToInclude(b));

    _prevLeft = _randomPair();
    _left = _randomPair();
    _prevRight = _randomPair();
    _right = _randomPair();

    _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  int _randomPair() {
    final n = _paths.length;
    var to = _rnd.nextInt(n);
    return to;
  }

  void _shuffle() {
    setState(() {
      final lTo = _randomPair();
      final rTo = _randomPair();
      _prevLeft = _left;
      _left = lTo;
      _prevRight = _right;
      _right = rTo;
    });
    _c.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final fromLeft = _paths[_prevLeft];
    final toLeft = _paths[_left];
    final fromRight = _paths[_prevRight];
    final toRight = _paths[_right];

    return Scaffold(
      backgroundColor: Colors.black,
      bottomSheet: FloatingActionButton.extended(
        onPressed: _shuffle,
        label: const Text('Shuffle'),
        icon: const Icon(Icons.shuffle),
      ),
      body: SafeArea(
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRect(
                child: SizedBox(
                  width: _referenceBounds.width,
                  height: _referenceBounds.height,
                  child: AnimatedBuilder(
                    animation: _t,
                    builder: (context, _) {
                      return CustomPaint(
                        painter: _MorphingCirclesPainter(
                          fromPath: fromLeft,
                          toPath: toLeft,
                          referenceBounds: _referenceBounds,
                          t: _t.value,
                          color: Colors.white,
                          stagger: _stagger,
                          padding: const EdgeInsets.all(8.0),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 24),
              ClipRect(
                child: SizedBox(
                  width: _referenceBounds.width,
                  height: _referenceBounds.height,
                  child: AnimatedBuilder(
                    animation: _t,
                    builder: (context, _) {
                      return CustomPaint(
                        painter: _MorphingCirclesPainter(
                          fromPath: fromRight,
                          toPath: toRight,
                          referenceBounds: _referenceBounds,
                          t: _t.value,
                          color: Colors.white,
                          stagger: _stagger,
                          padding: const EdgeInsets.all(8.0),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MorphingCirclesPainter extends CustomPainter {
  _MorphingCirclesPainter({
    required this.fromPath,
    required this.toPath,
    required this.referenceBounds,
    required this.t,
    this.color = Colors.white,
    this.stagger = 0.025,
    this.padding = EdgeInsets.zero,
  });

  final Path fromPath;
  final Path toPath;
  final Rect referenceBounds;
  final double t;
  final double stagger;
  final Color color;
  final EdgeInsets padding;

  @override
  void paint(Canvas canvas, Size size) {
    final layerRect = Offset.zero & size;

    final innerW = (size.width - padding.horizontal).clamp(0.0, double.infinity);
    final innerH = (size.height - padding.vertical).clamp(0.0, double.infinity);
    final innerSize = Size(innerW, innerH);

    final fitMat = _fitToCenterMatrix(referenceBounds, innerSize);
    final mat = Matrix4.identity()
      ..translate(padding.left, padding.top)
      ..multiply(fitMat);

    final fromT = fromPath.transform(mat.storage);
    final toT = toPath.transform(mat.storage);

    final fromMetrics = fromT.computeMetrics().toList(growable: false);
    final toMetrics = toT.computeMetrics().toList(growable: false);
    if (fromMetrics.isEmpty || toMetrics.isEmpty) return;

    final fromTotal = fromMetrics.fold<double>(0, (s, m) => s + m.length);
    final toTotal = toMetrics.fold<double>(0, (s, m) => s + m.length);
    final maxTotal = math.max(fromTotal, toTotal);

    final minSide = math.max(1.0, math.min(innerSize.width, innerSize.height));
    final circleRadius = minSide * 0.09;
    final targetSpacing = circleRadius * .7;
    final rawCount = maxTotal / targetSpacing;
    final circleCount = math.max(1, rawCount.floor());
    final blurSigma = circleRadius;

    final fromStep = fromTotal / (circleCount + 1);
    final toStep = toTotal / (circleCount + 1);

    final blurPaint = Paint()
      ..imageFilter = ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma, tileMode: TileMode.decal);
    canvas.saveLayer(layerRect, blurPaint);

    final paint = Paint()..color = color;

    for (var i = 0; i < circleCount; i++) {
      final delay = i * stagger;
      final prog = ((t - delay) / (1 - delay)).clamp(0.0, 1.0);

      final offFromTotal = ((i + 1) * fromStep) % fromTotal;
      final offToTotal = ((i + 1) * toStep) % toTotal;

      final tf = _tangentAt(fromMetrics, offFromTotal);
      final tt = _tangentAt(toMetrics, offToTotal);
      if (tf == null || tt == null) continue;

      final x = lerpDouble(tf.position.dx, tt.position.dx, prog)!;
      final y = lerpDouble(tf.position.dy, tt.position.dy, prog)!;

      canvas.drawCircle(Offset(x, y), circleRadius, paint);
    }

    canvas.restore();

    /// I layered colorDodge/colorBurn (not the article’s color-matrix approach),
    /// and the effect looks the same: the blurred edges tighten up and neighboring
    /// blobs visually “threshold” and merge. It’s essentially a contrast boost on RGB
    /// that makes the blur behave like a hard fuse, even though the alpha isn’t actually being quantized.
    canvas.drawRect(
      layerRect,
      Paint()
        ..color = const Color(0xff808080)
        ..style = PaintingStyle.fill
        ..blendMode = BlendMode.colorDodge,
    );
    canvas.drawRect(
      layerRect,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.fill
        ..blendMode = BlendMode.colorBurn,
    );
  }

  Tangent? _tangentAt(List<PathMetric> metrics, double globalOffset) {
    var remaining = globalOffset;
    for (final m in metrics) {
      if (remaining <= m.length) return m.getTangentForOffset(remaining);
      remaining -= m.length;
    }
    final last = metrics.isNotEmpty ? metrics.last : null;
    return last?.getTangentForOffset(last.length);
  }

  @override
  bool shouldRepaint(_MorphingCirclesPainter old) =>
      old.t != t ||
      old.color != color ||
      old.stagger != stagger ||
      old.fromPath != fromPath ||
      old.toPath != toPath ||
      old.referenceBounds != referenceBounds;
}

Matrix4 _fitToCenterMatrix(Rect viewBox, Size canvasSize) {
  final vw = viewBox.width == 0 ? 1.0 : viewBox.width;
  final vh = viewBox.height == 0 ? 1.0 : viewBox.height;

  final scale = math.min(canvasSize.width / vw, canvasSize.height / vh);

  final scaledW = vw * scale;
  final scaledH = vh * scale;

  final tx = (canvasSize.width - scaledW) / 2;
  final ty = (canvasSize.height - scaledH) / 2;

  return Matrix4.identity()
    ..translate(tx, ty)
    ..scale(scale, scale)
    ..translate(-viewBox.left, -viewBox.top);
}
