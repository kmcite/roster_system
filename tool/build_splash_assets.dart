import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

/// Builds rounded splash icon + full-screen splash backgrounds.
void main() {
  final iconSrc = File('assets/branding/app_icon.jpg');
  if (!iconSrc.existsSync()) {
    stderr.writeln('Missing ${iconSrc.path}');
    exit(1);
  }

  final raw = img.decodeImage(iconSrc.readAsBytesSync());
  if (raw == null) {
    stderr.writeln('Could not decode app icon');
    exit(1);
  }

  final square = img.copyResizeCropSquare(raw, size: 1024);
  const cornerRadius = 220.0;
  final rounded = _applyRoundedCorners(square, cornerRadius);

  final iconOut = File('assets/branding/splash_icon_rounded.png');
  iconOut.writeAsBytesSync(img.encodePng(rounded));
  stdout.writeln('Wrote ${iconOut.path}');

  _writeFullSplash(
    rounded,
    out: File('assets/branding/splash_full_light.png'),
    colors: [
      img.ColorRgb8(207, 224, 255),
      img.ColorRgb8(230, 222, 255),
      img.ColorRgb8(208, 240, 232),
      img.ColorRgb8(232, 240, 255),
    ],
  );

  _writeFullSplash(
    rounded,
    out: File('assets/branding/splash_full_dark.png'),
    colors: [
      img.ColorRgb8(10, 14, 20),
      img.ColorRgb8(20, 32, 54),
      img.ColorRgb8(14, 26, 40),
      img.ColorRgb8(16, 22, 40),
    ],
    iconGlow: img.ColorRgb8(126, 180, 255),
  );

  stdout.writeln('Splash assets ready — run: dart run flutter_native_splash:create');
}

img.Image _applyRoundedCorners(img.Image source, double radius) {
  final out = img.Image.from(source);
  final w = out.width;
  final h = out.height;

  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      if (!_insideRoundedRect(x.toDouble(), y.toDouble(), w.toDouble(), h.toDouble(), radius)) {
        out.setPixelRgba(x, y, 0, 0, 0, 0);
      }
    }
  }
  return out;
}

bool _insideRoundedRect(double x, double y, double w, double h, double r) {
  if (x >= r && x <= w - r) return y >= 0 && y <= h;
  if (y >= r && y <= h - r) return x >= 0 && x <= w;

  final corners = [
    (r, r),
    (w - r, r),
    (r, h - r),
    (w - r, h - r),
  ];
  for (final (cx, cy) in corners) {
    final inQuarter = (x <= r || x >= w - r) && (y <= r || y >= h - r);
    if (!inQuarter) continue;
    final dx = x - cx;
    final dy = y - cy;
    if (dx * dx + dy * dy <= r * r) return true;
  }
  return false;
}

void _writeFullSplash(
  img.Image icon, {
  required File out,
  required List<img.Color> colors,
  img.Color? iconGlow,
}) {
  const width = 1080;
  const height = 2340;
  final canvas = img.Image(width: width, height: height);

  for (var y = 0; y < height; y++) {
    final t = y / (height - 1);
    final c = _lerpGradient(colors, t);
    for (var x = 0; x < width; x++) {
      canvas.setPixel(x, y, c);
    }
  }

  const target = 520;
  final scaled = img.copyResize(icon, width: target, height: target, interpolation: img.Interpolation.cubic);

  if (iconGlow != null) {
    final glow = img.Image.from(scaled);
    for (var y = 0; y < glow.height; y++) {
      for (var x = 0; x < glow.width; x++) {
        final p = glow.getPixel(x, y);
        if (p.a > 0) {
          glow.setPixel(
            x,
            y,
            img.ColorRgba8(
              iconGlow.r.toInt(),
              iconGlow.g.toInt(),
              iconGlow.b.toInt(),
              (p.a * 0.35).round(),
            ),
          );
        }
      }
    }
    img.compositeImage(
      canvas,
      img.gaussianBlur(glow, radius: 28),
      dstX: (width - target) ~/ 2,
      dstY: (height - target) ~/ 2 - 40,
    );
  }

  final left = (width - target) ~/ 2;
  final top = (height - target) ~/ 2 - 40;
  img.compositeImage(canvas, scaled, dstX: left, dstY: top);

  out.writeAsBytesSync(img.encodePng(canvas));
  stdout.writeln('Wrote ${out.path}');
}

img.Color _lerpGradient(List<img.Color> colors, double t) {
  if (colors.length == 1) return colors.first;
  final segments = colors.length - 1;
  final pos = (t * segments).clamp(0, segments.toDouble() - 0.0001);
  final i = pos.floor();
  final localT = (pos - i).toDouble();
  final a = colors[i];
  final b = colors[math.min(i + 1, colors.length - 1)];
  return img.ColorRgb8(
    _lerpInt(a.r.toInt(), b.r.toInt(), localT),
    _lerpInt(a.g.toInt(), b.g.toInt(), localT),
    _lerpInt(a.b.toInt(), b.b.toInt(), localT),
  );
}

int _lerpInt(int a, int b, double t) => (a + (b - a) * t).round();
