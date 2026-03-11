import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_colors.dart';

class WelcomeScreen extends StatelessWidget {
  final VoidCallback onGetStarted;
  final Future<void> Function() onImport;

  const WelcomeScreen({
    super.key,
    required this.onGetStarted,
    required this.onImport,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  gradient: kOrangeGradient,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: kOrange.withValues(alpha: 0.35),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: SvgPicture.asset('assets/logo.svg'),
              ),
              const SizedBox(height: 28),
              const Text(
                'Witaj w Recipedia!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: kTextDark),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'Twoje ulubione przepisy\nw jednym miejscu.',
                style: TextStyle(fontSize: 15, color: kTextMuted, height: 1.55),
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 1),
              _featureTile(Icons.restaurant_menu_outlined, 'Przepisy', 'Twórz, edytuj i organizuj dania'),
              const SizedBox(height: 14),
              _featureTile(Icons.shopping_cart_outlined, 'Lista zakupów', 'Generuj automatycznie z przepisów'),
              const SizedBox(height: 14),
              _featureTile(Icons.document_scanner_outlined, 'Skanowanie OCR', 'Dodawaj składniki aparatem'),
              const Spacer(flex: 2),
              GestureDetector(
                onTap: onGetStarted,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: kOrangeGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: kOrange.withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'Rozpocznij',
                      style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: onImport,
                child: const Text(
                  'Importuj istniejące przepisy',
                  style: TextStyle(
                    fontSize: 12,
                    color: kTextMuted,
                    decoration: TextDecoration.underline,
                    decorationColor: kTextMuted,
                  ),
                ),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }

  Widget _featureTile(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(color: kOrangeLight, borderRadius: BorderRadius.circular(14)),
          child: Icon(icon, color: kOrange, size: 22),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: kTextDark)),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: kTextMuted)),
          ],
        ),
      ],
    );
  }
}
