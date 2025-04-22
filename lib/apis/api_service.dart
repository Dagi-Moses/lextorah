class ApiService {
  static const String apiKey = String.fromEnvironment('API_KEY');

  static const String serverUrl = String.fromEnvironment(
    'SERVER_URL',
    defaultValue: "http://localhost:3000",
  );
}
