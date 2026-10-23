// Perfil da TV: troque estes valores para gerar o launcher de outra TV.
const String nome = 'Lara Martins';
const String subtitulo = 'O que vamos assistir hoje?';

// Apps fixos no topo, nesta ordem. Pacotes não instalados são ignorados.
const List<String> appsFavoritos = [
  'com.google.android.youtube.tv',
  'com.netflix.ninja',
  'com.disney.disneyplus',
];

String saudacao(DateTime agora) {
  final hora = agora.hour;
  final periodo = hora >= 5 && hora < 12 ? 'Bom dia' : hora >= 12 && hora < 18 ? 'Boa tarde' : 'Boa noite';
  return '$periodo, $nome!';
}
