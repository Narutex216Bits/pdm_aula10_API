import 'package:flutter/material.dart';
import '../models/noticia_model.dart';
import '../services/noticia_service.dart';

class DetalheNoticiaScreen extends StatefulWidget {
  final NoticiaModel noticia;
  final bool inicialmenteFavorita;

  const DetalheNoticiaScreen({
    super.key,
    required this.noticia,
    this.inicialmenteFavorita = false,
  });

  @override
  State<DetalheNoticiaScreen> createState() => _DetalheNoticiaScreenState();
}

class _DetalheNoticiaScreenState extends State<DetalheNoticiaScreen> {
  final _service = NoticiaService();
  late Future<List<ComentarioModel>> _futureComentarios;
  late bool _favorita;

  @override
  void initState() {
    super.initState();
    _favorita = widget.inicialmenteFavorita;
    _futureComentarios = _service.buscarComentarios(widget.noticia.id);
  }

  @override
  Widget build(BuildContext context) {
    final noticia = widget.noticia;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Notícia'),
        actions: [
          IconButton(
            tooltip: _favorita ? 'Remover dos favoritos' : 'Favoritar notícia',
            icon: Icon(
              _favorita ? Icons.favorite : Icons.favorite_border,
              color: _favorita ? Colors.red : null,
            ),
            onPressed: () {
              setState(() => _favorita = !_favorita);
              Navigator.pop(context, _favorita);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: noticia.id,
              child: Image.network(
                noticia.urlImagem,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image, size: 40),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Chip(
                    avatar: const Icon(Icons.person, size: 16),
                    label: Text(noticia.autor),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    noticia.titulo,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const Divider(height: 24),
                  Text(
                    noticia.conteudoCompleto,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(height: 1.5),
                  ),
                  const Divider(height: 32),
                  Text(
                    'Comentários',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  FutureBuilder<List<ComentarioModel>>(
                    future: _futureComentarios,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Text('Erro nos comentários: ${snapshot.error}');
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text('Nenhum comentário encontrado.');
                      }

                      final comentarios = snapshot.data!;
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: comentarios.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final c = comentarios[index];
                          return Card(
                            elevation: 1,
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Text(c.nome[0].toUpperCase()),
                              ),
                              title: Text(
                                c.nome,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(c.corpo),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}