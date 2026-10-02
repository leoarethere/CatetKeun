import 'dart:async';

import 'package:flutter/material.dart';

import 'widgets/app_logo.dart';

/// Splash screen ber-animasi yang tampil saat aplikasi dibuka.
///
/// Menampilkan logo brand yang membesar + memudar masuk, nama aplikasi, lalu
/// memanggil [onFinished] setelah animasi selesai. Dirancang agar tidak pernah
/// menggantung: durasi animasi tetap, tidak menunggu proses async apa pun.
///
/// Catatan: ini splash tingkat Flutter (muncul setelah engine siap). Splash
/// native (windowBackground Android / LaunchScreen iOS) tetap memakai aset
/// platform dan tidak diubah di sini.
class SplashScreen extends StatefulWidget {
  /// Dipanggil setelah animasi selesai; biasanya mengganti layar ke Home.
  final VoidCallback onFinished;

  /// Total durasi tampil sebelum [onFinished] dipanggil.
  final Duration duration;

  const SplashScreen({
    super.key,
    required this.onFinished,
    this.duration = const Duration(milliseconds: 1900),
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _titleFade;
  late final Animation<Offset> _titleSlide;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    // Logo: muncul dari sedikit lebih kecil lalu membesar mulus.
    _logoScale = Tween<double>(begin: 0.72, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOutBack),
      ),
    );
    _logoFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
    );

    // Nama aplikasi: fade + slide naik, menyusul logo.
    _titleFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.35, 0.8, curve: Curves.easeOut),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 0.85, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();
    _timer = Timer(widget.duration, widget.onFinished);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Splash selalu memakai latar brand (bukan warna tema) agar konsisten
    // dengan adaptive icon dan terasa seperti kelanjutan splash native.
    return Scaffold(
      backgroundColor: AppLogo.brandColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FadeTransition(
              opacity: _logoFade,
              child: ScaleTransition(
                scale: _logoScale,
                child: const AppLogo(size: 112),
              ),
            ),
            const SizedBox(height: 20),
            FadeTransition(
              opacity: _titleFade,
              child: SlideTransition(
                position: _titleSlide,
                child: const Text(
                  'CatetKeun',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
