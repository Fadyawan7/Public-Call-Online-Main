// marker_utils.dart
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Data model for compute()
class MarkerImageParams {
  final String imageUrl;
  final String status;

  MarkerImageParams({required this.imageUrl, required this.status});
}

/// compute() will call this
Future<Uint8List> createMarkerIsolate(MarkerImageParams params) async {
  return await createBorderedMarkerFromUrl(
    params.imageUrl,
    currentStatus: params.status,
  );
}

/// This returns Uint8List — compute-friendly
Future<Uint8List> createBorderedMarkerFromUrl(
  String imageUrl, {
  double size = 80,
  double borderSize = 6,
  String currentStatus = 'available',
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final paint = Paint();

  final radius = size / 2;

  final borderColor = (currentStatus.trim().toLowerCase() == 'available')
      ? Colors.green
      : Colors.red;

  paint.color = borderColor;
  canvas.drawCircle(Offset(radius, radius), radius, paint);

  paint.color = Colors.white;
  canvas.drawCircle(Offset(radius, radius), radius - borderSize, paint);

  // fetch image bytes
  final Uint8List imgBytes = await fetchNetworkImageBytes(imageUrl);
  final ui.Codec codec = await ui.instantiateImageCodec(imgBytes);
  final ui.FrameInfo frameInfo = await codec.getNextFrame();
  final ui.Image image = frameInfo.image;

  canvas.clipPath(Path()
    ..addOval(Rect.fromCircle(
      center: Offset(radius, radius),
      radius: radius - borderSize,
    )));

  canvas.drawImageRect(
    image,
    Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
    Rect.fromLTWH(
      borderSize,
      borderSize,
      size - borderSize * 2,
      size - borderSize * 2,
    ),
    paint,
  );

  final picture = recorder.endRecording();
  final img = await picture.toImage(size.toInt(), size.toInt());
  final bytes = await img.toByteData(format: ui.ImageByteFormat.png);

  return bytes!.buffer.asUint8List();
}

Future<Uint8List> fetchNetworkImageBytes(String url) async {
  final http.Response response = await http.get(Uri.parse(url));
  return response.bodyBytes;
}
