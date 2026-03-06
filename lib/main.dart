import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env only in development (file won't exist in Vercel production).
  // In production, use Vercel environment variables via --dart-define.
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // .env not found — running in production or CI
  }

  runApp(
    const ProviderScope(
      child: TeeDooApp(),
    ),
  );
}
