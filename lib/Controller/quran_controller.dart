import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class QuranController extends GetxController {
  var surahs = <dynamic>[].obs;
  var filteredSurahs = <dynamic>[].obs;
  var isLoading = true.obs;
  var errorMessage = "".obs;

  @override
  void onInit() {
    super.onInit();
    loadLocalSurahsData(); // يبدأ التحميل مسبقاً في الخلفية
  }

  static List<dynamic> _parseSurahs(String response) {
    return json.decode(response);
  }

  Future<void> loadLocalSurahsData() async {
    try {
      final String response = await rootBundle.loadString('assets/data/surah.json');
      final List<dynamic> data = await compute(_parseSurahs, response);

      surahs.assignAll(data);
      filteredSurahs.assignAll(data);
      isLoading.value = false;
    } catch (e) {
      errorMessage.value = "error_quran".tr;
      isLoading.value = false;
    }
  }

  void filterSurahs(String query) {
    if (query.isEmpty) {
      filteredSurahs.assignAll(surahs);
    } else {
      final filtered = surahs.where((surah) {
        final nameAr = (surah['title'] ?? surah['name'] ?? '').toString().toLowerCase();
        final nameEn = (surah['english_name'] ?? '').toString().toLowerCase();
        return nameAr.contains(query.toLowerCase()) || nameEn.contains(query.toLowerCase());
      }).toList();
      filteredSurahs.assignAll(filtered);
    }
  }
}