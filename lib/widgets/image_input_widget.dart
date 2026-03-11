import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_colors.dart';

class ImageInputWidget extends StatefulWidget {
  final String value;
  final ValueChanged<String> onChange;

  const ImageInputWidget({
    super.key,
    required this.value,
    required this.onChange,
  });

  @override
  State<ImageInputWidget> createState() => _ImageInputWidgetState();
}

class _ImageInputWidgetState extends State<ImageInputWidget> {
  int _selectedTab = 0; // 0=camera, 1=gallery, 2=link
  final _urlController = TextEditingController();
  bool _loading = false;
  Uint8List? _cachedBytes;
  String? _cachedSrc;
  String _error = '';

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 1200,
        imageQuality: 82,
      );
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        final base64Str = base64Encode(bytes);
        widget.onChange('data:image/jpeg;base64,$base64Str');
      }
    } catch (e) {
      setState(() => _error = 'Nie udało się wczytać zdjęcia');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _confirmUrl() {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      setState(() => _error = 'Wklej adres URL');
      return;
    }
    try {
      Uri.parse(url);
      setState(() => _error = '');
      widget.onChange(url);
    } catch (_) {
      setState(() => _error = 'Nieprawidłowy adres URL');
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = widget.value.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasImage) _buildPreview(),
        if (!hasImage) _buildTabs(),
        if (_error.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(_error,
                style: const TextStyle(fontSize: 11, color: Color(0xFFDC2626))),
          ),
      ],
    );
  }

  Widget _buildPreview() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: kOrangeLight,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildImageWidget(widget.value),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withValues(alpha: 0.45), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: Row(
              children: [
                _previewButton(
                  icon: Icons.delete_outline,
                  label: 'Usuń zdjęcie',
                  color: const Color(0xFFDC2626),
                  onTap: () {
                    widget.onChange('');
                    _urlController.clear();
                  },
                ),
                const SizedBox(width: 8),
                _previewButton(
                  icon: Icons.refresh,
                  label: 'Zmień',
                  color: Colors.black54,
                  onTap: () => widget.onChange(''),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _previewButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: Colors.white),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFEE2C8)),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Row(
              children: [
                _tab(0, Icons.camera_alt_outlined, 'Kamera'),
                _tab(1, Icons.photo_library_outlined, 'Galeria'),
                _tab(2, Icons.link, 'Link'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildTabContent(),
          ),
        ],
      ),
    );
  }

  Widget _tab(int index, IconData icon, String label) {
    final active = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _selectedTab = index;
          _error = '';
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? const Color(0xFFFFF0E6) : const Color(0xFFFAFAFA),
            border: Border(
              bottom: BorderSide(
                color: active ? kDarkOrange : Colors.transparent,
                width: 2,
              ),
              right: index < 2
                  ? const BorderSide(color: Color(0xFFFEE2C8), width: 0.5)
                  : BorderSide.none,
            ),
            borderRadius: index == 0
                ? const BorderRadius.only(topLeft: Radius.circular(16))
                : index == 2
                    ? const BorderRadius.only(topRight: Radius.circular(16))
                    : BorderRadius.zero,
          ),
          child: Column(
            children: [
              Icon(icon, size: 18, color: active ? kDarkOrange : kTextMuted),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: active ? kDarkOrange : kTextMuted,
                  fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return _buildCameraTab();
      case 1:
        return _buildGalleryTab();
      case 2:
        return _buildLinkTab();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildCameraTab() {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: kOrangeGradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.camera_alt, size: 32, color: Colors.white),
        ),
        const SizedBox(height: 10),
        const Text('Zrób zdjęcie aparatem urządzenia',
            style: TextStyle(fontSize: 12, color: kTextMuted), textAlign: TextAlign.center),
        const SizedBox(height: 12),
        _orangeButton(
          icon: Icons.camera_alt,
          label: _loading ? 'Ładowanie…' : 'Otwórz aparat',
          onTap: _loading ? null : () => _pickImage(ImageSource.camera),
        ),
      ],
    );
  }

  Widget _buildGalleryTab() {
    return GestureDetector(
      onTap: _loading ? null : () => _pickImage(ImageSource.gallery),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: kOrangeLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.photo_library_outlined, size: 32, color: kOrange),
          ),
          const SizedBox(height: 10),
          const Text('Wybierz zdjęcie z galerii',
              style: TextStyle(fontSize: 12, color: kTextMuted)),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(color: kOrangeBorder, width: 2, style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              children: [
                Icon(Icons.upload_outlined, color: kOrangeMid),
                SizedBox(height: 6),
                Text('Kliknij, aby wybrać plik',
                    style: TextStyle(fontSize: 12, color: Color(0xFFC2410C))),
                Text('JPG, PNG, WEBP',
                    style: TextStyle(fontSize: 10, color: kTextMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: kOrangeLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Row(
            children: [
              Icon(Icons.link, size: 16, color: kOrange),
              SizedBox(width: 8),
              Expanded(
                child: Text('Wklej adres URL zdjęcia z internetu',
                    style: TextStyle(fontSize: 11, color: kTextMuted)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _urlController,
                style: const TextStyle(fontSize: 13, color: kTextDark),
                decoration: InputDecoration(
                  hintText: 'https://...',
                  hintStyle: const TextStyle(color: kTextMuted, fontSize: 13),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFFEE2C8)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: kOrange, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onSubmitted: (_) => _confirmUrl(),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _confirmUrl,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  gradient: kOrangeGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('Dodaj',
                    style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _orangeButton({required IconData icon, required String label, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          gradient: kOrangeGradient,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: Colors.white),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget(String imageStr) {
    if (imageStr.startsWith('data:image')) {
      if (_cachedSrc != imageStr || _cachedBytes == null) {
        try {
          _cachedBytes = base64Decode(imageStr.split(',').last);
          _cachedSrc = imageStr;
        } catch (_) {
          return Container(color: kOrangeLight);
        }
      }
      return Image.memory(_cachedBytes!, fit: BoxFit.cover, gaplessPlayback: true);
    }
    return Image.network(
      imageStr,
      fit: BoxFit.cover,
      gaplessPlayback: true,
      errorBuilder: (_, __, ___) => Container(color: kOrangeLight),
    );
  }
}
