class NoticiaModel {
  final int id;
  final String titulo;
  final String resumo;
  final String conteudoCompleto;
  final String autor;
  final String urlImagem;

  const NoticiaModel({
    required this.id,
    required this.titulo,
    required this.resumo,
    required this.conteudoCompleto,
    required this.autor,
    required this.urlImagem,
  });

  factory NoticiaModel.fromJson(Map<String, dynamic> json) {
    final int idNoticia = json['id'] ?? 0;
    final String corpo =
        (json['body'] as String? ?? 'Sem conteúdo disponível.').replaceAll('\n', ' ');
    final String resumoSeguro =
        corpo.length > 50 ? '${corpo.substring(0, 50)}...' : corpo;

    return NoticiaModel(
      id: idNoticia,
      titulo: json['title'] ?? 'Sem título',
      resumo: resumoSeguro,
      conteudoCompleto: json['body'] ?? 'Sem conteúdo disponível.',
      autor: 'Autor ID ${json['userId'] ?? '1'}',
      urlImagem: 'https://picsum.photos/seed/noticia_$idNoticia/600/300',
    );
  }
}

class ComentarioModel {
  final int id;
  final String nome;
  final String email;
  final String corpo;

  const ComentarioModel({
    required this.id,
    required this.nome,
    required this.email,
    required this.corpo,
  });

  factory ComentarioModel.fromJson(Map<String, dynamic> json) {
    return ComentarioModel(
      id: json['id'] ?? 0,
      nome: json['name'] ?? 'Anônimo',
      email: json['email'] ?? '',
      corpo: json['body'] ?? '',
    );
  }
}