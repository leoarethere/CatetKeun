import 'package:flutter/material.dart';

/// Transisi halaman bersama agar seluruh navigasi terasa konsisten dan halus.
///
/// Pengganti `MaterialPageRoute` bawaan yang cenderung "kaku" (hanya slide
/// platform default). Di sini dipakai kombinasi fade + slide kecil dengan
/// kurva [Curves.easeOutCubic] yang terasa lebih lembut.
class AppPageRoute<T> extends PageRouteBuilder<T> {
  final WidgetBuilder builder;

  AppPageRoute({
    required this.builder,
    super.settings,
  }) : super(
          transitionDuration: const Duration(milliseconds: 320),
          reverseTransitionDuration: const Duration(milliseconds: 240),
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );

            // Slide naik sedikit + fade masuk. Slide dari 4% tinggi layar
            // supaya terasa mengalir, bukan melompat.
            final slide = Tween<Offset>(
              begin: const Offset(0, 0.04),
              end: Offset.zero,
            ).animate(curved);

            return FadeTransition(
              opacity: curved,
              child: SlideTransition(position: slide, child: child),
            );
          },
        );
}

/// Helper singkat: `Navigator.of(context).push(AppPageRoute(builder: ...))`.
extension AppNavigation on NavigatorState {
  Future<T?> pushApp<T>(WidgetBuilder builder) {
    return push<T>(AppPageRoute<T>(builder: builder));
  }
}
