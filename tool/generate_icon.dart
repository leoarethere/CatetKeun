import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('generate CatetKeun professional app icon', () async {
    // 1. Generate Full Icon (for iOS, Windows, macOS, Web, Linux)
    final fullBytes = await _renderIcon(isForegroundOnly: false);
    final fullFile = File('assets/icon/icon.png');
    await fullFile.parent.create(recursive: true);
    await fullFile.writeAsBytes(fullBytes);

    // Salin juga ke webp agar backward-compatible
    final webpFile = File('assets/icon/icon.webp');
    await webpFile.writeAsBytes(fullBytes);

    // Salin juga ke Linux runner
    final linuxIcon = File('linux/runner/resources/app_icon.png');
    if (await linuxIcon.exists()) {
      await linuxIcon.writeAsBytes(fullBytes);
    }

    // 2. Generate Adaptive Foreground Icon (for Android adaptive icons)
    final fgBytes = await _renderIcon(isForegroundOnly: true);
    final fgFile = File('assets/icon/icon_foreground.png');
    await fgFile.writeAsBytes(fgBytes);

    // ignore: avoid_print
    print('Icons successfully generated!');
    // ignore: avoid_print
    print('  - Full icon: ${fullFile.path} (${fullBytes.length} bytes)');
    // ignore: avoid_print
    print('  - WebP icon: ${webpFile.path} (${fullBytes.length} bytes)');
    // ignore: avoid_print
    print('  - Android Foreground: ${fgFile.path} (${fgBytes.length} bytes)');
  });
}

