import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service to fetch real destination images — no API keys required.
///
/// Uses Wikipedia (EN + VI) and Wikimedia Commons with carefully tuned
/// search queries to return travel-relevant, high-quality photos.
class ImageService {
  ImageService._();
  static final ImageService instance = ImageService._();

  final Map<String, String> _cache = {};

  Future<String> getImageUrl(String destinationName) async {
    if (_cache.containsKey(destinationName)) {
      return _cache[destinationName]!;
    }

    final placeName = destinationName.split(',').first.trim();

    String? url;

    // 1. English Wikipedia — most reliable for popular destinations
    url = await _fetchWikipediaImage(placeName, 'en');

    // 2. Vietnamese Wikipedia — better for local Vietnamese destinations
    url ??= await _fetchWikipediaImage(placeName, 'vi');

    // 3. Wikimedia Commons — targeted travel/landscape search
    url ??= await _fetchCommonsImage(placeName);

    // 4. Wikimedia Commons — broader search with just the name
    url ??= await _fetchCommonsImageSimple(placeName);

    // 5. Fallback placeholder
    url ??=
        'https://placehold.co/800x600/1a365d/e2e8f0?text=${Uri.encodeComponent(placeName)}&font=roboto';

    _cache[destinationName] = url;
    return url;
  }

  Future<Map<String, String>> getImageUrls(List<String> names) async {
    final results = <String, String>{};
    for (final name in names) {
      results[name] = await getImageUrl(name);
    }
    return results;
  }

  // ── Wikipedia ──────────────────────────────────────────────────────────

  /// Fetch the main article image from Wikipedia.
  /// Wikipedia articles about tourist destinations almost always have a
  /// high-quality representative photo as their main image.
  Future<String?> _fetchWikipediaImage(String query, String lang) async {
    try {
      // Use opensearch to find the best matching article title first
      final searchUri = Uri.parse(
        'https://$lang.wikipedia.org/w/api.php'
        '?action=opensearch'
        '&search=${Uri.encodeComponent(query)}'
        '&limit=1'
        '&format=json'
        '&origin=*',
      );

      final searchResponse = await http
          .get(searchUri)
          .timeout(const Duration(seconds: 5));

      String articleTitle = query;
      if (searchResponse.statusCode == 200) {
        final searchJson = jsonDecode(searchResponse.body) as List<dynamic>;
        final titles = searchJson[1] as List<dynamic>;
        if (titles.isNotEmpty) {
          articleTitle = titles.first as String;
        }
      }

      // Now fetch the article's main image using the resolved title
      final uri = Uri.parse(
        'https://$lang.wikipedia.org/w/api.php'
        '?action=query'
        '&titles=${Uri.encodeComponent(articleTitle)}'
        '&prop=pageimages'
        '&format=json'
        '&formatversion=2'
        '&pithumbsize=800'
        '&origin=*',
      );

      final response = await http.get(uri).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final pages = json['query']?['pages'] as List<dynamic>?;
        if (pages != null && pages.isNotEmpty) {
          final page = pages.first as Map<String, dynamic>;
          final thumbnail = page['thumbnail'] as Map<String, dynamic>?;
          if (thumbnail != null) {
            return thumbnail['source'] as String?;
          }
        }
      }
    } catch (_) {}
    return null;
  }

  // ── Wikimedia Commons ──────────────────────────────────────────────────

  /// Targeted Commons search — prioritizes travel photos by using
  /// specific keywords to exclude maps, flags, logos, and diagrams.
  Future<String?> _fetchCommonsImage(String placeName) async {
    // Build a very specific search query focused on travel photos
    final searchTerms =
        '"$placeName" (panorama OR landscape OR aerial OR beach OR temple '
        'OR cityscape OR skyline OR harbor OR mountain OR bay OR island) '
        '-map -flag -logo -coat -seal -diagram -icon -svg';
    return _queryCommons(searchTerms);
  }

  /// Simple fallback Commons search using just the place name.
  Future<String?> _fetchCommonsImageSimple(String placeName) async {
    return _queryCommons(placeName);
  }

  /// Execute the actual Commons API call.
  Future<String?> _queryCommons(String searchTerms) async {
    try {
      final uri = Uri.parse(
        'https://commons.wikimedia.org/w/api.php'
        '?action=query'
        '&generator=search'
        '&gsrnamespace=6'
        '&gsrsearch=${Uri.encodeComponent(searchTerms)}'
        '&gsrlimit=5'
        '&prop=imageinfo'
        '&iiprop=url|extmetadata'
        '&iiurlwidth=800'
        '&format=json'
        '&formatversion=2'
        '&origin=*',
      );

      final response = await http.get(uri).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final pages = json['query']?['pages'] as List<dynamic>?;
        if (pages != null && pages.isNotEmpty) {
          // Filter: prefer JPEG/PNG images (skip SVG, PDF, OGG, etc.)
          for (final page in pages) {
            final title = (page['title'] as String?) ?? '';
            if (_isPhotoFile(title)) {
              final imageInfo =
                  (page['imageinfo'] as List<dynamic>?)?.firstOrNull
                      as Map<String, dynamic>?;
              if (imageInfo != null) {
                return (imageInfo['thumburl'] as String?) ??
                    (imageInfo['url'] as String?);
              }
            }
          }
        }
      }
    } catch (_) {}
    return null;
  }

  /// Check if the file is likely a photo (not SVG, PDF, or audio).
  bool _isPhotoFile(String title) {
    final lower = title.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp');
  }
}
