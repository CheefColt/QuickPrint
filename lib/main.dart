import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/order_provider.dart' as provider;
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => provider.OrderProvider(),
      child: MaterialApp(
        title: 'Print Shop',
        theme: ThemeData.dark(),
        home: const HomeScreen(),
      ),
    );
  }
}