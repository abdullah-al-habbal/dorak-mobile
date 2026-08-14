import 'package:core/src/config/app_config.entity.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ConfigProvider {
  static AppConfig get config {
    if (!dotenv.isInitialized) {
      throw StateError(
        'dotenv not loaded. Call await dotenv.load() in main() before accessing config.',
      );
    }
    return AppConfig(
      apiBaseUrl: dotenv.get('API_BASE_URL'),
      apiBaseV1Url: dotenv.get('API_BASE_URL_V1'),
    );
  }
}
