import 'package:flutter/material.dart';
import 'dart:io';

class HistoryPage extends StatelessWidget {
  final List<Map<String, dynamic>> predictedImages; // Liste des images prédites avec leurs résultats

  const HistoryPage({Key? key, required this.predictedImages}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: predictedImages.isNotEmpty
          ? ListView.builder(
        itemCount: predictedImages.length,
        itemBuilder: (context, index) {
          int reversedIndex = predictedImages.length - 1 - index;
          Map<String, dynamic> imageData = predictedImages[reversedIndex];
          File imageFile = imageData['image'];
          Map resultDict = imageData['result'];
          String mostProbablePrediction = resultDict['confidences'][0]['label'];

          return ListTile(
            leading: Image.file(imageFile, width: 50, height: 50),
            title: Text('$mostProbablePrediction'),
          );
        },
      )
      : const Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 16.0),
            child: Center(
              child: Text(
              "Empty history...",
              style: TextStyle(fontSize: 18),
            ),
            ),
          ),
        ],
      ),
    );
  }
}
