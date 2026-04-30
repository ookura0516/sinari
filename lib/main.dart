import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'shared/providers/database_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = await DatabaseHelper.open();
  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(database),
      ],
      child: const SinariApp(),
    ),
  );
}
