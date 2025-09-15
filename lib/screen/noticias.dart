// noticias.dart
// noticias.dart
class Noticia {
  final String title;
  final String description;
  final String link;
  final String imageUrl; // O back-end não tem imagem, então a URL será vazia

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
      imageUrl: '', 
    );
  }
}