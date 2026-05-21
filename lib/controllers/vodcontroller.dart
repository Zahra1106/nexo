import 'package:get/get.dart';

import '../core/services/xtremeservice.dart';

// ── Data Models ───────────────────────────────────────────────────────────────

class VodItem {
  final String streamId;
  final String name;
  final String posterUrl;
  final String plot;
  final String genre;
  final String rating;
  final String year;
  final String duration;
  final String streamUrl;

  VodItem({
    required this.streamId,
    required this.name,
    required this.posterUrl,
    required this.plot,
    required this.genre,
    required this.rating,
    required this.year,
    required this.duration,
    required this.streamUrl,
  });

  factory VodItem.fromJson(Map<String, dynamic> json) {
    return VodItem(
      streamId:  json['stream_id']?.toString()  ?? '',
      name:      json['name']                   ?? 'Unknown',
      posterUrl: json['stream_icon']            ?? '',
      plot:      json['plot']                   ?? 'No description available.',
      genre:     json['genre']                  ?? 'Unknown',
      rating:    json['rating']?.toString()     ?? '0',
      year:      json['year']?.toString()       ?? '',
      duration:  json['duration']               ?? '',
      streamUrl: json['stream_url']             ?? '',
    );
  }
}

class VodCategory {
  final String id;
  final String name;
  VodCategory({required this.id, required this.name});

  factory VodCategory.fromJson(Map<String, dynamic> json) {
    return VodCategory(
      id:   json['category_id']?.toString() ?? '',
      name: json['category_name']           ?? 'Unknown',
    );
  }
}

// ── Controller ────────────────────────────────────────────────────────────────

class VodController extends GetxController {
  // State
  final isLoading        = true.obs;
  final isLoadingDetail  = false.obs;
  final errorMessage     = ''.obs;

  final categories       = <VodCategory>[].obs;
  final allItems         = <VodItem>[].obs;
  final filteredItems    = <VodItem>[].obs;
  final selectedCategory = 'all'.obs;
  final searchQuery      = ''.obs;
  final isSeries         = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
    fetchVodItems();
  }

  // ── Fetch ──────────────────────────────────────────────────────────────────

  Future<void> fetchCategories() async {
    try {
      final List data = isSeries.value
          ? await XtreamService.getSeriesCategories()
          : await XtreamService.getMovieCategories();

      final list = data
          .map((e) => VodCategory.fromJson(e as Map<String, dynamic>))
          .toList();

      categories.assignAll([
        VodCategory(id: 'all', name: 'All'),
        ...list,
      ]);
    } catch (e) {
      errorMessage.value = 'Categories load nahi hui: $e';
    }
  }

  Future<void> fetchVodItems({String? categoryId}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      List data;

      if (isSeries.value) {
        // Series mode
        data = await XtreamService.getSeries();
      } else {
        // Movies mode
        if (categoryId != null && categoryId != 'all') {
          data = await XtreamService.getMoviesByCategory(categoryId);
        } else {
          data = await XtreamService.getMovies();
        }
      }

      final list = data
          .map((e) => VodItem.fromJson(e as Map<String, dynamic>))
          .toList();

      allItems.assignAll(list);
      _applyFilter();
    } catch (e) {
      errorMessage.value = 'Content load nahi hua: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // ── Filter + Search ────────────────────────────────────────────────────────

  void selectCategory(String categoryId) {
    selectedCategory.value = categoryId;
    fetchVodItems(categoryId: categoryId);
  }

  void onSearch(String query) {
    searchQuery.value = query;
    _applyFilter();
  }

  void _applyFilter() {
    final q = searchQuery.value.toLowerCase();
    if (q.isEmpty) {
      filteredItems.assignAll(allItems);
    } else {
      filteredItems.assignAll(
        allItems.where((item) => item.name.toLowerCase().contains(q)),
      );
    }
  }

  void toggleSeriesMode(bool series) {
    isSeries.value = series;
    allItems.clear();
    filteredItems.clear();
    categories.clear();
    selectedCategory.value = 'all';
    fetchCategories();
    fetchVodItems();
  }

  @override
  Future<void> refresh() async {
    await fetchVodItems(
      categoryId: selectedCategory.value == 'all'
          ? null
          : selectedCategory.value,
    );
  }
}