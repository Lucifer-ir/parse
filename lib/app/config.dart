/// Central runtime configuration for Parse.
/// Override values at build time with --dart-define.
abstract final class ParseConfig {
  static const apiBaseUrl = String.fromEnvironment('PARSE_API_URL', defaultValue: 'https://api.example.com/api');
  static const appName = String.fromEnvironment('PARSE_APP_NAME', defaultValue: 'Parse');
  static const requestTimeoutSeconds = int.fromEnvironment('PARSE_TIMEOUT', defaultValue: 20);
}
