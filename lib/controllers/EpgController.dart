import 'package:get/get.dart';
import '../core/services/xtremeservice.dart';

class EpgProgram {
  final String title;
  final String description;
  final DateTime start;
  final DateTime end;

  EpgProgram({
    required this.title,
    required this.description,
    required this.start,
    required this.end,
  });

  bool get isLive =>
      DateTime.now().isAfter(start) && DateTime.now().isBefore(end);

  String get timeRange =>
      '${_fmt(start)} - ${_fmt(end)}';

  String _fmt(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  double get progressPercent {
    final total = end.difference(start).inSeconds;
    final done = DateTime.now().difference(start).inSeconds;
    return (done / total).clamp(0.0, 1.0);
  }
}

class EpgController extends GetxController {
  final isLoading = false.obs;
  final programs = <EpgProgram>[].obs;
  final currentProgram = Rxn<EpgProgram>();
  final nextProgram = Rxn<EpgProgram>();
  final errorMsg = ''.obs;

  Future<void> loadEpg(String streamId) async {
    isLoading.value = true;
    errorMsg.value = '';
    programs.clear();

    try {
      final data = await XtreamService.getShortEpg(streamId);

      if (data != null && data['epg_listings'] != null) {
        final listings = data['epg_listings'] as List;

        final list = listings.map((e) {
          // Xtream timestamps seconds mein hote hain
          final start = DateTime.fromMillisecondsSinceEpoch(
            int.parse(e['start_timestamp'].toString()) * 1000,
          );
          final end = DateTime.fromMillisecondsSinceEpoch(
            int.parse(e['stop_timestamp'].toString()) * 1000,
          );

          // Title base64 encoded hota hai Xtream mein
          String title = e['title'] ?? 'Unknown';
          try {
            final bytes = Uri.parse(
              'data:text/plain;base64,$title',
            );
            title = String.fromCharCodes(
              Uri.decodeComponent(bytes.toString()).codeUnits,
            );
          } catch (_) {}

          return EpgProgram(
            title: title,
            description: e['description'] ?? '',
            start: start,
            end: end,
          );
        }).toList();

        programs.assignAll(list);

        // Current aur next program nikalo
        final now = DateTime.now();
        currentProgram.value = list.firstWhereOrNull(
              (p) => now.isAfter(p.start) && now.isBefore(p.end),
        );
        final currentIdx = list.indexOf(currentProgram.value!);
        if (currentIdx != -1 && currentIdx + 1 < list.length) {
          nextProgram.value = list[currentIdx + 1];
        }
      }
    } catch (e) {
      errorMsg.value = 'EPG load nahi hua: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void clear() {
    programs.clear();
    currentProgram.value = null;
    nextProgram.value = null;
  }
}