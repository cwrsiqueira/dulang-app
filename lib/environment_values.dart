import 'dart:convert';
import 'package:flutter/services.dart';

class FFDevEnvironmentValues {
  static const String currentEnvironment = 'Production';
  static const String environmentValuesPath =
      'assets/environment_values/environment.json';

  static final FFDevEnvironmentValues _instance =
      FFDevEnvironmentValues._internal();

  factory FFDevEnvironmentValues() {
    return _instance;
  }

  FFDevEnvironmentValues._internal();

  Map<String, dynamic> _values = {};

  Future<void> initialize() async {
    try {
      final String response =
          await rootBundle.loadString(environmentValuesPath);
      _values = json.decode(response);
    } catch (e) {
      print('Error loading environment values: $e');
    }
  }

  String get supabaseUrl => _values['SUPABASE_URL'] ?? '';
  String get supabaseAnonKey => _values['SUPABASE_ANON_KEY'] ?? '';
  String get youtubeApiKey => _values['YOUTUBE_API_KEY'] ?? '';
  String get revenueCatAndroidKey => _values['REVENUECAT_ANDROID_KEY'] ?? '';
}
