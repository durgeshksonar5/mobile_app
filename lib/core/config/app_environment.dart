enum AppEnvironment {
  development,
  staging,
  production,
  testing;

  static AppEnvironment fromString(String env) {
    switch (env.toLowerCase()) {
      case 'production':
      case 'prod':
        return AppEnvironment.production;
      case 'staging':
      case 'stage':
        return AppEnvironment.staging;
      case 'testing':
      case 'test':
        return AppEnvironment.testing;
      case 'development':
      case 'dev':
      default:
        return AppEnvironment.development;
    }
  }

  bool get isProduction => this == AppEnvironment.production;
  bool get isStaging => this == AppEnvironment.staging;
  bool get isDevelopment => this == AppEnvironment.development;
  bool get isTesting => this == AppEnvironment.testing;
}
