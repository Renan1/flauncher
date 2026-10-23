import 'package:flauncher/perfil.dart';
import 'package:flauncher/widgets/sky_background.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('foto do céu por período', () {
    expect(skyAssetFor(4), 'assets/ceu/noite.jpg');
    expect(skyAssetFor(5), 'assets/ceu/manha.jpg');
    expect(skyAssetFor(12), 'assets/ceu/tarde.jpg');
    expect(skyAssetFor(17), 'assets/ceu/por_do_sol.jpg');
    expect(skyAssetFor(19), 'assets/ceu/noite.jpg');
  });

  test('saudação por horário', () {
    expect(saudacao(DateTime(2026, 1, 1, 4)), 'Boa noite, Lara Martins!');
    expect(saudacao(DateTime(2026, 1, 1, 9)), 'Bom dia, Lara Martins!');
    expect(saudacao(DateTime(2026, 1, 1, 15)), 'Boa tarde, Lara Martins!');
    expect(saudacao(DateTime(2026, 1, 1, 21)), 'Boa noite, Lara Martins!');
  });
}
