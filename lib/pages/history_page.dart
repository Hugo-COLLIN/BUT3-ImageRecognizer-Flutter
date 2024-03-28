import 'package:flutter/material.dart';
import 'dart:io';

class HistoryPage extends StatelessWidget {
  final List<File> predictedImages; // Liste des images prédites

  const HistoryPage({Key? key, required this.predictedImages}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: ListView.builder(
        itemCount: predictedImages.length,
        itemBuilder: (context, index) {
          int reversedIndex = predictedImages.length - 1 - index;
          return ListTile(
            leading: Image.file(predictedImages[reversedIndex], width: 50, height: 50),
            title: Text('Image ${index + 1}'),
          );
        },
      ),
    );
  }
}
