// pages/predictions_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../widgets.dart'; // Assurez-vous que ce fichier contient le widget buildResultsIndicators

class PredictionsPage extends StatelessWidget {
  final File imageURI;
  final Map resultDict;
  final String latency;

  const PredictionsPage({
    Key? key,
    required this.imageURI,
    required this.resultDict,
    required this.latency,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Predictions'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                const Spacer(),
                Image.file(imageURI, height: 200, fit: BoxFit.cover),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 8),
            Text("Top 3 predictions", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            FittedBox(child: buildResultsIndicators(resultDict)),
            const SizedBox(height: 8),
            Text("Latency: $latency ms", style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
      ),
    );
  }
}
