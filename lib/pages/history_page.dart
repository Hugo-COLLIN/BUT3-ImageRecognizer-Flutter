import 'package:flutter/material.dart';
import 'dart:io';
import 'package:sea_animals_classifier/data.dart';

// TODO : images crop carré
//  + ne garder que la dernière prédiction d'une même image (seult si idem à la précédente,
//  ou aussi supprimer le précédent idem même si plus loin dans l'historique?)
// + afficher le résultat de prédiction au clic sur l'élément
// + option supprimer l'historique

class HistoryPage extends StatelessWidget {

  const HistoryPage({Key? key, required predictedImages})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: predictedImages.isNotEmpty
          ? ListView.separated(
              itemCount: predictedImages.length,
              itemBuilder: (context, index) {
                int reversedIndex = predictedImages.length - 1 - index;
                Map<String, dynamic> imageData = predictedImages[reversedIndex];
                File imageFile = imageData['image'];
                Map resultDict = imageData['result'];
                String mostProbablePrediction =
                    resultDict['confidences'][0]['label'];

                return ListTile(
                  leading: Image.file(imageFile, width: 100, height: 100),
                  title: Text(mostProbablePrediction),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(
                    height: 20,
                  ))
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
