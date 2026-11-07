import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marky/app/theme/reading_room_tokens.dart';
import 'package:marky/features/bookmarks/domain/bookmark.dart';
import 'package:url_launcher/url_launcher.dart';

enum ReaderThemeMode {
  light(
    name: 'Paper',
    background: Color(0xFFFDFBF7),
    surface: Color(0xFFF5F0E6),
    text: Color(0xFF1E1E1E),
    subtext: Color(0xFF6E6E6C),
    accent: Color(0xFF8C5E35),
    border: Color(0xFFE8E2D5),
  ),
  sepia(
    name: 'Sepia',
    background: Color(0xFFF4ECD8),
    surface: Color(0xFFEADFCA),
    text: Color(0xFF382C1E),
    subtext: Color(0xFF7A6A55),
    accent: Color(0xFF7A4A25),
    border: Color(0xFFDDD2BC),
  ),
  dark(
    name: 'Dark',
    background: Color(0xFF141413),
    surface: Color(0xFF20201E),
    text: Color(0xFFE6E5E3),
    subtext: Color(0xFF9E9D9A),
    accent: Color(0xFFD4A373),
    border: Color(0xFF2C2C28),
  );

  const ReaderThemeMode({
    required this.name,
    required this.background,
    required this.surface,
    required this.text,
    required this.subtext,
    required this.accent,
    required this.border,
  });

  final String name;
  final Color background;
  final Color surface;
  final Color text;
  final Color subtext;
  final Color accent;
  final Color border;
}

enum ReaderFontFamily {
  serif('Serif'),
  sans('Sans');

  const ReaderFontFamily(this.label);
  final String label;
}

/// Immersive, distraction-free reader mode for articles and long-form bookmarks.
class ReaderScreen extends StatefulWidget {
  const ReaderScreen({
    required this.bookmark,
    super.key,
  });

  final Bookmark bookmark;

