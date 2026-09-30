import 'package:flutter/material.dart';

/// Logo aplikasi untuk dipakai seragam di seluruh antarmuka.
///
/// Menggunaikan [iconForeground] — layer foreground adaptive icon yang sama
/// dengan yang dipakai untuk ikon launcher Android — lalu diletakkan di atas
/// latar brand [#brandColor] dengan perbandingan yang benar. Hasilnya identik
/// dengan ikon yang terlihat di layar utama, hanya saja bisa memakai bentuk
/// dan ukuran sendiri sesuai konteks (lingkaran di AppBar, kotak tumpul di
/// kartu, dan seterusnya).
///
/// Aset `icon_foreground.png` berukuran 1024x1024 dan bersifat transparan.
/// Logo di dalamnya **tidak** mengisi seluruh kanvas: berdasarkan alpha
/// channel, area yang benar-benar berisi logo adalah
/// x 272..811 dan y 229..811. Karena itu [Image.asset] tidak boleh
/// langsung dipasang ke kotak ber-[size]; logo akan terlihat kecil dan
/// tidak CENTER. Widget ini memperbaikinya dengan memperbesar gambar lalu
/// memotong bagian transparannya.
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 28,
    this.borderRadius,
  });

  /// Ukuran sisi kotak logo (logical pixel).
  final double size;

  /// Bentuk sudut kotak. Default-nya mengikuti Material 3 (28% dari sisi).
  final BorderRadius? borderRadius;

  /// Warna latar brand, sama dengan `adaptive_icon_background` di pubspec.
  static const Color brandColor = Color(0xFF00796B);

  /// Aset foreground adaptive icon.
  static const String _assetPath = 'assets/icon/icon_foreground.png';

  /// Porsi kanvas 1024x1024 yang benar-benar terisi logo (lihat docs kelas).
  static const double _sourceLogoWidth = 539 / 1024; // 0.5264
  static const double _sourceLogoHeight = 583 / 1024; // 0.5693

  /// Berapa bagian dari kotak yang boleh dipakai logo setelah diperbesar.
  /// Dipakai nilai terkecil dari kedua sisi supaya bagian atas/bawah tidak
  /// ikut terpotong.
  static const double _targetFill = 0.86;

  static double get _zoom => _targetFill /
      (_sourceLogoWidth < _sourceLogoHeight
          ? _sourceLogoWidth
          : _sourceLogoHeight);

  /// Faktor pembesar yang dipakai widget. Diekspos agar invariant geometri
  /// (logo solid tidak terpotong) bisa diuji di [app_logo_test.dart].
  @visibleForTesting
  static double get zoomForTesting => _zoom;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(size * 0.28);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: brandColor,
        borderRadius: radius,
      ),
      // clip + DecoratedBox: dipakai ClipRRect agar gambar ikut terpotong
      // mengikuti rounded border.
      clipBehavior: Clip.antiAlias,
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: size,
          height: size,
          // Perbesar supaya bagian logo memenuhi [_targetFill] dari kotak,
          // sementara bagian transparannya terpotong keluar.
          child: Transform.scale(
            scale: _zoom,
            child: Image.asset(
              _assetPath,
              width: size,
              height: size,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
