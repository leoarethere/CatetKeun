// Skrip sekali pakai untuk melihat code point Material Icon.
//
// Jalankan dengan: `flutter test scratch/icon_codes.dart`
// (harus lewat `flutter test`, bukan `dart run`, karena `Icons` memakai
// `dart:ui` yang hanya tersedia di dalam engine Flutter.)
//
// Output skrip ini memang sengaja dicetak ke terminal, jadi `avoid_print`
// tidak berlaku di file ini.
//
// ignore_for_file: avoid_print
import 'package:flutter/material.dart';

void main() {
  print('restaurant:${Icons.restaurant.codePoint}');
  print('directions_car:${Icons.directions_car.codePoint}');
  print('shopping_bag:${Icons.shopping_bag.codePoint}');
  print('receipt_long:${Icons.receipt_long.codePoint}');
  print('sports_esports:${Icons.sports_esports.codePoint}');
  print('medical_services:${Icons.medical_services.codePoint}');
  print('school:${Icons.school.codePoint}');
  print('more_horiz:${Icons.more_horiz.codePoint}');
  print('account_balance_wallet:${Icons.account_balance_wallet.codePoint}');
  print('card_giftcard:${Icons.card_giftcard.codePoint}');
  print('trending_up:${Icons.trending_up.codePoint}');
  print('storefront:${Icons.storefront.codePoint}');
  print('sell:${Icons.sell.codePoint}');
  print('redeem:${Icons.redeem.codePoint}');
  print('savings:${Icons.savings.codePoint}');
}