  static Route<void> route(Bookmark bookmark) {
    return MaterialPageRoute<void>(
      builder: (BuildContext _) => ReaderScreen(bookmark: bookmark),
    );
  }

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  final ScrollController _scrollController = ScrollController();
  double _readingProgress = 0;
  double _fontSize = 17;
  ReaderFontFamily _fontFamily = ReaderFontFamily.serif;
  ReaderThemeMode _themeMode = ReaderThemeMode.dark;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final double max = _scrollController.position.maxScrollExtent;
    if (max <= 0) {
      if (_readingProgress != 1.0) {
        setState(() => _readingProgress = 1.0);
      }
      return;
    }
    final double current = _scrollController.offset.clamp(0.0, max);
    final double next = (current / max).clamp(0.0, 1.0);
    if ((next - _readingProgress).abs() > 0.01) {
      setState(() => _readingProgress = next);
    }
  }

  TextStyle _getTextStyle(ReaderThemeMode theme, {double? size, FontWeight? weight, double? height}) {
    final double effectiveSize = size ?? _fontSize;
    final double effectiveHeight = height ?? 1.65;
    return switch (_fontFamily) {
      ReaderFontFamily.serif => GoogleFonts.merriweather(
          fontSize: effectiveSize,
          fontWeight: weight ?? FontWeight.normal,
          height: effectiveHeight,
          color: theme.text,
        ),
      ReaderFontFamily.sans => GoogleFonts.inter(
          fontSize: effectiveSize,
          fontWeight: weight ?? FontWeight.normal,
          height: effectiveHeight,
          color: theme.text,
        ),
    };
  }

  void _showAppearanceSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        return StatefulBuilder(
          builder: (BuildContext ctx, StateSetter setSheetState) {
            return Container(
              padding: const EdgeInsets.all(ReadingRoomSpacing.lg),
              decoration: BoxDecoration(
                color: _themeMode.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(ReadingRoomRadii.sheet),
                ),
                border: Border(top: BorderSide(color: _themeMode.border)),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: ReadingRoomSpacing.md),
                        decoration: BoxDecoration(
                          color: _themeMode.subtext.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'Typography & Theme',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _themeMode.text,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close_rounded, size: 20, color: _themeMode.text),
                          onPressed: () => Navigator.of(ctx).pop(),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: ReadingRoomSpacing.lg),

                    // ── Theme Selector ────────────────────────
                    Row(
                      children: ReaderThemeMode.values.map((ReaderThemeMode mode) {
                        final bool isSelected = _themeMode == mode;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: GestureDetector(
                              onTap: () {
                                setState(() => _themeMode = mode);
                                setSheetState(() {});
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: mode.background,
                                  borderRadius: BorderRadius.circular(ReadingRoomRadii.standard),
                                  border: Border.all(
                                    color: isSelected ? mode.accent : mode.border,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    mode.name,
                                    style: TextStyle(
                                      color: mode.text,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: ReadingRoomSpacing.lg),

                    // ── Font Selector ─────────────────────────
                    Row(
                      children: ReaderFontFamily.values.map((ReaderFontFamily font) {
                        final bool isSelected = _fontFamily == font;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                backgroundColor: isSelected ? _themeMode.accent.withValues(alpha: 0.15) : Colors.transparent,
                                side: BorderSide(
                                  color: isSelected ? _themeMode.accent : _themeMode.border,
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              onPressed: () {
                                setState(() => _fontFamily = font);
                                setSheetState(() {});
                              },
                              child: Text(
                                font.label,
                                style: TextStyle(
                                  color: _themeMode.text,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: ReadingRoomSpacing.lg),

                    // ── Font Size Controls ────────────────────
                    Row(
                      children: <Widget>[
                        Icon(Icons.format_size_rounded, size: 18, color: _themeMode.subtext),
                        const SizedBox(width: 8),
                        Text(
                          'A',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _themeMode.text,
                          ),
                        ),
                        Expanded(
                          child: Slider(
                            value: _fontSize,
                            min: 14,
                            max: 26,
                            divisions: 6,
                            activeColor: _themeMode.accent,
                            inactiveColor: _themeMode.border,
                            onChanged: (double val) {
                              setState(() => _fontSize = val);
                              setSheetState(() {});
                            },
                          ),
                        ),
                        Text(
                          'A',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: _themeMode.text,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  int _calculateReadingMinutes(String content) {
    final int wordCount = content.split(RegExp(r'\s+')).where((String w) => w.isNotEmpty).length;
    final int minutes = (wordCount / 200).ceil();
    return minutes < 1 ? 1 : minutes;
  }

  @override
  Widget build(BuildContext context) {
    final Bookmark bookmark = widget.bookmark;
    final String rawText = (bookmark.description ?? '') + (bookmark.snippet != null ? '\n\n${bookmark.snippet}' : '');
    final String content = rawText.trim().isNotEmpty
        ? rawText.trim()
        : 'Bu yer işareti için henüz uzun makale metni çıkarılmamış. Orijinal sayfayı web görünümünde açarak okuyabilirsiniz.';
    final int estMinutes = bookmark.readingTimeMinutes ?? _calculateReadingMinutes(content);

    return Scaffold(
      backgroundColor: _themeMode.background,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // ── Top Reading Progress Bar ───────────────────
            LinearProgressIndicator(
              value: _readingProgress,
              minHeight: 2.5,
              backgroundColor: _themeMode.border,
              valueColor: AlwaysStoppedAnimation<Color>(_themeMode.accent),
            ),

            // ── Custom App Bar ────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: ReadingRoomSpacing.md,
                vertical: ReadingRoomSpacing.xs,
              ),
              child: Row(
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.arrow_back_rounded, color: _themeMode.text),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Geri',
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _themeMode.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _themeMode.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(Icons.schedule_rounded, size: 14, color: _themeMode.subtext),
                        const SizedBox(width: 4),
                        Text(
                          '$estMinutes dk okuma',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: _themeMode.subtext,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    icon: Icon(Icons.text_fields_rounded, color: _themeMode.text),
                    tooltip: 'Yazı Tipi & Tema',
                    onPressed: _showAppearanceSheet,
                  ),
                ],
              ),
            ),

            // ── Scrollable Article ────────────────────────
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: ReadingRoomSpacing.xl,
                  vertical: ReadingRoomSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Domain / Site Name
                    if (bookmark.siteName != null || bookmark.normalizedHost != null)
                      Text(
                        (bookmark.siteName ?? bookmark.normalizedHost!).toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w600,
                          color: _themeMode.accent,
                        ),
                      ),
                    const SizedBox(height: ReadingRoomSpacing.sm),

                    // Article Title
                    Text(
                      bookmark.displayTitle,
                      style: _getTextStyle(
                        _themeMode,
                        size: _fontSize * 1.45,
                        weight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: ReadingRoomSpacing.md),

                    // Author & Date
                    Row(
                      children: <Widget>[
                        if (bookmark.author != null && bookmark.author!.isNotEmpty) ...<Widget>[
                          Icon(Icons.person_outline_rounded, size: 14, color: _themeMode.subtext),
                          const SizedBox(width: 4),
                          Text(
                            bookmark.author!,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: _themeMode.subtext,
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        if (bookmark.publishDate != null) ...<Widget>[
                          Icon(Icons.calendar_today_outlined, size: 12, color: _themeMode.subtext),
                          const SizedBox(width: 4),
                          Text(
                            '${bookmark.publishDate!.day}.${bookmark.publishDate!.month}.${bookmark.publishDate!.year}',
                            style: TextStyle(
                              fontSize: 13,
                              color: _themeMode.subtext,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: ReadingRoomSpacing.lg),

                    // Hero Image
                    if (bookmark.heroImageUrl != null && bookmark.heroImageUrl!.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(ReadingRoomRadii.standard),
                        child: Image.network(
                          bookmark.heroImageUrl!,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                      ),
                    const SizedBox(height: ReadingRoomSpacing.xl),

                    // Content Paragraphs
                    ...content.split('\n\n').map((String p) {
                      final String trimmed = p.trim();
                      if (trimmed.isEmpty) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: ReadingRoomSpacing.lg),
                        child: Text(
                          trimmed,
                          style: _getTextStyle(_themeMode),
                        ),
                      );
                    }),

                    const SizedBox(height: ReadingRoomSpacing.huge),

                    // Bottom Open in Web action
                    Center(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _themeMode.text,
                          side: BorderSide(color: _themeMode.border),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        onPressed: () {
                          final Uri? uri = Uri.tryParse(bookmark.canonicalUrl ?? bookmark.originalUrl);
                          if (uri != null) {
                            launchUrl(uri, mode: LaunchMode.externalApplication);
                          }
                        },
                        icon: const Icon(Icons.open_in_browser_rounded, size: 18),
                        label: const Text('Orijinal Sayfayı Tarayıcıda Aç'),
                      ),
                    ),
                    const SizedBox(height: ReadingRoomSpacing.huge),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
