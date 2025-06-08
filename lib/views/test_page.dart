import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:pointycastle/pointycastle.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  final boxWidth = 400.0;
  final boxHeight = 400.0;

  img.Image? currentImage;

  @override
  Widget build(BuildContext context) {
    Uint8List? imageBytes =
        currentImage != null
            ? Uint8List.fromList(img.encodePng(currentImage!))
            : null;

    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: boxWidth,
              height: boxHeight,
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(20),
              ),
              child:
                  imageBytes != null
                      ? Image.memory(imageBytes, fit: BoxFit.cover)
                      : const Center(child: Text('No image generated yet')),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _generateImage,
              child: const Text('Generate'),
            ),
            FilledButton(
              onPressed: () {
                if (currentImage == null) return;
                final scrambled = scrambleImage(currentImage!, 'ciao');
                setState(() {
                  currentImage = scrambled;
                });
              },
              child: const Text('Encrypt/Decrypt'),
            ),
          ],
        ),
      ),
    );
  }

  void _generateImage() {
    final width = 400;
    final height = 400;
    final image = img.Image(width: width, height: height);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        image.setPixelRgba(x, y, x, 0, 0, 255);
      }
    }

    setState(() {
      currentImage = image;
    });
  }

  img.Image scrambleImage(img.Image original, String password) {
    final key = sha256.convert(utf8.encode(password)).bytes;
    final iv = Uint8List.fromList(List.generate(16, (i) => i));

    final pixels = original.toUint8List();
    final cipher = StreamCipher('AES/CTR')
      ..init(true, ParametersWithIV(KeyParameter(Uint8List.fromList(key)), iv));

    final scrambled = cipher.process(pixels);

    final width = original.width;
    final height = original.height;

    final bytesPerPixel =
        pixels.length ~/ (original.width * original.height); // likely 3 or 4
    final scrambledImage = img.Image(width: width, height: height);

    for (int i = 0; i < width * height; i++) {
      int base = i * bytesPerPixel;

      // For RGB (3 bytes)
      if (bytesPerPixel == 3) {
        scrambledImage.setPixelRgba(
          i % width,
          i ~/ width,
          scrambled[base],
          scrambled[base + 1],
          scrambled[base + 2],
          255,
        );
      } else if (bytesPerPixel == 4) {
        scrambledImage.setPixelRgba(
          i % width,
          i ~/ width,
          scrambled[base],
          scrambled[base + 1],
          scrambled[base + 2],
          scrambled[base + 3],
        );
      }
    }

    return scrambledImage;
  }
}
