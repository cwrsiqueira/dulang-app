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
  String get youtubeApiKey {
    const fromDefine = String.fromEnvironment('YOUTUBE_API_KEY');
    if (fromDefine.isNotEmpty) {
      return fromDefine;
    }
    return _values['YOUTUBE_API_KEY'] ?? '';
  }
  String get revenueCatAndroidKey {
    const fromDefine = String.fromEnvironment('REVENUECAT_ANDROID_KEY');
    if (fromDefine.isNotEmpty) {
      return fromDefine;
    }
    return _values['REVENUECAT_ANDROID_KEY'] ?? '';
  }

  String get revenueCatIosKey {
    const fromDefine = String.fromEnvironment('REVENUECAT_IOS_KEY');
    if (fromDefine.isNotEmpty) {
      return fromDefine;
    }
    return _values['REVENUECAT_IOS_KEY'] ?? '';
  }

  String get brevoApiKey => _values['BREVO_API_KEY'] ?? '';

  int get brevoListId =>
      int.tryParse(_values['BREVO_LIST_ID']?.toString() ?? '') ?? 2;
}
