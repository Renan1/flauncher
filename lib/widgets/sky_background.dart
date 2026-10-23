import 'dart:async';

import 'package:flutter/material.dart';

// Foto do céu de acordo com o período do dia
String skyAssetFor(int hour) {
  if (hour >= 5 && hour < 12) return 'assets/ceu/manha.jpg';
  if (hour >= 12 && hour < 17) return 'assets/ceu/tarde.jpg';
  if (hour >= 17 && hour < 19) return 'assets/ceu/por_do_sol.jpg';
  return 'assets/ceu/noite.jpg';
}

/// Fundo com foto real do céu: troca com dissolve quando muda o período
/// e tem um zoom lento contínuo (efeito Ken Burns) para não ficar estático.
class SkyBackground extends StatefulWidget {
  const SkyBackground({super.key});

  @override
  State<SkyBackground> createState() => _SkyBackgroundState();
}

class _SkyBackgroundState extends State<SkyBackground> with SingleTickerProviderStateMixin {
  late final AnimationController _zoom =
      AnimationController(vsync: this, duration: const Duration(seconds: 40))..repeat(reverse: true);
  late final Timer _clock;
  String _asset = skyAssetFor(DateTime.now().hour);

  @override
  void initState() {
    super.initState();
    _clock = Timer.periodic(const Duration(minutes: 1), (_) {
      final asset = skyAssetFor(DateTime.now().hour);
      if (asset != _asset) setState(() => _asset = asset);
    });
  }

  @override
  void dispose() {
    _clock.cancel();
    _zoom.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: Stack(
      fit: StackFit.expand,
      children: [
        AnimatedSwitcher(
          duration: const Duration(seconds: 3),
          child: AnimatedBuilder(
            key: ValueKey(_asset),
            animation: _zoom,
            builder: (_, child) => Transform.scale(
              scale: 1 + 0.08 * Curves.easeInOut.transform(_zoom.value),
              child: child
            ),
            child: Image.asset(_asset, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
          ),
        ),
        // Escurece o canto da saudação e a base para o texto e os cards se destacarem
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0x99000000), Color(0x22000000), Color(0x66000000)],
            ),
          ),
        ),
      ],
    ),
  );
}
