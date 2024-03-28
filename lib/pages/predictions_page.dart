import 'dart:io';
import 'package:flutter/material.dart';
import '../widgets.dart'; // Assurez-vous que ce fichier contient le widget buildResultsIndicators

class PredictionsPage extends StatelessWidget {
  final File imageURI;
  final Map resultDict;
  final String latency;
  final bool isLoading; // Ajout de l'état de chargement

  const PredictionsPage({
    Key? key,
    required this.imageURI,
    required this.resultDict,
    required this.latency,
    this.isLoading = true, // Par défaut, isLoading est vrai
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Predictions'),
      ),
      body: SingleChildScrollView( // Permet le défilement si le contenu dépasse l'écran
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: AspectRatio( // Contraint l'image à un rapport d'aspect
                aspectRatio: 1.5, // Vous pouvez ajuster ce rapport d'aspect selon vos besoins
                child: SizedBox(
                  width: double.infinity, // Prend toute la largeur disponible
                  child: Image.file(imageURI, fit: BoxFit.contain), // fit: BoxFit.contain pour s'assurer que l'image est entièrement visible
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (isLoading) ...[
              const Center(child: CircularProgressIndicator()), // Affiche un indicateur de chargement
              const SizedBox(height: 16),
              const Center(child: Text("Calculating predictions...")),
            ] else ...[
              Center(child: Text("Top 3 predictions:", style: Theme.of(context).textTheme.titleLarge),),
              const SizedBox(height: 12),
              FittedBox(child: buildResultsIndicators(resultDict)),
              const SizedBox(height: 24),
              Text("Latency: $latency ms", style: Theme.of(context).textTheme.titleMedium),
            ],
          ],
        ),
      ),
    );
  }
}
