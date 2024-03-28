import 'package:flutter/material.dart';
import 'dart:io';
import 'package:sea_animals_classifier/data.dart';
import 'package:sea_animals_classifier/pages/predictions_page.dart';

// TODO : images crop carré
//  + ne garder que la dernière prédiction d'une même image (seult si idem à la précédente,
//  ou aussi supprimer le précédent idem même si plus loin dans l'historique?)
// + afficher le résultat de prédiction au clic sur l'élément

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: <Widget>[
          if (predictedImages.isNotEmpty) // Masquer l'icône si l'historique est vide
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Confirm"),
                      content: Text("Are you sure you want to delete the history?"),
                      actions: <Widget>[
                        TextButton(
                          child: Text("Cancel"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: Text("Delete"),
                          onPressed: () {
                            setState(() {
                              predictedImages.clear();
                            });
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
        ],
      ),
      body: predictedImages.isNotEmpty
          ? ListView.separated(
              itemCount: predictedImages.length,
              itemBuilder: (context, index) {
                int reversedIndex = predictedImages.length - 1 - index;
                Map<String, dynamic> imageData = predictedImages[reversedIndex];
                File imageFile = imageData['image'];
                Map resultDict = imageData['result'];
                String latency = imageData['latency'];
                bool isLoading = imageData['isLoading'];

                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PredictionsPage(
                          imageURI: imageFile,
                          resultDict: resultDict,
                          latency: latency,
                          isLoading: isLoading,
                        ),
                      ),
                    );
                  },
                  child: ListTile(
                    leading: Image.file(imageFile, width: 100, height: 100),
                    title: Text(resultDict['confidences'][0]['label']),
                  ),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(height: 20),
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
