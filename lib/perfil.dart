// Perfis por TV. O perfil é escolhido na compilação: --dart-define=PERFIL=varanda
// favoritos: apps fixos no topo, nesta ordem. Pacotes não instalados são ignorados.
const Map<String, ({String nome, List<String> favoritos})> _perfis = {
  'lara': (
    nome: 'Lara Martins',
    favoritos: ['com.google.android.youtube.tv', 'com.netflix.ninja', 'com.disney.disneyplus'],
  ),
  'varanda': (
    nome: 'família Martins',
    favoritos: [],
  ),
};

const String _perfilAtual = String.fromEnvironment('PERFIL', defaultValue: 'lara');

final String nome = _perfis[_perfilAtual]!.nome;
final List<String> appsFavoritos = _perfis[_perfilAtual]!.favoritos;
const String subtitulo = 'O que vamos assistir hoje?';

String saudacao(DateTime agora) {
  final hora = agora.hour;
  final periodo = hora >= 5 && hora < 12 ? 'Bom dia' : hora >= 12 && hora < 18 ? 'Boa tarde' : 'Boa noite';
  return '$periodo, $nome!';
}
