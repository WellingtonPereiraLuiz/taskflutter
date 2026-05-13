// tool/generate_icon.dart
// Run with: dart run tool/generate_icon.dart
//
// Generates assets/icon/app_icon.png — a 512x512 PNG with:
//   • Background: #0B0F19 (GritTracker dark navy)
//   • Centered rounded square accent: #38BDF8 (sky blue)
//   • Letter "G" rendered via pixel blocks

import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  const size = 512;
  final bg = img.ColorRgb8(11, 15, 25);       // #0B0F19
  final accent = img.ColorRgb8(56, 189, 248);  // #38BDF8
  final white = img.ColorRgb8(255, 255, 255);  // #FFFFFF

  final image = img.Image(width: size, height: size);
  img.fill(image, color: bg);

  // Draw rounded accent square in centre
  const squareSize = 320;
  const squareOffset = (size - squareSize) ~/ 2;
  const radius = 64;
  _drawRoundedRect(image, squareOffset, squareOffset, squareSize, squareSize, radius, accent);

  // Draw letter "G" using thick lines
  const cx = size ~/ 2;
  const cy = size ~/ 2;
  const letterR = 100;
  const thickness = 28;

  // Draw arc (top-left going around clockwise ~270 degrees)
  for (double angle = 30; angle <= 360; angle += 0.5) {
    final rad = angle * 3.14159265 / 180;
    final x = cx + (letterR * _cos(rad)).round();
    final y = cy + (letterR * _sin(rad)).round();
    _fillCircle(image, x, y, thickness ~/ 2, white);
  }

  // Horizontal arm going left from middle-right
  for (int x = cx; x <= cx + letterR; x++) {
    _fillCircle(image, x, cy, thickness ~/ 2, white);
  }

  // Vertical arm going down from middle-right
  for (int y = cy - thickness ~/ 2; y <= cy + letterR ~/ 2; y++) {
    _fillCircle(image, cx + letterR, y, thickness ~/ 2, white);
  }

  // Erase inner arc to make it hollow
  const innerR = letterR - thickness;
  for (double angle = 0; angle <= 360; angle += 0.5) {
    final rad = angle * 3.14159265 / 180;
    final x = cx + (innerR * _cos(rad)).round();
    final y = cy + (innerR * _sin(rad)).round();
    _fillCircle(image, x, y, thickness ~/ 2 - 4, accent);
  }

  final outputFile = File('assets/icon/app_icon.png');
  outputFile.writeAsBytesSync(img.encodePng(image));
  print('✅ Icon generated at: ${outputFile.path}');
}

double _cos(double rad) => _cosImpl(rad);
double _sin(double rad) => _sinImpl(rad);

double _cosImpl(double rad) {
  // Taylor series approximation — good enough
  double x = rad;
  x = x % (2 * 3.14159265);
  return 1 -
      (x * x) / 2 +
      (x * x * x * x) / 24 -
      (x * x * x * x * x * x) / 720;
}

double _sinImpl(double rad) {
  double x = rad;
  x = x % (2 * 3.14159265);
  return x -
      (x * x * x) / 6 +
      (x * x * x * x * x) / 120 -
      (x * x * x * x * x * x * x) / 5040;
}

void _fillCircle(img.Image image, int cx, int cy, int r, img.Color color) {
  for (int y = cy - r; y <= cy + r; y++) {
    for (int x = cx - r; x <= cx + r; x++) {
      final dx = x - cx;
      final dy = y - cy;
      if (dx * dx + dy * dy <= r * r) {
        if (x >= 0 && x < image.width && y >= 0 && y < image.height) {
          image.setPixel(x, y, color);
        }
      }
    }
  }
}

void _drawRoundedRect(
    img.Image image, int x, int y, int w, int h, int r, img.Color color) {
  // Fill interior rectangles
  img.fillRect(image,
      x1: x + r, y1: y, x2: x + w - r, y2: y + h, color: color);
  img.fillRect(image,
      x1: x, y1: y + r, x2: x + w, y2: y + h - r, color: color);
  // Fill corners with circles
  _fillCircle(image, x + r, y + r, r, color);
  _fillCircle(image, x + w - r, y + r, r, color);
  _fillCircle(image, x + r, y + h - r, r, color);
  _fillCircle(image, x + w - r, y + h - r, r, color);
}
