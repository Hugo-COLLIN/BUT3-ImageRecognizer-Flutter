import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:empty_widget/empty_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'services.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'widgets.dart';
import 'utils.dart';

final List<String> imgList = [
  'https://oceana.org/wp-content/uploads/sites/18/cephalopods.jpg',
  'https://images.pexels.com/photos/1076758/pexels-photo-1076758.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
  'https://i.natgeofe.com/n/d36dafe7-5837-4ba3-b572-5e097e60820c/18161_3x2.jpg',
  'https://wpvip.ted.com/wp-content/uploads/sites/3/2014/06/sailfish.jpg',
  'https://www.nothingfishy.co/cdn/shop/articles/animal-1868046_1280.jpg?v=1683647714&width=1100',
  'https://allthatsinteresting.com/wordpress/wp-content/uploads/2013/09/blobfish-out-of-water.jpg',
  'https://c02.purpledshub.com/uploads/sites/62/2023/09/Lionfish.jpg',
  'https://images.saymedia-content.com/.image/ar_4:3%2Cc_fill%2Ccs_srgb%2Cfl_progressive%2Cq_auto:eco%2Cw_1200/MjAzMzEzMDI1MzgwMjYzMDk0/sea-animals-list.jpg',
  'https://30a.com/wp-content/uploads/2020/02/Seahorse-mating-photo-by-Don-McLeish-.jpg',
  'https://images.squarespace-cdn.com/content/v1/5e2755963c421657bd408970/e3a534b0-e703-4c2d-a048-df995b6fbffa/Mammals.jpg',
];

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
                  // _btnController.stop();
                  isClassifying = false;
                });
                Navigator.pop(context);
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
                    // _btnController.stop();
                    isClassifying = false;
                  },
                );
                Navigator.pop(context);
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
                            // _btnController.stop();
                            isClassifying = false;
                            clearInferenceResults();
                          });
                          context.loaderOverlay.hide();
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
        drawer: Drawer(
          // Add a ListView to the drawer. This ensures the user can scroll
          // through the options in the drawer if there isn't enough vertical
          // space to fit everything.
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Text('My Paddy Disease App'),
              ),
              ListTile(
                title: const Text('About'),
                onTap: () {
                  // Update the state of the app
                  // ...
                  // Then close the drawer
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Version'),
                onTap: () {
                  // Update the state of the app
                  // ...
                  // Then close the drawer
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
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
        floatingActionButton: Row(
          children: [
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  // primary: Colors.blue, // background color
                  // onPrimary: Colors.white, // text color
                  ),
              onPressed: isClassifying || imageURI == null
                  ? null // null value disables the button
                  : () async {
                      setState(() {
                        isClassifying = true;
                      });

                      imgBytes = await imageURI!.readAsBytes();
                      String base64Image =
                          "data:image/png;base64," + base64Encode(imgBytes!);

                      try {
                        Stopwatch stopwatch = Stopwatch()..start();
                        final result = await classifyRiceImage(base64Image);

                        setState(() {
                          _resultString = parseResultsIntoString(result);
                          _resultDict = result;
                          _latency =
                              stopwatch.elapsed.inMilliseconds.toString();
                          isClassifying = false;
                        });
                      } catch (e) {
                        setState(() {
                          isClassifying = false;
                        });
                        // Handle error
                      }
                    },
              child: isClassifying
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : const Text('🌊 Classify!'),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
