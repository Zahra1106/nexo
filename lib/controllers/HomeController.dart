import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import '../../core/storage/local_storage.dart';

class HomeController extends GetxController {
  final channels = [].obs;
  final movies = [].obs;
  final categories = [].obs;
  final isLoading = true.obs;
  final selectedIndex = 0.obs;

  String get username => LocalStorage.getUsername() ?? '';
  String get password => LocalStorage.getPassword() ?? '';

  @override
  void onInit() {
    super.onInit();
    fetchAll();
  }

  Future<void> fetchAll() async {
    isLoading.value = true;

    final results = await Future.wait([
      ApiService.getLiveChannels(username, password),
      ApiService.getMovies(username, password),
    ]);

    channels.value = results[0];
    movies.value = results[1];

    // Categories nikaalo channels se
    final cats = <String>{};
    for (var ch in channels) {
      if (ch['category_name'] != null) {
        cats.add(ch['category_name']);
      }
    }
    categories.value = ['All', ...cats];

    isLoading.value = false;
  }
}