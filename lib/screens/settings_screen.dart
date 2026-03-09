import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgLight,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.white.withOpacity(0.95),
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            pinned: true,
            title: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: kOrangeGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.settings_outlined, size: 20, color: Colors.white),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ustawienia',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: kTextDark)),
                    Text('Dostosuj aplikację',
                        style: TextStyle(fontSize: 11, color: kTextMuted)),
                  ],
                ),
              ],
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: kCardBorder),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('Aplikacja'),
                  _settingsCard([
                    _settingsTile(
                      icon: Icons.info_outline,
                      iconColor: kOrange,
                      title: 'Wersja aplikacji',
                      trailing: const Text('1.0.0', style: TextStyle(fontSize: 13, color: kTextMuted)),
                    ),
                    _settingsTile(
                      icon: Icons.language,
                      iconColor: kOrange,
                      title: 'Język',
                      trailing: const Text('Polski', style: TextStyle(fontSize: 13, color: kTextMuted)),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  _sectionTitle('O aplikacji'),
                  _settingsCard([
                    _settingsTile(
                      icon: Icons.restaurant,
                      iconColor: kOrange,
                      title: 'Recipedia',
                      subtitle: 'Twoje ulubione przepisy w jednym miejscu',
                    ),
                  ]),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(title,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kTextMuted)),
    );
  }

  Widget _settingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kCardBorder),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Column(
        children: children.asMap().entries.map((e) {
          final isLast = e.key == children.length - 1;
          return Column(
            children: [
              e.value,
              if (!isLast) const Divider(height: 1, color: kCardBorder),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: kOrangeLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: iconColor),
      ),
      title: Text(title, style: const TextStyle(fontSize: 14, color: kTextDark, fontWeight: FontWeight.w500)),
      subtitle: subtitle != null
          ? Text(subtitle, style: const TextStyle(fontSize: 12, color: kTextMuted))
          : null,
      trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right, color: kTextMuted, size: 18) : null),
    );
  }
}
