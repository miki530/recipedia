import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recipes_provider.dart';
import '../providers/categories_provider.dart';
import '../theme/app_colors.dart';
import '../utils/import_export_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _exporting = false;
  bool _importing = false;

  Future<void> _export() async {
    setState(() => _exporting = true);
    try {
      final recipes = context.read<RecipesProvider>().recipes;
      final categories = context.read<CategoriesProvider>().categories;
      if (recipes.isEmpty) {
        _snack('Brak przepisów do eksportu');
        return;
      }
      await ImportExportService.exportRecipes(recipes, categories);
    } catch (e) {
      _snack('Błąd eksportu: $e');
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _import() async {
    setState(() => _importing = true);
    try {
      final result = await ImportExportService.importData();
      if (!mounted) return;
      if (result == null) {
        _snack('Anulowano lub błąd odczytu pliku');
        return;
      }

      if (result.categories.isNotEmpty) {
        await context.read<CategoriesProvider>().bulkImport(result.categories);
      }

      final imported = await context.read<RecipesProvider>().bulkImport(result.recipes);
      if (mounted) {
        _snack(imported == 0
            ? 'Wszystkie przepisy już istnieją – nic nie dodano'
            : 'Zaimportowano $imported przepisów ✓');
      }
    } catch (e) {
      _snack('Błąd importu: $e');
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

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
                      borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.settings_outlined,
                      size: 20, color: Colors.white),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ustawienia',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: kTextDark)),
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
                  _sectionTitle('Dane'),
                  _settingsCard([
                    _settingsTile(
                      icon: Icons.upload_outlined,
                      iconColor: kOrange,
                      title: 'Eksportuj przepisy',
                      subtitle: 'Zapisz backup jako plik .recipedia',
                      onTap: _exporting ? null : _export,
                      trailing: _exporting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: kOrange))
                          : null,
                    ),
                    _settingsTile(
                      icon: Icons.download_outlined,
                      iconColor: kOrange,
                      title: 'Importuj przepisy',
                      subtitle: 'Wczytaj plik .recipedia',
                      onTap: _importing ? null : _import,
                      trailing: _importing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: kOrange))
                          : null,
                    ),
                  ]),
                  const SizedBox(height: 16),
                  _sectionTitle('Aplikacja'),
                  _settingsCard([
                    _settingsTile(
                      icon: Icons.info_outline,
                      iconColor: kOrange,
                      title: 'Wersja aplikacji',
                      trailing: const Text('1.0.0',
                          style: TextStyle(fontSize: 13, color: kTextMuted)),
                    ),
                    _settingsTile(
                      icon: Icons.language,
                      iconColor: kOrange,
                      title: 'Język',
                      trailing: const Text('Polski',
                          style: TextStyle(fontSize: 13, color: kTextMuted)),
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

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 4),
        child: Text(title,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: kTextMuted)),
      );

  Widget _settingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kCardBorder),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)
        ],
      ),
      child: Column(
        children: children.asMap().entries.map((e) {
          final isLast = e.key == children.length - 1;
          return Column(children: [
            e.value,
            if (!isLast) const Divider(height: 1, color: kCardBorder),
          ]);
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
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
            color: kOrangeLight, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, size: 18, color: iconColor),
      ),
      title: Text(title,
          style: const TextStyle(
              fontSize: 14,
              color: kTextDark,
              fontWeight: FontWeight.w500)),
      subtitle: subtitle != null
          ? Text(subtitle,
              style: const TextStyle(fontSize: 12, color: kTextMuted))
          : null,
      trailing: trailing ??
          (onTap != null
              ? const Icon(Icons.chevron_right,
                  color: kTextMuted, size: 18)
              : null),
    );
  }
}
