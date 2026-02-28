import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:voyz/data/trip_data.dart';
import 'package:voyz/models/destination_detail.dart';
import 'package:voyz/models/destination_suggestion.dart';
import 'package:voyz/models/itinerary_plan.dart';

import 'package:voyz/services/cache_service.dart';
import 'package:voyz/services/image_service.dart';

/// Central service for interacting with the Gemini Flash 3 API.
///
/// Uses Vietnamese prompts and returns strongly-typed Dart models.
/// All methods check Hive cache first; only calls the API on cache miss.
class GeminiService {
  GeminiService._();
  static final GeminiService instance = GeminiService._();

  final CacheService _cache = CacheService.instance;

  GenerativeModel? _model;

  GenerativeModel get _gemini {
    if (_model != null) return _model!;
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty || apiKey == 'YOUR_API_KEY_HERE') {
      throw Exception(
        'GEMINI_API_KEY is not set. Please add your key to .env file.',
      );
    }
    _model = GenerativeModel(
      model: 'gemini-3-flash-preview',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        temperature: 0.7,
      ),
    );
    return _model!;
  }

  // ── Explore (independent, no TripData needed) ─────────────────────────

  /// Get trending travel destinations for free exploration.
  /// Does NOT require any user input — perfect for the Explore tab.
  ///
  /// [limit] number of destinations to return.
  /// [forceRefresh] if true, bypasses the cache.
  Future<List<DestinationSuggestion>> getExploreTrending({
    int limit = 10,
    bool forceRefresh = false,
  }) async {
    final cacheKey = _cache.buildKey('explore_trending', {'limit': limit});

    if (!forceRefresh) {
      final cached = _cache.get(cacheKey);
      if (cached != null) {
        return _parseSuggestions(cached);
      }
    }

    final prompt =
        '''
Bạn là chuyên gia du lịch AI. Hãy gợi ý $limit điểm đến du lịch đang thịnh hành nhất hiện nay, bao gồm cả trong nước Việt Nam và quốc tế.

Ưu tiên các điểm đến:
- Đa dạng vùng miền (biển, núi, thành phố, thiên nhiên hoang sơ)
- Phù hợp với mùa du lịch hiện tại
- Có cả địa điểm bình dân và cao cấp
- Mix giữa Việt Nam và quốc tế

Trả về JSON array với đúng $limit phần tử, mỗi phần tử:
{
  "name": "Tên địa điểm, Quốc gia",
  "matchPercent": 85,
  "rating": 4.5,
  "reviewCount": 1200,
  "price": "~4.2M VNĐ",
  "aiInsight": "Lý do nên đến ngay thời điểm này (1-2 câu)",
  "isTopMatch": false
}

Quy tắc:
- matchPercent thể hiện mức độ trending (60-99)
- rating từ 1.0-5.0
- reviewCount là ước tính số đánh giá
- price là chi phí ước tính cho 1 người/chuyến
- aiInsight nên đề cập lý do trending (mùa lễ hội, thời tiết đẹp, ...)
- Phần tử đầu tiên có isTopMatch = true
- CHỈ trả về JSON array, KHÔNG thêm markdown hay text khác
''';

    final response = await _gemini.generateContent([Content.text(prompt)]);
    final text = response.text;
    if (text == null || text.isEmpty) return [];

    await _cache.put(cacheKey, text);
    return _parseSuggestions(text);
  }

  // ── Suggestions ──────────────────────────────────────────────────────

  /// Get AI travel suggestions based on user's trip preferences.
  ///
  /// [trip] contains destination, budget, interests, dates, etc.
  /// [limit] controls the number of suggestions returned (default 10).
  /// [forceRefresh] if true, bypasses the cache and calls the API.
  Future<List<DestinationSuggestion>> getSuggestions(
    TripData trip, {
    int limit = 10,
    bool forceRefresh = false,
  }) async {
    // Build cache key from the inputs that actually affect the result
    final cacheKey = _cache.buildKey('suggestions', {
      'destination': trip.destination,
      'budget': trip.budget,
      'currency': trip.currency,
      'interests': trip.selectedInterests,
      'limit': limit,
    });

    // Check cache
    if (!forceRefresh) {
      final cached = _cache.get(cacheKey);
      if (cached != null) {
        return _parseSuggestions(cached);
      }
    }

    // Cache miss — call Gemini API
    final prompt = _buildSuggestionsPrompt(trip, limit);
    final response = await _gemini.generateContent([Content.text(prompt)]);
    final text = response.text;
    if (text == null || text.isEmpty) return [];

    // Save to cache
    await _cache.put(cacheKey, text);

    return _parseSuggestions(text);
  }

  /// Parse raw JSON text into a list of DestinationSuggestion with images.
  Future<List<DestinationSuggestion>> _parseSuggestions(String text) async {
    final List<dynamic> jsonList = jsonDecode(text) as List<dynamic>;

    // Batch fetch image URLs
    final names = jsonList
        .map((e) => (e as Map<String, dynamic>)['name'] as String)
        .toList();
    final imageUrls = await ImageService.instance.getImageUrls(names);

    final suggestions = jsonList.map((e) {
      final map = e as Map<String, dynamic>;
      final name = map['name'] as String? ?? '';
      return DestinationSuggestion.fromJson(map, imageUrls[name] ?? '');
    }).toList();

    // Mark the first item as top match if none is flagged.
    if (suggestions.isNotEmpty && !suggestions.any((s) => s.isTopMatch)) {
      final top = suggestions.first;
      suggestions[0] = DestinationSuggestion(
        name: top.name,
        imageUrl: top.imageUrl,
        matchPercent: top.matchPercent,
        rating: top.rating,
        reviewCount: top.reviewCount,
        price: top.price,
        aiInsight: top.aiInsight,
        isTopMatch: true,
      );
    }

    return suggestions;
  }

  String _buildSuggestionsPrompt(TripData trip, int limit) {
    final interests = trip.selectedInterests.isNotEmpty
        ? trip.selectedInterests.join(', ')
        : 'du lịch tổng hợp';

    final destination = trip.destination.isNotEmpty
        ? trip.destination
        : 'Việt Nam';

    final budget = trip.budget.isNotEmpty
        ? '${trip.budget} ${trip.currency}'
        : 'không giới hạn';

    final dateInfo = trip.departDate != null && trip.returnDate != null
        ? 'từ ${_formatDate(trip.departDate!)} đến ${_formatDate(trip.returnDate!)}'
        : 'linh hoạt';

    final additionalNotes = trip.additionalNotes.isNotEmpty
        ? '\nYêu cầu thêm: ${trip.additionalNotes}'
        : '';

    final aiPromptExtra = trip.aiPrompt.isNotEmpty
        ? '\nMô tả chuyến đi: ${trip.aiPrompt}'
        : '';

    return '''
Bạn là chuyên gia du lịch AI. Hãy gợi ý $limit điểm đến du lịch phù hợp nhất.

Thông tin người dùng:
- Điểm đến mong muốn: $destination
- Ngân sách: $budget
- Sở thích: $interests
- Thời gian: $dateInfo
- Số người: ${trip.participants.isNotEmpty ? trip.participants : 'không rõ'}
- Độ tuổi: ${trip.ageRange.isNotEmpty ? trip.ageRange : 'không rõ'}$additionalNotes$aiPromptExtra

Trả về JSON array với đúng $limit phần tử, mỗi phần tử có cấu trúc:
{
  "name": "Tên địa điểm, Quốc gia",
  "matchPercent": 85,
  "rating": 4.5,
  "reviewCount": 120,
  "price": "~4.2M VNĐ",
  "aiInsight": "Nhận xét ngắn gọn về sự phù hợp với người dùng",
  "isTopMatch": false
}

Quy tắc:
- matchPercent từ 60-99, sắp xếp giảm dần theo matchPercent
- rating từ 1.0-5.0
- reviewCount là số lượng đánh giá ước tính
- price phải phù hợp với ngân sách người dùng, ghi bằng ${trip.currency}
- aiInsight phải cụ thể, liên quan đến sở thích và ngân sách người dùng
- Chỉ có 1 phần tử đầu tiên có isTopMatch = true
- CHỈ trả về JSON array, KHÔNG thêm markdown hay text khác
''';
  }

  // ── Destination Detail ────────────────────────────────────────────────

  /// Get detailed information about a specific destination.
  ///
  /// [forceRefresh] if true, bypasses the cache.
  Future<DestinationDetail> getDestinationDetail(
    String destinationName,
    TripData trip, {
    bool forceRefresh = false,
  }) async {
    final cacheKey = _cache.buildKey('detail', {'name': destinationName});

    // Check cache
    if (!forceRefresh) {
      final cached = _cache.get(cacheKey);
      if (cached != null) {
        return _parseDetail(cached, destinationName);
      }
    }

    // Cache miss — call Gemini API
    final prompt = _buildDetailPrompt(destinationName, trip);
    final response = await _gemini.generateContent([Content.text(prompt)]);
    final text = response.text;
    if (text == null || text.isEmpty) {
      throw Exception('Không nhận được phản hồi từ AI.');
    }

    // Save to cache
    await _cache.put(cacheKey, text);

    return _parseDetail(text, destinationName);
  }

  /// Parse raw JSON text into a DestinationDetail with image.
  Future<DestinationDetail> _parseDetail(
    String text,
    String destinationName,
  ) async {
    final Map<String, dynamic> json = jsonDecode(text) as Map<String, dynamic>;
    final name = json['name'] as String? ?? destinationName;
    final imageUrl = await ImageService.instance.getImageUrl(name);
    return DestinationDetail.fromJson(json, imageUrl);
  }

  String _buildDetailPrompt(String destinationName, TripData trip) {
    final dateInfo = trip.departDate != null && trip.returnDate != null
        ? '${_formatDateShort(trip.departDate!)} - ${_formatDateShort(trip.returnDate!)}'
        : 'Mar 15 - Mar 18';

    final budget = trip.budget.isNotEmpty
        ? '${trip.budget} ${trip.currency}'
        : '5M VNĐ';

    return '''
Bạn là chuyên gia du lịch AI. Hãy cung cấp thông tin chi tiết về điểm đến "$destinationName".

Ngân sách người dùng: $budget
Thời gian: $dateInfo

Trả về JSON object với cấu trúc:
{
  "name": "$destinationName",
  "location": "Tỉnh/Vùng",
  "tags": ["🌿 Wellness", "🏖️ Beach", "🤿 Diving", "🌅 Scenic"],
  "weather": "Sunny, 32°C",
  "dateRange": "$dateInfo",
  "totalBudget": "~4.2M VNĐ",
  "budgetBreakdown": [
    {"label": "Transport", "amount": "1.7M", "fraction": 0.40, "icon": "flight"},
    {"label": "Stay", "amount": "1.2M", "fraction": 0.30, "icon": "hotel"},
    {"label": "Food", "amount": "0.8M", "fraction": 0.20, "icon": "restaurant"},
    {"label": "Activities", "amount": "0.5M", "fraction": 0.10, "icon": "kayaking"}
  ]
}

Quy tắc:
- tags: 4 thẻ phù hợp nhất với điểm đến, có emoji phía trước
- weather: thời tiết thực tế cho thời gian du lịch
- budgetBreakdown: chia ngân sách thành 4 loại, tổng fraction = 1.0
- icon chỉ dùng: flight, hotel, restaurant, kayaking
- Số liệu phải phù hợp với ngân sách $budget
- CHỈ trả về JSON object, KHÔNG thêm markdown hay text khác
''';
  }

  // ── Itinerary Plan ────────────────────────────────────────────────────

  /// Generate a day-by-day itinerary plan for a destination.
  ///
  /// [numDays] number of days in the itinerary.
  /// [limit] max activities per day (default 4).
  /// [forceRefresh] if true, bypasses the cache.
  Future<ItineraryPlan> getItineraryPlan(
    String destinationName,
    int numDays,
    TripData trip, {
    int limit = 4,
    bool forceRefresh = false,
  }) async {
    final cacheKey = _cache.buildKey('itinerary', {
      'name': destinationName,
      'numDays': numDays,
    });

    // Check cache
    if (!forceRefresh) {
      final cached = _cache.get(cacheKey);
      if (cached != null) {
        final Map<String, dynamic> json =
            jsonDecode(cached) as Map<String, dynamic>;
        return ItineraryPlan.fromJson(json);
      }
    }

    // Cache miss — call Gemini API
    final prompt = _buildItineraryPrompt(destinationName, numDays, trip, limit);
    final response = await _gemini.generateContent([Content.text(prompt)]);
    final text = response.text;
    if (text == null || text.isEmpty) {
      throw Exception('Không nhận được phản hồi từ AI.');
    }

    // Save to cache
    await _cache.put(cacheKey, text);

    final Map<String, dynamic> json = jsonDecode(text) as Map<String, dynamic>;
    return ItineraryPlan.fromJson(json);
  }

  String _buildItineraryPrompt(
    String destinationName,
    int numDays,
    TripData trip,
    int limit,
  ) {
    final dateInfo = trip.departDate != null && trip.returnDate != null
        ? '${_formatDateShort(trip.departDate!)} - ${_formatDateShort(trip.returnDate!)}'
        : 'MAR 15 - MAR 18';

    return '''
Bạn là chuyên gia du lịch AI. Hãy lên kế hoạch du lịch chi tiết $numDays ngày tại "$destinationName".

Thời gian: $dateInfo

Trả về JSON object với cấu trúc:
{
  "destinationName": "$destinationName",
  "dateRange": "$dateInfo",
  "days": [
    {
      "dayNumber": 1,
      "title": "Day 1: Arrival & Coastal Relaxation",
      "subtitle": "Experience the serene beauty of the islands.",
      "items": [
        {
          "time": "09:00 AM",
          "title": "Arrival at Airport",
          "description": "Mô tả ngắn gọn về hoạt động",
          "icon": "flight_land"
        }
      ]
    }
  ],
  "proTip": "Mẹo hữu ích cho chuyến đi"
}

Quy tắc:
- Mỗi ngày có tối đa $limit hoạt động
- Tổng cộng $numDays ngày
- title cho mỗi ngày: "Day X: Tiêu đề ngắn gọn" (tiếng Anh)
- subtitle: mô tả ngắn bằng tiếng Anh
- items.time: định dạng "HH:MM AM/PM"
- items.icon chỉ dùng: flight_land, hotel, restaurant, beach_access
- items.description: viết bằng tiếng Anh, 1-2 câu
- proTip: mẹo thực tế bằng tiếng Anh
- CHỈ trả về JSON object, KHÔNG thêm markdown hay text khác
''';
  }

  // ── Helpers ───────────────────────────────────────────────────────────

  String _formatDate(DateTime date) {
    const months = [
      'Tháng 1',
      'Tháng 2',
      'Tháng 3',
      'Tháng 4',
      'Tháng 5',
      'Tháng 6',
      'Tháng 7',
      'Tháng 8',
      'Tháng 9',
      'Tháng 10',
      'Tháng 11',
      'Tháng 12',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatDateShort(DateTime date) {
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }
}
