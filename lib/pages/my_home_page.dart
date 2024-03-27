import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:empty_widget/empty_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:image_picker/image_picker.dart';
import 'package:paddy_disease_classifier/data.dart';
import 'package:url_launcher/url_launcher.dart';
import '../process/services.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../widgets.dart';
import '../process/utils.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? _resultString;
  Map _resultDict = {
    "label": "None",
    "confidences": [
      {"label": "None", "confidence": 0.0},
      {"label": "None", "confidence": 0.0},
      {"label": "None", "confidence": 0.0}
    ]
  };

  String _latency = "N/A";

  File? imageURI; // Show on image widget on app
  Uint8List? imgBytes; // Store img to be sent for api inference
  bool isClassifying = false;

  String parseResultsIntoString(Map results) {
    return """
    ${results['confidences'][0]['label']} - ${(results['confidences'][0]['confidence'] * 100.0).toStringAsFixed(2)}% \n
    ${results['confidences'][1]['label']} - ${(results['confidences'][1]['confidence'] * 100.0).toStringAsFixed(2)}% \n
    ${results['confidences'][2]['label']} - ${(results['confidences'][2]['confidence'] * 100.0).toStringAsFixed(2)}% """;
  }

  clearInferenceResults() {
    _resultString = "";
    _latency = "N/A";
    _resultDict = {
      "label": "None",
      "confidences": [
        {"label": "None", "confidence": 0.0},
        {"label": "None", "confidence": 0.0},
        {"label": "None", "confidence": 0.0}
      ]
    };
  }

  // Nouvelle fonction pour classifier l'image
  Future<void> classifyImage() async {
    if (imageURI == null) return;

    setState(() {
      isClassifying = true;
    });

    imgBytes = await imageURI!.readAsBytes();
    String base64Image = "data:image/png;base64," + base64Encode(imgBytes!);

    try {
      Stopwatch stopwatch = Stopwatch()..start();
      final result = await classifyRiceImage(base64Image);

      setState(() {
        _resultString = parseResultsIntoString(result);
        _resultDict = result;
        _latency = stopwatch.elapsed.inMilliseconds.toString();
        isClassifying = false;
      });
    } catch (e) {
      setState(() {
        isClassifying = false;
      });
      // Handle error
    }
  }

  Widget buildModalBtmSheetItems() {
    return SizedBox(
      height: 120,
      child: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.camera),
            title: const Text("Camera"),
            onTap: () async {
              final XFile? pickedFile =
              await ImagePicker().pickImage(source: ImageSource.camera);

              if (pickedFile != null) {
                // Clear result of previous inference as soon as new image is selected
                setState(() {
                  clearInferenceResults();
                });

                File croppedFile = await cropImage(pickedFile);
                final imgFile = File(croppedFile.path);
                // File imgFile = File(pickedFile.path);
                // or image_cropper 5.0.1 check la page et modif manifest.xml android

                setState(() {
                  imageURI = imgFile;
                  isClassifying = false;
                });
                Navigator.pop(context);
                classifyImage(); // Appeler la fonction de classification
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.image),
            title: const Text("Gallery"),
            onTap: () async {
              final XFile? pickedFile =
                  await ImagePicker().pickImage(source: ImageSource.gallery);

              if (pickedFile != null) {
                // Clear result of previous inference as soon as new image is selected
                setState(() {
                  clearInferenceResults();
                });

                File croppedFile = await cropImage(pickedFile);
                final imgFile = File(croppedFile.path);

                setState(
                  () {
                    imageURI = imgFile;
                    isClassifying = false;
                  },
                );
                Navigator.pop(context);
                classifyImage(); // Appeler la fonction de classification
              }
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> imageSliders = imgList
        .map((item) => Container(
              margin: const EdgeInsets.all(5.0),
              child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                  child: Stack(
                    children: <Widget>[
                      GestureDetector(
                        onTap: () async {
                          context.loaderOverlay.show();

                          String imgUrl = imgList[imgList.indexOf(item)];

                          final imgFile = await getImage(imgUrl);

                          setState(() {
                            imageURI = imgFile;
                            isClassifying = false;
                            clearInferenceResults();
                          });
                          context.loaderOverlay.hide();
                          classifyImage();
                        },
                        child: CachedNetworkImage(
                          imageUrl: item,
                          fit: BoxFit.fill,
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                      ),
                      Positioned(
                        bottom: 0.0,
                        left: 0.0,
                        right: 0.0,
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color.fromARGB(200, 0, 0, 0),
                                Color.fromARGB(0, 0, 0, 0)
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 20.0),
                          child: Text(
                            'GT: ${imgList[imgList.indexOf(item)].split('/').reversed.elementAt(1)}', // get the class name from url
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )),
            ))
        .toList();

    return LoaderOverlay(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              imageURI == null
                  ? SizedBox(
                      height: 200,
                      child: EmptyWidget(
                        image: null,
                        packageImage: PackageImage.Image_3,
                        title: 'No image',
                        subTitle: 'Select an image',
                        titleTextStyle: const TextStyle(
                          fontSize: 15,
                          color: Color(0xff9da9c7),
                          fontWeight: FontWeight.w500,
                        ),
                        subtitleTextStyle: const TextStyle(
                          fontSize: 14,
                          color: Color(0xffabb8d6),
                        ),
                      ),
                    )
                  : Row(
                      children: [
                        const Spacer(),
                        Image.file(imageURI!, height: 200, fit: BoxFit.cover),
                        const Spacer(),
                      ],
                    ),
              const SizedBox(
                height: 8,
              ),
              Text("Top 3 predictions",
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              FittedBox(child: buildResultsIndicators(_resultDict)),
              const SizedBox(height: 8),
              Text("Latency: $_latency ms",
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: FloatingActionButton.extended(
                      label: const Text("Take a picture"),
                      icon: const Icon(Icons.camera),
                      onPressed: () {
                        showModalBottomSheet<void>(
                          context: context,
                          builder: (BuildContext context) {
                            return buildModalBtmSheetItems();
                          },
                        );
                      },
                    ),
                  ),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 8),
              Center(
                  child: Text("Or select a sample :",
                      style: Theme.of(context).textTheme.titleLarge)),
              const SizedBox(height: 8),
              CarouselSlider(
                options: CarouselOptions(
                  height: 180,
                  autoPlay: true,
                  viewportFraction: 0.4,
                  enlargeCenterPage: false,
                  enlargeStrategy: CenterPageEnlargeStrategy.height,
                ),
                items: imageSliders,
              ),
              Row(
                children: [
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Linkify(
                      onOpen: (link) async {
                        if (await canLaunchUrl(Uri.parse(link.url))) {
                          await launchUrl(Uri.parse(link.url));
                        } else {
                          throw 'Could not launch $link';
                        }
                      },
                      text:
                          "Based on \"Rice Diseases\" : https://dicksonneoh.com",
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
