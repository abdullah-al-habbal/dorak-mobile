import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:client_app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  final preferences = await SharedAppPreferences.create();
  final feedCache = await SharedFeedCache.create();
  runApp(DorakApp(preferences: preferences, feedCache: feedCache));
}
