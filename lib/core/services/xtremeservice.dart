import 'package:dio/dio.dart';
import '../storage/local_storage.dart';
import 'remote_config_service.dart';

class XtreamService {
  static final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
  ));

  static String get _base => RemoteConfigService.serverUrl;
  static String get _user => LocalStorage.getUsername() ?? '';
  static String get _pass => LocalStorage.getPassword() ?? '';

  // ─────────────────────────────────────────
  //  AUTH
  // ─────────────────────────────────────────

  static Future<Map<String, dynamic>?> login(
      String username, String password) async {
    try {
      final res = await _dio.get(
        '$_base/player_api.php',
        queryParameters: {'username': username, 'password': password},
      );
      return res.data;
    } on DioException catch (e) {
      print('[XtreamService] login error: ${e.message}');
      return null;
    }
  }

  // ─────────────────────────────────────────
  //  LIVE TV
  // ─────────────────────────────────────────

  static Future<List> getLiveChannels() async {
    try {
      final res = await _dio.get('$_base/player_api.php',
          queryParameters: {
            'username': _user,
            'password': _pass,
            'action': 'get_live_streams',
          });
      return res.data ?? [];
    } on DioException catch (e) {
      print('[XtreamService] getLiveChannels error: ${e.message}');
      return [];
    }
  }

  static Future<List> getLiveCategories() async {
    try {
      final res = await _dio.get('$_base/player_api.php',
          queryParameters: {
            'username': _user,
            'password': _pass,
            'action': 'get_live_categories',
          });
      return res.data ?? [];
    } on DioException catch (e) {
      print('[XtreamService] getLiveCategories error: ${e.message}');
      return [];
    }
  }

  static Future<List> getChannelsByCategory(String categoryId) async {
    try {
      final res = await _dio.get('$_base/player_api.php',
          queryParameters: {
            'username': _user,
            'password': _pass,
            'action': 'get_live_streams',
            'category_id': categoryId,
          });
      return res.data ?? [];
    } on DioException catch (e) {
      print('[XtreamService] getChannelsByCategory error: ${e.message}');
      return [];
    }
  }

  static String getLiveUrl(String streamId) {
    return '$_base/live/$_user/$_pass/$streamId.m3u8';
  }

  // ─────────────────────────────────────────
  //  VOD — MOVIES
  // ─────────────────────────────────────────

  static Future<List> getMovies() async {
    try {
      final res = await _dio.get('$_base/player_api.php',
          queryParameters: {
            'username': _user,
            'password': _pass,
            'action': 'get_vod_streams',
          });
      return res.data ?? [];
    } on DioException catch (e) {
      print('[XtreamService] getMovies error: ${e.message}');
      return [];
    }
  }

  /// ← NEW: category ke hisaab se movies
  static Future<List> getMoviesByCategory(String categoryId) async {
    try {
      final res = await _dio.get('$_base/player_api.php',
          queryParameters: {
            'username': _user,
            'password': _pass,
            'action': 'get_vod_streams',
            'category_id': categoryId,
          });
      return res.data ?? [];
    } on DioException catch (e) {
      print('[XtreamService] getMoviesByCategory error: ${e.message}');
      return [];
    }
  }

  static Future<List> getMovieCategories() async {
    try {
      final res = await _dio.get('$_base/player_api.php',
          queryParameters: {
            'username': _user,
            'password': _pass,
            'action': 'get_vod_categories',
          });
      return res.data ?? [];
    } on DioException catch (e) {
      print('[XtreamService] getMovieCategories error: ${e.message}');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getMovieDetail(String vodId) async {
    try {
      final res = await _dio.get('$_base/player_api.php',
          queryParameters: {
            'username': _user,
            'password': _pass,
            'action': 'get_vod_info',
            'vod_id': vodId,
          });
      return res.data;
    } on DioException catch (e) {
      print('[XtreamService] getMovieDetail error: ${e.message}');
      return null;
    }
  }

  static String getMovieUrl(String streamId, String containerExtension) {
    return '$_base/movie/$_user/$_pass/$streamId.$containerExtension';
  }

  // ─────────────────────────────────────────
  //  SERIES
  // ─────────────────────────────────────────

  static Future<List> getSeries() async {
    try {
      final res = await _dio.get('$_base/player_api.php',
          queryParameters: {
            'username': _user,
            'password': _pass,
            'action': 'get_series',
          });
      return res.data ?? [];
    } on DioException catch (e) {
      print('[XtreamService] getSeries error: ${e.message}');
      return [];
    }
  }

  static Future<List> getSeriesCategories() async {
    try {
      final res = await _dio.get('$_base/player_api.php',
          queryParameters: {
            'username': _user,
            'password': _pass,
            'action': 'get_series_categories',
          });
      return res.data ?? [];
    } on DioException catch (e) {
      print('[XtreamService] getSeriesCategories error: ${e.message}');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getSeriesDetail(
      String seriesId) async {
    try {
      final res = await _dio.get('$_base/player_api.php',
          queryParameters: {
            'username': _user,
            'password': _pass,
            'action': 'get_series_info',
            'series_id': seriesId,
          });
      return res.data;
    } on DioException catch (e) {
      print('[XtreamService] getSeriesDetail error: ${e.message}');
      return null;
    }
  }

  static String getEpisodeUrl(
      String streamId, String containerExtension) {
    return '$_base/series/$_user/$_pass/$streamId.$containerExtension';
  }

  // ─────────────────────────────────────────
  //  EPG
  // ─────────────────────────────────────────

  static Future<Map<String, dynamic>?> getEpg(String streamId) async {
    try {
      final res = await _dio.get('$_base/player_api.php',
          queryParameters: {
            'username': _user,
            'password': _pass,
            'action': 'get_simple_data_table',
            'stream_id': streamId,
          });
      return res.data;
    } on DioException catch (e) {
      print('[XtreamService] getEpg error: ${e.message}');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getShortEpg(
      String streamId) async {
    try {
      final res = await _dio.get('$_base/player_api.php',
          queryParameters: {
            'username': _user,
            'password': _pass,
            'action': 'get_short_epg',
            'stream_id': streamId,
            'limit': '2',
          });
      return res.data;
    } on DioException catch (e) {
      print('[XtreamService] getShortEpg error: ${e.message}');
      return null;
    }
  }
}