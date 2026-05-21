import 'package:dio/dio.dart';
import 'remote_config_service.dart';

class ApiService {
  static final Dio _dio = Dio();

  static String get _base => RemoteConfigService.serverUrl;

  // Login
  static Future<Map<String, dynamic>?> login(
      String username, String password) async {
    try {
      final res = await _dio.get(
        '$_base/player_api.php',
        queryParameters: {
          'username': username,
          'password': password,
        },
      );
      return res.data;
    } catch (e) {
      return null;
    }
  }

  // Live channels
  static Future<List> getLiveChannels(
      String username, String password) async {
    try {
      final res = await _dio.get(
        '$_base/player_api.php',
        queryParameters: {
          'username': username,
          'password': password,
          'action': 'get_live_streams',
        },
      );
      return res.data ?? [];
    } catch (e) {
      return [];
    }
  }

  // Movies
  static Future<List> getMovies(
      String username, String password) async {
    try {
      final res = await _dio.get(
        '$_base/player_api.php',
        queryParameters: {
          'username': username,
          'password': password,
          'action': 'get_vod_streams',
        },
      );
      return res.data ?? [];
    } catch (e) {
      return [];
    }
  }

  // Live stream URL builder
  static String getLiveStreamUrl(
      String username, String password, String streamId) {
    return '$_base/live/$username/$password/$streamId.m3u8';
  }
}