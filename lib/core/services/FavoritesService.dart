import 'package:hive_flutter/hive_flutter.dart';

class FavoritesService {
  static const _favBox = 'favorites';
  static const _continueBox = 'continue_watching';

  static late Box _fav;
  static late Box _cont;

  static Future<void> init() async {
    _fav  = await Hive.openBox(_favBox);
    _cont = await Hive.openBox(_continueBox);
  }

  // ── Favorites ──────────────────────────────────────────────────────────────

  static Future<void> addFavorite(Map<String, dynamic> item) async {
    final id = item['stream_id']?.toString() ?? '';
    if (id.isEmpty) return;
    await _fav.put(id, item);
  }

  static Future<void> removeFavorite(String streamId) async {
    await _fav.delete(streamId);
  }

  static bool isFavorite(String streamId) {
    return _fav.containsKey(streamId);
  }

  static List<Map> getFavorites() {
    return _fav.values.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  // ── Continue Watching ──────────────────────────────────────────────────────

  static Future<void> saveProgress({
    required String streamId,
    required String name,
    required String posterUrl,
    required String streamUrl,
    required int positionMs,
    required int durationMs,
    required String type, // 'movie' ya 'series'
  }) async {
    await _cont.put(streamId, {
      'stream_id':   streamId,
      'name':        name,
      'poster_url':  posterUrl,
      'stream_url':  streamUrl,
      'position_ms': positionMs,
      'duration_ms': durationMs,
      'type':        type,
      'saved_at':    DateTime.now().millisecondsSinceEpoch,
    });
  }

  static List<Map> getContinueWatching() {
    final list = _cont.values
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    // Newest first
    list.sort((a, b) =>
        (b['saved_at'] as int).compareTo(a['saved_at'] as int));
    return list;
  }

  static Future<void> removeFromContinue(String streamId) async {
    await _cont.delete(streamId);
  }

  static int? getSavedPosition(String streamId) {
    final item = _cont.get(streamId);
    return item?['position_ms'] as int?;
  }

  static double getProgressPercent(String streamId) {
    final item = _cont.get(streamId);
    if (item == null) return 0;
    final pos = (item['position_ms'] as int?) ?? 0;
    final dur = (item['duration_ms'] as int?) ?? 1;
    return (pos / dur).clamp(0.0, 1.0);
  }
}