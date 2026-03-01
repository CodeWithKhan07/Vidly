import 'package:flutter_dotenv/flutter_dotenv.dart';

const String baseUrl =
    'https://social-download-all-in-one.p.rapidapi.com/v1/social/autolink';
String apiKey = dotenv.env['API_KEY'] ?? "";
