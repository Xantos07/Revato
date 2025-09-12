import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SaveTemporyCarousel {
  static Future<void> saveTempData({
    required String dreamTitle,
    required Map<String, List<String>> tagsByCategory,
    required Map<String, String> notesByCategory,
  }) async {
    debugPrint(
      'Saving temporary data: $dreamTitle, ${tagsByCategory.length} tag categories, ${notesByCategory.length} notes',
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('dreamTitle', dreamTitle);
    await prefs.setString('tagsByCategory', jsonEncode(tagsByCategory));
    await prefs.setString('notesByCategory', jsonEncode(notesByCategory));
  }

  static Future<Map<String, dynamic>> restoreTempData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'dreamTitle': prefs.getString('dreamTitle') ?? '',
      'tagsByCategory': _decodeTags(prefs.getString('tagsByCategory') ?? '{}'),
      'notesByCategory': _decodeNotes(
        prefs.getString('notesByCategory') ?? '{}',
      ),
    };
  }

  static Future<void> clearTempData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('dreamTitle');
    await prefs.remove('tagsByCategory');
    await prefs.remove('notesByCategory');
  }

  static Map<String, List<String>> _decodeTags(String str) {
    final map = jsonDecode(str) as Map<String, dynamic>;
    return map.map((k, v) => MapEntry(k, List<String>.from(v)));
  }

  static Map<String, String> _decodeNotes(String str) {
    final map = jsonDecode(str) as Map<String, dynamic>;
    return map.map((k, v) => MapEntry(k, v as String));
  }
}
