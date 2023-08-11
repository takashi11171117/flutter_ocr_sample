import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class TesseractOcrSample extends StatefulWidget {
  const TesseractOcrSample({Key? key}) : super(key: key);

  @override
  TesseractOcrSampleState createState() => TesseractOcrSampleState();
}

class TesseractOcrSampleState extends State<TesseractOcrSample> {
  String _ocrText = '';
  List<String> langList = ["jpn", "eng"];
  List<String> selectList = ["eng", "jpn"];
  String path = "";
  bool loading = false;

  void runFilePiker() async {
    final pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _ocr(pickedFile.path);
    }
  }

  void _ocr(url) async {
    if (selectList.isEmpty) {
      print("Please select language");
      return;
    }

    loading = true;
    setState(() {});

    img.Image? image = img.decodeImage(File(url).readAsBytesSync());
    if (image == null) return;

    final newPath = convertBinaryColor(image, url);

    path = newPath;
    String langs = selectList.join("+");

    _ocrText =
        await FlutterTesseractOcr.extractText(path, language: langs, args: {
      "preserve_interword_spaces": "1",
    });

    loading = false;
    setState(() {});
  }

  String convertBinaryColor(img.Image image, String path) {
    for (var x = 0; x < image.width; x++) {
      for (var y = 0; y < image.height; y++) {
        var pixel = image.getPixelSafe(x, y);

        num red = pixel.r;
        num green = pixel.g;
        num blue = pixel.b;

        num luma = 0.25 * red + 0.55 * green + 0.15 * blue;

        int binaryColor = luma < 150 ? 0 : 255;

        image.setPixelRgba(x, y, binaryColor, binaryColor, binaryColor, 255);
      }
    }
    String bwPath = p.join(p.dirname(path), "bw_${p.basename(path)}");
    File(bwPath).writeAsBytesSync(img.encodePng(image));

    return bwPath;
  }

  Future<String> convertGrayScale(img.Image image, String path) async {
    var grayscale = img.grayscale(image);

    final tempDir = await getTemporaryDirectory();
    final grayPath = '${tempDir.path}/grayscale.png';
    final grayFile = File(grayPath);
    await grayFile.writeAsBytes(img.encodePng(grayscale));

    return grayPath;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TesseractOcr デモ'),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Row(
                  children: [
                    ...langList.map((lang) {
                      return Row(children: [
                        Checkbox(
                            value: selectList.contains(lang),
                            onChanged: (v) async {
                              if (!selectList.contains(lang)) {
                                selectList.add(lang);
                              } else {
                                selectList.remove(lang);
                              }
                              setState(() {});
                            }),
                        Text(lang)
                      ]);
                    }).toList(),
                  ],
                ),
                Expanded(
                    child: ListView(
                  children: [
                    path.isEmpty ? Container() : Image.file(File(path)),
                    loading
                        ? const Column(children: [CircularProgressIndicator()])
                        : Text(
                            _ocrText,
                          ),
                  ],
                ))
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          runFilePiker();
          // _ocr("");
        },
        tooltip: 'OCR',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
