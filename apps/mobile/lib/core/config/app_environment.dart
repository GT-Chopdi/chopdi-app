class AppEnvironment {
  static const String appVersion = String.fromEnvironment(
    'APP_VERSION',
    defaultValue: '0.0.0',
  );

  static const String buildNumber = String.fromEnvironment(
    'APP_BUILD_NUMBER',
    defaultValue: '0',
  );
}