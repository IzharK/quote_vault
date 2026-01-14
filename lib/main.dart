import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:quote_vault/app.dart';
import 'package:quote_vault/core/constants/supa_constants.dart';
import 'package:quote_vault/core/di/injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupaConstants.supabaseUrl,
    anonKey: SupaConstants.supabaseAnonKey,
  );

  InjectionContainer.init();

  runApp(const MyApp());
}
