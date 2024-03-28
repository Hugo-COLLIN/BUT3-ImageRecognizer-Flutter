import 'package:flutter/material.dart';
import 'package:paddy_disease_classifier/data.dart';
import 'package:paddy_disease_classifier/pages/selection_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SelectionPage(title: appName),
      debugShowCheckedModeBanner: false,
    );
  }
}
