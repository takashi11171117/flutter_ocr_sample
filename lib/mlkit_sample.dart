import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class MlkitSample extends StatefulWidget {
  const MlkitSample({super.key});

  @override
  MlkitSampleState createState() => MlkitSampleState();
}

class MlkitSampleState extends State<MlkitSample> {
  final textRecognizer = TextRecognizer(script: TextRecognitionScript.japanese);
  String detectedText = '';
  final picker = ImagePicker();
  String path = "";
  bool loading = false;

  @override
  void dispose() {
    textRecognizer.close();
    super.dispose();
  }

  Future<void> detectTextFromImagePicker() async {
    loading = true;
    setState(() {});

    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage == null) return; // If user cancels the image picker

    final inputImage = InputImage.fromFilePath(pickedImage.path);
    path = pickedImage.path;

    final recognisedText = await textRecognizer.processImage(inputImage);
    detectedText = recognisedText.text;

    loading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mlkit デモ')),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
                child: ListView(
              children: [
                path.isEmpty ? Container() : Image.file(File(path)),
                loading
                    ? const Column(children: [CircularProgressIndicator()])
                    : Text(
                        detectedText,
                      ),
              ],
            ))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: detectTextFromImagePicker,
        tooltip: 'OCR',
        child: const Icon(Icons.add),
      ),
    );
  }
}
