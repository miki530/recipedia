import 'package:flutter/material.dart';

const Color kOrange = Color(0xFFF97316);
const Color kDarkOrange = Color(0xFFEA580C);
const Color kBgLight = Color(0xFFFEF7EE);
const Color kBgLighter = Color(0xFFFFF8F0);
const Color kTextDark = Color(0xFF1C0A00);
const Color kTextMuted = Color(0xFF9E7B6B);
const Color kTextBrown = Color(0xFF7C3D12);
const Color kCardBorder = Color(0xFFFFF0E6);
const Color kOrangeBorder = Color(0xFFFED7AA);
const Color kOrangeLight = Color(0xFFFEF3E2);
const Color kOrangeMid = Color(0xFFFDBA74);

const LinearGradient kOrangeGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [kOrange, kDarkOrange],
);

const LinearGradient kBgGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [kBgLight, kBgLighter],
);

Color difficultyColor(String difficulty) {
  switch (difficulty) {
    case 'łatwy':
      return const Color(0xFF16A34A);
    case 'średni':
      return const Color(0xFFD97706);
    case 'trudny':
      return const Color(0xFFDC2626);
    default:
      return kTextMuted;
  }
}

Color difficultyBg(String difficulty) {
  switch (difficulty) {
    case 'łatwy':
      return const Color(0xFFF0FDF4);
    case 'średni':
      return const Color(0xFFFFFBEB);
    case 'trudny':
      return const Color(0xFFFEF2F2);
    default:
      return kOrangeLight;
  }
}

BoxDecoration orangeButtonDecoration({double radius = 12}) => BoxDecoration(
      gradient: kOrangeGradient,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: kOrange.withOpacity(0.3),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
