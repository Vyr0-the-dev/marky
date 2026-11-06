import 'package:flutter/material.dart';

import 'package:marky/app/theme/reading_room_tokens.dart';
import 'package:marky/core/url/url_extractor.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  bool _resolved = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_resolved || !mounted) return;

    for (final Barcode barcode in capture.barcodes) {
      final String? raw = barcode.rawValue;
      if (raw == null || raw.trim().isEmpty) continue;
      final String? extracted = const UrlExtractor().extractFirst(raw);
      if (extracted == null || extracted.isEmpty) continue;
      _resolved = true;
      Navigator.of(context).pop(extracted);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isTurkish =
        Localizations.localeOf(context).languageCode.toLowerCase().startsWith(
              'tr',
            );

    return Scaffold(
      appBar: AppBar(
        title: Text(isTurkish ? 'QR ile Tara' : 'Scan QR'),
      ),
      body: Stack(
        children: <Widget>[
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          Positioned(
            left: ReadingRoomSpacing.lg,
            right: ReadingRoomSpacing.lg,
            bottom: ReadingRoomSpacing.xl,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.56),
                borderRadius: BorderRadius.circular(ReadingRoomRadii.standard),
              ),
              child: Padding(
                padding: const EdgeInsets.all(ReadingRoomSpacing.md),
                child: Text(
                  isTurkish
                      ? 'Bir bağlantı içeren QR kodunu kameraya göster.'
                      : 'Point the camera at a QR code containing a link.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
