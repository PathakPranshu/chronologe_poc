import 'package:google_generative_ai/google_generative_ai.dart';

const String apiKey = String.fromEnvironment('GEMINI_API_KEY');

Future<void> main() async {
  if (apiKey.isEmpty) {
    print('API key not found.');
    return;
  }

  final model = GenerativeModel(
    model: 'gemini-3.6-flash',
    apiKey: apiKey,
  );

  final response = await model.generateContent([
    Content.text('Say: Gemini connection successful.'),
  ]);
  print(response.text);
} 