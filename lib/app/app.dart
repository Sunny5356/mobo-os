import 'package:flutter/material.dart';
import 'package:mobo_app/core/database/app_database.dart';
import 'theme/mobo_theme.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../core/widgets/ai_quick_query_bubble.dart';
import 'package:mobo_app/features/mobo_ai/presentation/screens/ai_chat_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final db = AppDatabase();
    return MaterialApp(
      title: 'MOBO',
      theme: buildMoboTheme(),
      home: HomeScreen(db: db),
      routes: {
        '/ai': (_) => AiChatScreen(conversationId: 'default'),
      },
    );
  }
}
