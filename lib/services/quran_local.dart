import 'dart:convert';
import 'package:flutter/services.dart';

class QuranLocal {

  static Future<List<dynamic>> loadSurahs() async {

    final String response =
    await rootBundle.loadString('assets/quran.json');

    final data = jsonDecode(response);

    return data['surahs'];
  }
}