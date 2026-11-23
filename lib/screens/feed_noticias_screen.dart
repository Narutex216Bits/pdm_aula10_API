import 'package:flutter/material.dart';
import '../models/noticia_model.dart';
import '../services/noticia_service.dart';

class FeedNoticiasScreen extends StatefulWidget {
  const FeedNoticiasScreen({super.key});

  @override
  State<FeedNoticiasScreen> createState() => _FeedNoticiasScreenState();
}

class _FeedNoticiasScreenState extends State<FeedNoticiasScreen> {
  final _service = NoticiaService();
  final _buscaController = TextEditingController();

  List<NoticiaModel> _todasNoticias = [];
  List<NoticiaModel> _noticiasFiltradas = [];
  bool _carregando = true;
  String? _erro;
  bool _simularErro = false;

  @override
  void initState() {
    super.initState();
    _carregarFeed();
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  Future<void> _carregarFeed() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final lista = await _service.buscarNoticias(simularErro: _simularErro);
      setState(() {
        _todasNoticias = lista;
        _filtrarNoticias(_buscaController.text);
      });
    } catch (e) {
      setState(() {
        _erro = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _carregando = false);
      }
    }
  }

  void _filtrarNoticias(String termo) {
    setState(() {
      if (termo.trim().isEmpty) {
        _noticiasFiltradas = List.from(_todasNoticias);
      } else {
        _noticiasFiltradas = _todasNoticias
            .where((n) =>
                n.titulo.toLowerCase().contains(termo.trim().toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed de Notícias'),
        actions: [
          IconButton(
            tooltip: _simularErro
                ? 'Desativar simulação de erro'
                : 'Simular erro de API',
            icon: Icon(
              _simularErro ? Icons.wifi_off : Icons.bug_report_outlined,
              color: _simularErro ? Colors.red : null,
            ),
            onPressed: () {
              setState(() => _simularErro = !_simularErro);
              _carregarFeed();
            },
          ),
          IconButton(
            tooltip: 'Recarregar',
            icon: const Icon(Icons.refresh),
            onPressed: _carregarFeed,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              controller: _buscaController,
              onChanged: _filtrarNoticias,
              decoration: InputDecoration(
                hintText: 'Filtrar notícias por título...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _buscaController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _buscaController.clear();
                          _filtrarNoticias('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(child: _buildConteudo()),
        ],
      ),
    );
  }

  Widget _buildConteudo() {
    if (_carregando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_erro != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 56, color: Colors.red),
              const SizedBox(height: 12),
              Text(
                _erro!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _carregarFeed,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (_noticiasFiltradas.isEmpty) {
      return const Center(
        child: Text('Nenhuma notícia encontrada.'),
      );
    }

    return ListView.builder(
      itemCount: _noticiasFiltradas.length,
      padding: const EdgeInsets.all(12),
      itemBuilder: (context, index) {
        final noticia = _noticiasFiltradas[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(child: Text(noticia.id.toString())),
            title: Text(
              noticia.titulo,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              noticia.resumo,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => Scaffold(
                    appBar: AppBar(title: Text('Notícia #${noticia.id}')),
                    body: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            noticia.titulo,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          Text('Autor ID: ${noticia.autorId}'),
                          const Divider(height: 24),
                          Text(
                            noticia.resumo,
                            style: const TextStyle(fontSize: 16, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}