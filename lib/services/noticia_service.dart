import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/noticia_model.dart';

class NoticiaService {
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';

  Future<List<NoticiaModel>> buscarNoticias() async {
    final response = await http.get(Uri.parse('$_baseUrl/posts'));

    if (response.statusCode == 200) {
      final List<dynamic> listaJson = jsonDecode(response.body);
      return listaJson.map((item) => NoticiaModel.fromJson(item)).toList();
    } else {
      throw Exception('Erro ao carregar notícias (HTTP ${response.statusCode})');
    }
  }

  Future<List<ComentarioModel>> buscarComentarios(int postId) async {
    final response =
        await http.get(Uri.parse('$_baseUrl/posts/$postId/comments'));

    if (response.statusCode == 200) {
      final List<dynamic> listaJson = jsonDecode(response.body);
      return listaJson.map((item) => ComentarioModel.fromJson(item)).toList();
    } else {
      throw Exception('Erro ao carregar comentários');
    }
  }
}