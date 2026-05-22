import 'package:get/get.dart';
import '../core/services/xtremeservice.dart';
import '../core/storage/local_storage.dart';

class LiveChannel {
  final String streamId;
  final String name;
  final String logoUrl;
  final String categoryId;
  final String categoryName;
  final int num;

  LiveChannel({
    required this.streamId,
    required this.name,
    required this.logoUrl,
    required this.categoryId,
    required this.categoryName,
    required this.num,
  });

  factory LiveChannel.fromJson(Map<String, dynamic> json) {
    return LiveChannel(
      streamId:     json['stream_id']?.toString()   ?? '',
      name:         json['name']                    ?? 'Unknown',
      logoUrl:      json['stream_icon']             ?? '',
      categoryId:   json['category_id']?.toString() ?? '',
      categoryName: json['category_name']           ?? '',
      num:          int.tryParse(json['num']?.toString() ?? '0') ?? 0,
    );
  }

  String get streamUrl => XtreamService.getLiveUrl(streamId);
}

class LiveCategory {
  final String id;
  final String name;
  LiveCategory({required this.id, required this.name});

  factory LiveCategory.fromJson(Map<String, dynamic> json) {
    return LiveCategory(
      id:   json['category_id']?.toString() ?? '',
      name: json['category_name']           ?? 'Unknown',
    );
  }
}

class LiveTvController extends GetxController {
  final isLoading        = true.obs;
  final errorMsg         = ''.obs;

  final categories       = <LiveCategory>[].obs;
  final allChannels      = <LiveChannel>[].obs;
  final filteredChannels = <LiveChannel>[].obs;

  final selectedCategoryId = 'all'.obs;
  final currentChannelIdx  = 0.obs;

  LiveChannel? get currentChannel =>
      filteredChannels.isNotEmpty
          ? filteredChannels[currentChannelIdx.value]
          : null;

  @override
  void onInit() {
    super.onInit();
    fetchAll();
  }

  Future<void> fetchAll() async {
    isLoading.value = true;
    errorMsg.value  = '';

    try {
      final results = await Future.wait([
        XtreamService.getLiveCategories(),
        XtreamService.getLiveChannels(),
      ]);

      final cats = (results[0] as List)
          .map((e) => LiveCategory.fromJson(e as Map<String, dynamic>))
          .toList();

      categories.assignAll([
        LiveCategory(id: 'all', name: 'All'),
        ...cats,
      ]);

      final chs = (results[1] as List)
          .map((e) => LiveChannel.fromJson(e as Map<String, dynamic>))
          .toList();

      allChannels.assignAll(chs);
      filteredChannels.assignAll(chs);
    } catch (e) {
      errorMsg.value = 'Data load nahi hua: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void selectCategory(String categoryId) {
    selectedCategoryId.value = categoryId;
    currentChannelIdx.value  = 0;

    if (categoryId == 'all') {
      filteredChannels.assignAll(allChannels);
    } else {
      filteredChannels.assignAll(
        allChannels.where((ch) => ch.categoryId == categoryId),
      );
    }
  }

  void selectChannel(int index) {
    currentChannelIdx.value = index.clamp(0, filteredChannels.length - 1);
  }

  void channelUp() {
    if (currentChannelIdx.value > 0) {
      currentChannelIdx.value--;
    }
  }

  void channelDown() {
    if (currentChannelIdx.value < filteredChannels.length - 1) {
      currentChannelIdx.value++;
    }
  }
}