import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

// Cores do céu (topo, horizonte) em horários-chave; entre eles as cores são interpoladas
const List<(double, Color, Color)> _skyKeys = [
  (0, Color(0xFF0B1026), Color(0xFF1B2447)),
  (5, Color(0xFF0B1026), Color(0xFF2B2F5A)),
  (6.5, Color(0xFF3B4A8C), Color(0xFFF2A07B)),
  (8, Color(0xFF4A90D9), Color(0xFFBFE3FF)),
  (16, Color(0xFF3F86D6), Color(0xFFCDE8FF)),
  (18, Color(0xFF3A3F8F), Color(0xFFF58A5C)),
  (19.5, Color(0xFF141A3D), Color(0xFF3B3466)),
  (24, Color(0xFF0B1026), Color(0xFF1B2447)),
];

(Color, Color) skyColorsAt(double hour) {
  for (int i = 1; i < _skyKeys.length; i++) {
    final (h1, top1, bottom1) = _skyKeys[i];
    if (hour <= h1) {
      final (h0, top0, bottom0) = _skyKeys[i - 1];
      final f = (hour - h0) / (h1 - h0);
      return (Color.lerp(top0, top1, f)!, Color.lerp(bottom0, bottom1, f)!);
    }
  }
  return (_skyKeys.last.$2, _skyKeys.last.$3);
}

// 1 à noite, 0 durante o dia, com transição no amanhecer e no entardecer
double nightAmount(double hour) {
  if (hour < 5 || hour > 20) return 1;
  if (hour < 7) return (7 - hour) / 2;
  if (hour > 18) return (hour - 18) / 2;
  return 0;
}

/// Céu desenhado em código que acompanha a hora do dia (sem imagens nem vídeo).
class SkyBackground extends StatefulWidget {
  const SkyBackground({super.key});

  @override
  State<SkyBackground> createState() => _SkyBackgroundState();
}

class _SkyBackgroundState extends State<SkyBackground> {
  late final Timer _timer;
  final DateTime _start = DateTime.now();

  @override
  void initState() {
    super.initState();
    // ponytail: 20 fps fixo para poupar a TCL; aumentar se o movimento parecer travado
    _timer = Timer.periodic(const Duration(milliseconds: 50), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final seconds = now.difference(_start).inMilliseconds / 1000;
    return RepaintBoundary(
      child: CustomPaint(painter: _SkyPainter(now.hour + now.minute / 60, seconds), size: Size.infinite)
    );
  }
}

class _SkyPainter extends CustomPainter {
  final double hour;
  final double seconds;

  static final List<(double, double, double)> _stars = () {
    final random = Random(42);
    return List.generate(90, (_) => (random.nextDouble(), random.nextDouble() * 0.7, random.nextDouble() * 2 * pi));
  }();

  _SkyPainter(this.hour, this.seconds);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final (top, bottom) = skyColorsAt(hour);
    canvas.drawRect(rect, Paint()
      ..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [top, bottom])
          .createShader(rect));

    final night = nightAmount(hour);
    if (night > 0) {
      _paintStars(canvas, size, night);
      _paintMoon(canvas, size, top, bottom);
    }
    if (night < 1) {
      _paintSun(canvas, size);
      _paintClouds(canvas, size, 1 - night);
    }
  }

  void _paintStars(Canvas canvas, Size size, double night) {
    final paint = Paint();
    for (final (x, y, phase) in _stars) {
      final twinkle = 0.5 + 0.5 * sin(seconds * 1.5 + phase);
      paint.color = Colors.white.withOpacity(night * (0.3 + 0.7 * twinkle));
      canvas.drawCircle(Offset(x * size.width, y * size.height), 1 + phase / 4, paint);
    }
  }

  // Sol e lua percorrem um arco: x vai da esquerda para a direita, y sobe até o meio do percurso
  Offset _arc(Size size, double progress) => Offset(
    size.width * (0.1 + 0.8 * progress),
    size.height * (0.8 - 0.65 * sin(pi * progress)),
  );

  void _paintSun(Canvas canvas, Size size) {
    if (hour < 6 || hour > 19) return;
    final center = _arc(size, (hour - 6) / 13);
    final radius = size.shortestSide * 0.06;
    canvas.drawCircle(center, radius * 3, Paint()
      ..shader = RadialGradient(colors: [const Color(0x66FFE8A3), const Color(0x00FFE8A3)])
          .createShader(Rect.fromCircle(center: center, radius: radius * 3)));
    canvas.drawCircle(center, radius, Paint()..color = const Color(0xFFFFE07A));
  }

  void _paintMoon(Canvas canvas, Size size, Color top, Color bottom) {
    final progress = ((hour - 18.5) % 24) / 12;
    if (progress > 1) return;
    final center = _arc(size, progress);
    final radius = size.shortestSide * 0.045;
    canvas.drawCircle(center, radius, Paint()..color = const Color(0xFFF4F1E1));
    // Recorte com a cor do céu naquela altura para formar a lua crescente
    final sky = Color.lerp(top, bottom, center.dy / size.height)!;
    canvas.drawCircle(center + Offset(radius * 0.45, -radius * 0.2), radius * 0.85, Paint()..color = sky);
  }

  void _paintClouds(Canvas canvas, Size size, double day) {
    final paint = Paint()..color = Colors.white.withOpacity(0.55 * day);
    for (int i = 0; i < 4; i++) {
      final width = size.width * (0.14 + 0.04 * i);
      final travel = size.width + width * 2;
      final x = (i * travel / 4 + seconds * (8 + 3 * i)) % travel - width;
      final y = size.height * (0.12 + 0.11 * i);
      canvas.drawOval(Rect.fromLTWH(x, y, width, width * 0.28), paint);
      canvas.drawOval(Rect.fromLTWH(x + width * 0.2, y - width * 0.12, width * 0.5, width * 0.3), paint);
    }
  }

  @override
  bool shouldRepaint(_SkyPainter old) => old.seconds != seconds || old.hour != hour;
}
