import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import '../appbar.dart';
// A importação de noticias.dart foi removida

// A classe Noticia foi movida para este arquivo
class Noticia {
  final String title;
  final String description;
  final String link;
  final String imageUrl;

  Noticia({
    required this.title,
    required this.description,
    required this.link,
    required this.imageUrl,
  });

  factory Noticia.fromJson(Map<String, dynamic> json) {
    return Noticia(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      link: json['link'] ?? '',
      // A imagem não existe no JSON do back-end, então definimos como vazia.
      imageUrl: '', 
    );
  }
}

class NoticiasScreen extends StatefulWidget {
  const NoticiasScreen({super.key});

  @override
  NoticiasScreenState createState() => NoticiasScreenState();
}

class NoticiasScreenState extends State<NoticiasScreen> {
  List<Noticia> noticias = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNoticias();
  }

  Future<void> fetchNoticias() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:8000/rss/')); // Corrigido para incluir a barra final

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final List<Noticia> listaNoticias = jsonData
            .map((item) => Noticia.fromJson(item as Map<String, dynamic>))
            .toList();

        setState(() {
          noticias = listaNoticias;
          isLoading = false;
        });
      } else {
        throw Exception('Erro ao carregar notícias');
      }
    } catch (e) {
      debugPrint('Erro: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildNoticiaCard(Noticia noticia) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: InkWell(
        onTap: () async {
          final Uri url = Uri.parse(noticia.link);
          if (await url_launcher.canLaunchUrl(url)) {
            await url_launcher.launchUrl(url, mode: url_launcher.LaunchMode.externalApplication);
          } else {
            debugPrint('Não foi possível abrir o link: ${noticia.link}');
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              noticia.imageUrl.isNotEmpty
                  ? Image.network(
                      noticia.imageUrl,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/placeholder.png',
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        );
                      },
                    )
                  : Image.asset(
                      'assets/placeholder.png',
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
              const SizedBox(height: 8),
              Text(
                noticia.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 6),
              Html(
                data: noticia.description,
                style: {
                  "body": Style(
                    margin: Margins.zero,
                    padding: HtmlPaddings.zero,
                    fontSize: FontSize(14),
                  ),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        onRefresh: fetchNoticias,
        isLoading: isLoading,
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/CheckMen_Logo_Certa.png',
                    height: 60,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Menu Principal',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('Saúde Masculina'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.article),
              title: const Text('Notícias'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
              ListTile(
              leading: const Icon(Icons.alarm),
              title: const Text('Lembretes'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
              ListTile(
              leading: const Icon(Icons.mail),
              title: const Text('Contato'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
              ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configurações'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : noticias.isEmpty
              ? const Center(child: Text('Nenhuma notícia encontrada.'))
              : ListView.builder(
                  itemCount: noticias.length,
                  itemBuilder: (context, index) {
                    return _buildNoticiaCard(noticias[index]);
                  },
                ),
    );
  }
}