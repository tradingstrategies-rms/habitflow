import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/core/services/config/app_config.dart';
import 'package:habitflow/core/services/environment/environment.dart';

void main() {
  group('AppConfig', () {
    test('fromEnvironment returns development config', () {
      final config = AppConfig.fromEnvironment(Environment.development);
      expect(config.appName, 'HabitFlow (Dev)');
      expect(config.environment, Environment.development);
      expect(config.isProduction, isFalse);
    });

    test('fromEnvironment returns production config', () {
      final config = AppConfig.fromEnvironment(Environment.production);
      expect(config.appName, 'HabitFlow');
      expect(config.environment, Environment.production);
      expect(config.isProduction, isTrue);
    });

    test('isProduction returns true only for production environment', () {
      expect(AppConfig.fromEnvironment(Environment.development).isProduction, isFalse);
      expect(AppConfig.fromEnvironment(Environment.staging).isProduction, isFalse);
      expect(AppConfig.fromEnvironment(Environment.production).isProduction, isTrue);
    });
  });
}