Future<List<int>> _renderIcon({required bool isForegroundOnly}) async {
  const size = 1024.0;
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, size, size));

  if (!isForegroundOnly) {
    // -------------------------------------------------------------------------
    // 1. BACKGROUND SQUIRCLE / BASE
    // -------------------------------------------------------------------------
    final bgRect = const Rect.fromLTWH(0, 0, size, size);
    
    // Background gradient: Rich deep teal (#004D40) to vibrant teal (#00897B)
    final bgPaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(100, 50),
        const Offset(900, 950),
        [
          const Color(0xFF00897B), // Vibrant Teal
          const Color(0xFF00695C), // Teal 800
          const Color(0xFF004D40), // Deep Forest Teal
        ],
        [0.0, 0.55, 1.0],
      );
    
    // Smooth rounded square
    final bgRRect = RRect.fromRectAndRadius(bgRect, const Radius.circular(220));
    canvas.drawRRect(bgRRect, bgPaint);

    // Subtle ambient lighting overlay (radial glow from top-left)
    final glowPaint = Paint()
      ..shader = ui.Gradient.radial(
        const Offset(250, 220),
        480,
        [
          Colors.white.withValues(alpha: 0.18),
          Colors.white.withValues(alpha: 0.0),
        ],
      );
    canvas.drawRRect(bgRRect, glowPaint);

    // Subtle inner stroke highlight
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..color = Colors.white.withValues(alpha: 0.15);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(2, 2, size - 4, size - 4),
        const Radius.circular(218),
      ),
      strokePaint,
    );
  }

  // -------------------------------------------------------------------------
  // 2. MAIN EMBLEM: MODERN FINANCIAL LEDGER NOTEBOOK + GOLDEN COIN & GRAPH
  // -------------------------------------------------------------------------
  // Safe zone center: (512, 512)
  canvas.save();
  // Safe scale to fit comfortably within Android adaptive icon circle (66% safe zone = ~680px diameter)
  // Center of canvas
  canvas.translate(512, 512);

  // --- DROP SHADOW FOR THE NOTEBOOK ---
  final shadowPath = Path()
    ..addRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: const Offset(-20, 16), width: 440, height: 530),
      const Radius.circular(42),
    ));
  canvas.drawShadow(shadowPath, const Color(0xFF001F18), 36, true);

  // --- NOTEBOOK BODY ---
  final noteRect = Rect.fromCenter(center: const Offset(-20, 0), width: 440, height: 530);
  final noteRRect = RRect.fromRectAndRadius(noteRect, const Radius.circular(42));
  
  final notePaint = Paint()
    ..shader = ui.Gradient.linear(
      noteRect.topCenter,
      noteRect.bottomCenter,
      [
        const Color(0xFFFFFFFF),
        const Color(0xFFF8FAFC),
        const Color(0xFFEFF6FF),
      ],
      [0.0, 0.6, 1.0],
    );
  canvas.drawRRect(noteRRect, notePaint);

  // --- NOTEBOOK BINDING / LEFT SPINE ---
  final spineRect = Rect.fromLTWH(noteRect.left, noteRect.top, 50, noteRect.height);
  final spineRRect = RRect.fromRectAndCorners(
    spineRect,
    topLeft: const Radius.circular(42),
    bottomLeft: const Radius.circular(42),
  );
  final spinePaint = Paint()
    ..shader = ui.Gradient.linear(
      spineRect.topCenter,
      spineRect.bottomCenter,
      [
        const Color(0xFF004D40),
        const Color(0xFF00796B),
      ],
    );
  canvas.drawRRect(spineRRect, spinePaint);

  // Spine stitches/rings (3 small pill holes)
  final ringPaint = Paint()..color = Colors.white.withValues(alpha: 0.85);
  for (int i = 0; i < 3; i++) {
    final y = noteRect.top + 130 + (i * 135.0);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(noteRect.left + 25, y), width: 14, height: 26),
        const Radius.circular(7),
      ),
      ringPaint,
    );
  }

  // --- TOP HEADER BANNER ON THE NOTE ---
  final bannerRect = Rect.fromLTWH(
    noteRect.left + 50,
    noteRect.top,
    noteRect.width - 50,
    90,
  );
  final bannerRRect = RRect.fromRectAndCorners(
    bannerRect,
    topRight: const Radius.circular(42),
  );
  final bannerPaint = Paint()
    ..shader = ui.Gradient.linear(
      bannerRect.centerLeft,
      bannerRect.centerRight,
      [
        const Color(0xFF00796B),
        const Color(0xFF00897B),
      ],
    );
  canvas.drawRRect(bannerRRect, bannerPaint);

  // Header decorative pill (Wallet/Card slot visual)
  final slotPaint = Paint()..color = Colors.white.withValues(alpha: 0.35);
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(bannerRect.center.dx - 10, bannerRect.center.dy),
        width: 140,
        height: 14,
      ),
      const Radius.circular(7),
    ),
    slotPaint,
  );

  // --- TRANSACTION DATA ROWS / LINES ---
  final line1Paint = Paint()..color = const Color(0xFF334155); // Slate 700
  final line2Paint = Paint()..color = const Color(0xFF64748B); // Slate 500
  final line3Paint = Paint()..color = const Color(0xFF94A3B8); // Slate 400

  // Row 1: dot + bar
  final dotPaint1 = Paint()..color = const Color(0xFF10B981); // Emerald green for income
  canvas.drawCircle(Offset(noteRect.left + 85, noteRect.top + 140), 9, dotPaint1);
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(noteRect.left + 110, noteRect.top + 132, 190, 16),
      const Radius.circular(8),
    ),
    line1Paint,
  );

  // Row 2: dot + bar
  final dotPaint2 = Paint()..color = const Color(0xFFEF4444); // Red for expense
  canvas.drawCircle(Offset(noteRect.left + 85, noteRect.top + 185), 9, dotPaint2);
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(noteRect.left + 110, noteRect.top + 177, 150, 16),
      const Radius.circular(8),
    ),
    line2Paint,
  );

  // Row 3: dot + bar
  final dotPaint3 = Paint()..color = const Color(0xFF0EA5E9); // Sky blue
  canvas.drawCircle(Offset(noteRect.left + 85, noteRect.top + 230), 9, dotPaint3);
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(noteRect.left + 110, noteRect.top + 222, 120, 16),
      const Radius.circular(8),
    ),
    line3Paint,
  );

  // --- FINANCIAL TREND CHART INSIDE NOTEBOOK ---
  // A sleek 3-bar chart representing budgeting & financial growth
  final barX = noteRect.left + 85;
  final barBaseY = noteRect.top + 430;

  final barColors = [
    const Color(0xFF99F6E4), // Mint light
    const Color(0xFF2DD4BF), // Teal medium
    const Color(0xFF0D9488), // Teal strong
  ];
  final barHeights = [70.0, 110.0, 155.0];

  for (int i = 0; i < 3; i++) {
    final x = barX + (i * 44.0);
    final h = barHeights[i];
    final bPaint = Paint()..color = barColors[i];
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(x, barBaseY - h, 28, h),
        topLeft: const Radius.circular(8),
        topRight: const Radius.circular(8),
      ),
      bPaint,
    );
  }

  // Trend upward curve line over bars
  final trendPath = Path();
  trendPath.moveTo(barX + 14, barBaseY - 80);
  trendPath.quadraticBezierTo(
    barX + 58,
    barBaseY - 120,
    barX + 102,
    barBaseY - 180,
  );
  final trendPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 6
    ..strokeCap = StrokeCap.round
    ..color = const Color(0xFF0F766E);
  canvas.drawPath(trendPath, trendPaint);

  // Small trend dot at apex
  canvas.drawCircle(Offset(barX + 102, barBaseY - 180), 7, Paint()..color = const Color(0xFF0F766E));

  // --- RIBBON BOOKMARK EXTENDING FROM TOP ---
  final ribbonPath = Path();
  final rLeft = noteRect.left + 230.0;
  final rWidth = 44.0;
  final rTop = noteRect.top - 18.0;
  final rBottom = noteRect.top + 75.0;
  ribbonPath.moveTo(rLeft, rTop);
  ribbonPath.lineTo(rLeft + rWidth, rTop);
  ribbonPath.lineTo(rLeft + rWidth, rBottom);
  ribbonPath.lineTo(rLeft + (rWidth / 2), rBottom - 16);
  ribbonPath.lineTo(rLeft, rBottom);
  ribbonPath.close();

  final ribbonPaint = Paint()
    ..shader = ui.Gradient.linear(
      Offset(rLeft, rTop),
      Offset(rLeft + rWidth, rBottom),
      [
        const Color(0xFFF59E0B), // Amber 500
        const Color(0xFFD97706), // Amber 600
      ],
    );
  canvas.drawPath(ribbonPath, ribbonPaint);

  // -------------------------------------------------------------------------
  // 3. OVERLAPPING GOLDEN WEALTH COIN WITH GROWTH ARROW & "Rp" EMBLEM
  // -------------------------------------------------------------------------
  final coinCenter = const Offset(155, 155);
  const coinRadius = 145.0;

  // Coin drop shadow
  final coinShadowPath = Path()
    ..addOval(Rect.fromCircle(center: coinCenter + const Offset(-6, 16), radius: coinRadius));
  canvas.drawShadow(coinShadowPath, const Color(0xFF00150F), 32, true);

  // Coin outer rim (rich metallic gold gradient)
  final coinRimPaint = Paint()
    ..shader = ui.Gradient.linear(
      coinCenter + const Offset(-coinRadius, -coinRadius),
      coinCenter + const Offset(coinRadius, coinRadius),
      [
        const Color(0xFFFFFBEB), // Glistening light gold
        const Color(0xFFFBBF24), // Bright gold
        const Color(0xFFD97706), // Deep rich gold
        const Color(0xFFB45309), // Bronze shadow
      ],
      [0.0, 0.35, 0.75, 1.0],
    );
  canvas.drawCircle(coinCenter, coinRadius, coinRimPaint);

  // Coin inner circle
  final innerRadius = coinRadius - 16;
  final coinInnerPaint = Paint()
    ..shader = ui.Gradient.radial(
      coinCenter + const Offset(-20, -25),
      innerRadius * 1.3,
      [
        const Color(0xFFFDE68A), // Light radiant gold
        const Color(0xFFF59E0B), // Warm amber gold
        const Color(0xFFD97706), // Deep amber gold
      ],
      [0.0, 0.6, 1.0],
    );
  canvas.drawCircle(coinCenter, innerRadius, coinInnerPaint);

  // Coin engraved inner ring line
  final innerRingPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3.5
    ..color = const Color(0xFFFBBF24).withValues(alpha: 0.9);
  canvas.drawCircle(coinCenter, innerRadius - 12, innerRingPaint);

  // --- EMBLEM ON COIN: MODERN FINANCIAL GROWTH ARROW + "Rp" ---
  // Let's draw an elegant upward financial arrow (↗) with dynamic bar
  final arrowPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 16
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..color = const Color(0xFFFFFFFF);

  // Upward Arrow Path
  final arrowPath = Path();
  // Line from bottom-left to top-right of coin
  arrowPath.moveTo(coinCenter.dx - 45, coinCenter.dy + 45);
  arrowPath.lineTo(coinCenter.dx + 40, coinCenter.dy - 40);
  // Arrow head
  arrowPath.moveTo(coinCenter.dx - 2, coinCenter.dy - 40);
  arrowPath.lineTo(coinCenter.dx + 40, coinCenter.dy - 40);
  arrowPath.lineTo(coinCenter.dx + 40, coinCenter.dy + 2);

  // Arrow drop shadow inside coin for embossed look
  final arrowShadowPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 16
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..color = const Color(0xFF92400E).withValues(alpha: 0.45);
  canvas.drawPath(arrowPath.shift(const Offset(0, 3)), arrowShadowPaint);
  canvas.drawPath(arrowPath, arrowPaint);

  // Small sparkles / star shine on coin edge (top-right)
  final sparkleCenter = coinCenter + const Offset(70, -70);
  final sparklePaint = Paint()..color = Colors.white.withValues(alpha: 0.95);
  
  // 4-point sparkle star
  final starPath = Path();
  const starR = 24.0;
  const innerR = 6.0;
  for (int i = 0; i < 8; i++) {
    final r = i.isEven ? starR : innerR;
    final angle = i * math.pi / 4;
    final px = sparkleCenter.dx + r * math.cos(angle);
    final py = sparkleCenter.dy + r * math.sin(angle);
    if (i == 0) {
      starPath.moveTo(px, py);
    } else {
      starPath.lineTo(px, py);
    }
  }
  starPath.close();
  canvas.drawPath(starPath, sparklePaint);

  canvas.restore();

  // Convert to image
  final picture = recorder.endRecording();
  final image = await picture.toImage(size.toInt(), size.toInt());
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}
