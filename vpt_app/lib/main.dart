import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/session_store.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const VptApp());
}

class VptApp extends StatelessWidget {
  const VptApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VehiclePriceTracker',
      theme: AppTheme.dark(),
      home: const RootScreen(),
    );
  }
}

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  final SessionStore _sessionStore = SessionStore();

  late Future<int?> _storedUserIdFuture;

  @override
  void initState() {
    super.initState();
    _storedUserIdFuture = _sessionStore.getUserId();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int?>(
      future: _storedUserIdFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final storedUserId = snapshot.data;

        if (storedUserId != null) {
          return HomeScreen(userId: storedUserId);
        }

        return const LoginScreen();
      },
    );
  }
}
