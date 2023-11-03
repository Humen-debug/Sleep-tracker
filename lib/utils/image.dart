import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:image/image.dart' as image;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

Future<ui.Image>? loadImage(String svgString, double size) async {
  PictureInfo pictureInfo = await vg.loadPicture(SvgStringLoader(svgString), null, clipViewbox: false);

  ui.Picture? picture = pictureInfo.picture;

  ui.Image? image = await picture.toImage(size.toInt(), size.toInt());

  return image;
}

Future<ui.Image?> loadAssetImage(String assetPath, double size) async {
  final ByteData assetImageByteData = await rootBundle.load(assetPath);
  image.Image? baseSizeImage = image.decodeImage(assetImageByteData.buffer.asUint8List());
  if (baseSizeImage == null) return null;
  image.Image? resizeImage = image.copyResize(baseSizeImage,
      height: size.toInt(), width: size.toInt(), interpolation: image.Interpolation.average);
  ui.Codec codec = await ui.instantiateImageCodec(image.encodePng(resizeImage));
  ui.FrameInfo frameInfo = await codec.getNextFrame();
  return frameInfo.image;
}

double degreeToRadian(double degree) {
  return degree * math.pi / 180;
}

ui.Image rotatedImage(double radian, ui.Image image, {double? scale}) {
  var pictureRecorder = ui.PictureRecorder();
  Canvas canvas = Canvas(pictureRecorder);
  final double r = math.sqrt(image.width * image.width + image.height * image.height) / 2;
  final alpha = math.atan(image.height / image.width);

  final gama = alpha + radian;
  final shiftY = r * math.sin(gama);
  final shiftX = r * math.cos(gama);
  final translateX = image.width / 2 - shiftX;
  final translateY = image.height / 2 - shiftY;
  canvas.save();

  canvas.translate(translateX, translateY);
  canvas.rotate(radian);
  final size = math.max(image.width.toDouble(), r);

  paintImage(
    canvas: canvas,
    fit: BoxFit.contain,
    rect: Rect.fromCenter(
      center: Offset(image.width / 2, image.height / 2),
      width: size,
      height: size,
    ),
    image: image,
    filterQuality: FilterQuality.high,
  );

  canvas.restore();
  return pictureRecorder.endRecording().toImageSync(image.width, image.height);
}
