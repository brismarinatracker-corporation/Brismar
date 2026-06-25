import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  final url = dotenv.env['SUPABASE_URL']!;
  final key = dotenv.env['SUPABASE_ANON_KEY']!;
  final client = SupabaseClient(url, key);
  try {
    print('Testing query to registro_embarcaciones...');
    final response = await client.from('registro_embarcaciones').select().limit(1);
    print('Response: $response');
  } catch (e) {
    print('Error: $e');
  }
  exit(0);
}
