import 'package:flauncher/perfil.dart';
import 'package:flauncher/widgets/sky_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('cores do céu batem com as chaves e interpolam entre elas', () {
    expect(skyColorsAt(0).$1, const Color(0xFF0B1026));
    expect(skyColorsAt(8).$1, const Color(0xFF4A90D9));
    expect(skyColorsAt(24).$1, const Color(0xFF0B1026));
    expect(skyColorsAt(12).$1, Color.lerp(const Color(0xFF4A90D9), const Color(0xFF3F86D6), 0.5));
  });

  test('noite e dia', () {
    expect(nightAmount(2), 1);
    expect(nightAmount(12), 0);
    expect(nightAmount(6), 0.5);
    expect(nightAmount(19), 0.5);
  });

  test('saudação por horário', () {
    expect(saudacao(DateTime(2026, 1, 1, 4)), 'Boa noite, Lara Martins!');
    expect(saudacao(DateTime(2026, 1, 1, 9)), 'Bom dia, Lara Martins!');
    expect(saudacao(DateTime(2026, 1, 1, 15)), 'Boa tarde, Lara Martins!');
    expect(saudacao(DateTime(2026, 1, 1, 21)), 'Boa noite, Lara Martins!');
  });
}
