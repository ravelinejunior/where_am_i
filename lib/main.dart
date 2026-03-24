import 'package:flutter/material.dart';

void main() {
  runApp(const MissingPersonsApp());
}

class MissingPersonsApp extends StatelessWidget {
  const MissingPersonsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Missing Persons',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: const PlaceholderHomePage(),
    );
  }
}

class PlaceholderHomePage extends StatelessWidget {
  const PlaceholderHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Missing Persons')),
      body: const Center(
        child: Text(
          'Projeto inicializado com sucesso',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
