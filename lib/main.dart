import 'package:flutter/material.dart';

void main() {
  runApp(const PowerFanApp());
}

class PowerFanApp extends StatelessWidget {
  const PowerFanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Power Fan Network',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFFF5F6FA),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('POWER FAN NETWORK'),
        backgroundColor: const Color(0xFF1E0F45),
      ),
      body: const Center(
        child: Text(
          'Welcome to Power Fan Network',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
