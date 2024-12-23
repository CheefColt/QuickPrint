import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/order_provider.dart' as provider;
import 'services/api_service.dart';
import 'screens/home_screen.dart';
import 'screens/upload_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>(
          create: (_) => ApiService(),
        ),
        ChangeNotifierProvider<provider.OrderProvider>(
          create: (context) => provider.OrderProvider(
            apiService: context.read<ApiService>(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Print Shop',
      theme: ThemeData.dark(),
      routes: {
        '/': (context) => const HomeScreen(),
        '/upload': (context) => const UploadScreen(),
      },
    );
  }
}