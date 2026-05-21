import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigService {
  static final _remoteConfig = FirebaseRemoteConfig.instance;

  static Future<void> init() async {
    await _remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: const Duration(hours: 1),
    ));

    // Default URL — jab tak Firebase se naya na aaye
    await _remoteConfig.setDefaults({
      'server_base_url': 'http://your-default-server.com',
    });

    await _remoteConfig.fetchAndActivate();
  }

  static String get serverUrl =>
      _remoteConfig.getString('server_base_url');
}