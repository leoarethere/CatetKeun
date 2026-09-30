import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:catat_keuangan/views/widgets/app_logo.dart';

/// Invariant geometri [AppLogo].
///
/// [AppLogo] memperbesar `icon_foreground.png` (1024x1024, transparan) lalu
/// memotong bagian transparannya. Kalau atauannya salah, bagian logo yang
/// solid ikut terpotong — test di bawah itu mencegahnya.
void main() {
  group('Geometri AppLogo', () {
    // Bounding box logo solid (alpha >= 250) di dalam kanvas 1024x1024.
    const solidLeft = 272.0;
    const solidRight = 810.0;
    const solidTop = 229.0;
    const solidBottom = 811.0;

    test('perbesar tidak memotong bagian logo yang solid', () {
      const canvas = 1024.0;
      final z = AppLogo.zoomForTesting;

      double scaledMin(double v) => canvas / 2 + (v - canvas / 2) * z;
      double scaledMax(double v) => canvas / 2 + (v - canvas / 2) * z;

      final left = scaledMin(solidLeft);
      final right = scaledMax(solidRight);
      final top = scaledMin(solidTop);
      final bottom = scaledMax(solidBottom);

      expect(left, greaterThanOrEqualTo(0),
          reason: 'sisi kiri logo solid terpotong');
      expect(top, greaterThanOrEqualTo(0),
          reason: 'sisi atas logo solid terpotong');
      expect(right, lessThanOrEqualTo(canvas),
          reason: 'sisi kanan logo solid terpotong');
      expect(bottom, lessThanOrEqualTo(canvas),
          reason: 'sisi bawah logo solid terpotong');
    });

    test('logo solid tidak lebih kecil dari 80% kanvas setelah diperbesar',
        () {
      final z = AppLogo.zoomForTesting;
      final solidWidth = (solidRight - solidLeft) * z;
      final solidHeight = (solidBottom - solidTop) * z;

      // Sisi terpendek menentukan填isian; pastikan tidak terlalu kecil.
      expect(solidWidth / 1024, greaterThan(0.8));
      expect(solidHeight / 1024, greaterThan(0.8));
    });

    test('warna latar sama dengan adaptive_icon_background di pubspec', () {
      // pubspec: adaptive_icon_background: "#00796B"
      expect(AppLogo.brandColor, const Color(0xFF00796B));
    });
  });

  group('Render AppLogo', () {
    for (final size in [16.0, 20.0, 26.0, 40.0, 88.0]) {
      testWidgets('tanpa overflow pada size $size', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: AppLogo(size: size),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(AppLogo), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('seperti di About: logo besar + nama aplikasi', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppLogo(size: 88),
                  SizedBox(height: 12),
                  Text('CatetKeun'),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
