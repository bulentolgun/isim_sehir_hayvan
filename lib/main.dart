import 'package:flutter/material.dart';
import 'lobby_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const KelimeTurnuvasiApp());
}

class KelimeTurnuvasiApp extends StatelessWidget {
  const KelimeTurnuvasiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Türkiye Canlı Kelime Turnuvası',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF5E17EB),
        scaffoldBackgroundColor: const Color(0xFFF8F9FD),
        fontFamily: 'Roboto',
      ),
      home: const LobbyPage(),
    );
  }
}