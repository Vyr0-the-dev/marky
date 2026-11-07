import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marky/app/theme/reading_room_tokens.dart';
import 'package:marky/features/bookmarks/domain/bookmark.dart';
import 'package:marky/features/reader/domain/article_content.dart';
import 'package:marky/features/reader/presentation/reader_providers.dart';
import 'package:url_launcher/url_launcher.dart';

enum ReaderThemeMode {
  light(
    name: 'Kağıt',
    background: Color(0xFFFDFBF7),
    surface: Color(0xFFF5F0E6),
    text: Color(0xFF1E1E1E),
    subtext: Color(0xFF6E6E6C),
    accent: Color(0xFF8C5E35),
    border: Color(0xFFE8E2D5),
  ),
  sepia(
    name: 'Sepya',
    background: Color(0xFFF4ECD8),
    surface: Color(0xFFEADFCA),
    text: Color(0xFF382C1E),
    subtext: Color(0xFF7A6A55),
    accent: Color(0xFF7A4A25),
    border: Color(0xFFDDD2BC),
  ),
  dark(
    name: 'Koyu',
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
  serif('Serif (Tırnaklı)'),
  sans('Sans (Düz)');

  const ReaderFontFamily(this.label);
  final String label;
}

/// Immersive, distraction-free reader mode for articles and long-form bookmarks.
class ReaderScreen extends ConsumerStatefulWidget {
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
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
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

  TextStyle _getTextStyle(
    ReaderThemeMode theme, {
    double? size,
    FontWeight? weight,
    double? height,
    FontStyle? fontStyle,
  }) {
    final double effectiveSize = size ?? _fontSize;
    final double effectiveHeight = height ?? 1.68;
    return switch (_fontFamily) {
      ReaderFontFamily.serif => GoogleFonts.merriweather(
          fontSize: effectiveSize,
          fontWeight: weight ?? FontWeight.normal,
          height: effectiveHeight,
          fontStyle: fontStyle,
          color: theme.text,
        ),
      ReaderFontFamily.sans => GoogleFonts.inter(
          fontSize: effectiveSize,
          fontWeight: weight ?? FontWeight.normal,
          height: effectiveHeight,
          fontStyle: fontStyle,
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
                        margin: const EdgeInsets.only(
                            bottom: ReadingRoomSpacing.md),
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
                          'Yazı Tipi & Tema',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _themeMode.text,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close_rounded,
                              size: 20, color: _themeMode.text),
                          onPressed: () => Navigator.of(ctx).pop(),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: ReadingRoomSpacing.lg),

                    // ── Theme Selector ────────────────────────
                    Row(
                      children:
                          ReaderThemeMode.values.map((ReaderThemeMode mode) {
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
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: mode.background,
                                  borderRadius: BorderRadius.circular(
                                      ReadingRoomRadii.standard),
                                  border: Border.all(
                                    color:
                                        isSelected ? mode.accent : mode.border,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    mode.name,
                                    style: TextStyle(
                                      color: mode.text,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
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
                      children:
                          ReaderFontFamily.values.map((ReaderFontFamily font) {
                        final bool isSelected = _fontFamily == font;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                backgroundColor: isSelected
                                    ? _themeMode.accent.withValues(alpha: 0.15)
                                    : Colors.transparent,
                                side: BorderSide(
                                  color: isSelected
                                      ? _themeMode.accent
                                      : _themeMode.border,
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                              onPressed: () {
                                setState(() => _fontFamily = font);
                                setSheetState(() {});
                              },
                              child: Text(
                                font.label,
                                style: TextStyle(
                                  color: _themeMode.text,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
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
                        Icon(Icons.format_size_rounded,
                            size: 18, color: _themeMode.subtext),
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

  @override
  Widget build(BuildContext context) {
    final Bookmark bookmark = widget.bookmark;
    final AsyncValue<ArticleContent> articleAsync =
        ref.watch(readerArticleProvider(bookmark));

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
                    icon:
                        Icon(Icons.arrow_back_rounded, color: _themeMode.text),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Geri',
                  ),
                  const Spacer(),
                  articleAsync.when(
                    data: (ArticleContent article) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _themeMode.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _themeMode.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(Icons.schedule_rounded,
                              size: 14, color: _themeMode.subtext),
                          const SizedBox(width: 4),
                          Text(
                            '${article.readingTimeMinutes} dk okuma',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: _themeMode.subtext,
                            ),
                          ),
                        ],
                      ),
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    icon: Icon(Icons.refresh_rounded, color: _themeMode.text),
                    tooltip: 'Yeniden Ayrıştır',
                    onPressed: () {
                      ref
                          .read(readerArticleProvider(bookmark).notifier)
                          .refresh();
                    },
                  ),
                  IconButton(
                    icon:
                        Icon(Icons.text_fields_rounded, color: _themeMode.text),
                    tooltip: 'Yazı Tipi & Tema',
                    onPressed: _showAppearanceSheet,
                  ),
                ],
              ),
            ),

            // ── Article Body ──────────────────────────────
            Expanded(
              child: articleAsync.when(
                data: _buildArticleScroll,
                loading: _buildLoadingState,
                error: (Object err, _) => _buildErrorState(err),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ReadingRoomSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: _themeMode.accent,
              ),
            ),
            const SizedBox(height: ReadingRoomSpacing.lg),
            Text(
              'Makale içeriği çıkarılıyor…',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: _themeMode.text,
              ),
            ),
            const SizedBox(height: ReadingRoomSpacing.xs),
            Text(
              'Gereksiz ögeler ve reklamlar temizleniyor',
              style: TextStyle(
                fontSize: 13,
                color: _themeMode.subtext,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ReadingRoomSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.error_outline_rounded,
                size: 48, color: _themeMode.accent),
            const SizedBox(height: ReadingRoomSpacing.md),
            Text(
              'Makale içeriği çıkarılamadı',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _themeMode.text,
              ),
            ),
            const SizedBox(height: ReadingRoomSpacing.sm),
            Text(
              'Sayfa sunucusu isteği engellemiş olabilir veya internet bağlantınız kesilmiş olabilir.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: _themeMode.subtext),
            ),
            const SizedBox(height: ReadingRoomSpacing.lg),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: _themeMode.accent,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                ref
                    .read(readerArticleProvider(widget.bookmark).notifier)
                    .refresh();
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Tekrar Dene'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleScroll(ArticleContent article) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(
        horizontal: ReadingRoomSpacing.xl,
        vertical: ReadingRoomSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Fallback notice banner if article couldn't be fully fetched
          if (article.isFallback) ...<Widget>[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(ReadingRoomSpacing.md),
              margin: const EdgeInsets.only(bottom: ReadingRoomSpacing.lg),
              decoration: BoxDecoration(
                color: _themeMode.surface,
                borderRadius: BorderRadius.circular(ReadingRoomRadii.standard),
                border: Border.all(color: _themeMode.border),
              ),
              child: Row(
                children: <Widget>[
                  Icon(Icons.info_outline_rounded,
                      size: 18, color: _themeMode.accent),
                  const SizedBox(width: ReadingRoomSpacing.sm),
                  Expanded(
                    child: Text(
                      'Tam metin çıkarılamadı; özet ve önizleme gösteriliyor.',
                      style: TextStyle(
                        fontSize: 12,
                        color: _themeMode.subtext,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Domain / Site Name
          if (article.siteName != null && article.siteName!.isNotEmpty)
            Text(
              article.siteName!.toUpperCase(),
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
            article.title,
            style: _getTextStyle(
              _themeMode,
              size: _fontSize * 1.45,
              weight: FontWeight.bold,
              height: 1.28,
            ),
          ),
          const SizedBox(height: ReadingRoomSpacing.md),

          // Author & Date
          Row(
            children: <Widget>[
              if (article.author != null &&
                  article.author!.isNotEmpty) ...<Widget>[
                Icon(Icons.person_outline_rounded,
                    size: 14, color: _themeMode.subtext),
                const SizedBox(width: 4),
                Text(
                  article.author!,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _themeMode.subtext,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              if (article.publishDate != null) ...<Widget>[
                Icon(Icons.calendar_today_outlined,
                    size: 12, color: _themeMode.subtext),
                const SizedBox(width: 4),
                Text(
                  '${article.publishDate!.day}.${article.publishDate!.month}.${article.publishDate!.year}',
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
          if (article.heroImageUrl != null &&
              article.heroImageUrl!.isNotEmpty) ...<Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(ReadingRoomRadii.standard),
              child: Image.network(
                article.heroImageUrl!,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
            const SizedBox(height: ReadingRoomSpacing.xl),
          ],

          // Render Rich Article Blocks
          ...article.blocks.map(_buildBlock),

          const SizedBox(height: ReadingRoomSpacing.huge),

          // Bottom Open in Web action
          Center(
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: _themeMode.text,
                side: BorderSide(color: _themeMode.border),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onPressed: () {
                final String url =
                    widget.bookmark.canonicalUrl ?? widget.bookmark.originalUrl;
                final Uri? uri = Uri.tryParse(url);
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
    );
  }

  Widget _buildBlock(ArticleBlock block) {
    switch (block.type) {
      case ArticleBlockType.heading:
        final double scale = switch (block.level) {
          1 => 1.35,
          2 => 1.22,
          _ => 1.1,
        };
        return Padding(
          padding: const EdgeInsets.only(
            top: ReadingRoomSpacing.xl,
            bottom: ReadingRoomSpacing.sm,
          ),
          child: Text(
            block.text,
            style: _getTextStyle(
              _themeMode,
              size: _fontSize * scale,
              weight: FontWeight.bold,
              height: 1.3,
            ),
          ),
        );

      case ArticleBlockType.paragraph:
        return Padding(
          padding: const EdgeInsets.only(bottom: ReadingRoomSpacing.lg),
          child: Text(
            block.text,
            style: _getTextStyle(_themeMode),
          ),
        );

      case ArticleBlockType.blockquote:
        return Container(
          margin: const EdgeInsets.only(bottom: ReadingRoomSpacing.lg),
          padding: const EdgeInsets.symmetric(
            horizontal: ReadingRoomSpacing.md,
            vertical: ReadingRoomSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: _themeMode.surface.withValues(alpha: 0.5),
            border: Border(
              left: BorderSide(color: _themeMode.accent, width: 3.5),
            ),
            borderRadius: const BorderRadius.horizontal(
              right: Radius.circular(8),
            ),
          ),
          child: Text(
            block.text,
            style: _getTextStyle(
              _themeMode,
              fontStyle: FontStyle.italic,
              height: 1.55,
            ),
          ),
        );

      case ArticleBlockType.code:
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: ReadingRoomSpacing.lg),
          padding: const EdgeInsets.all(ReadingRoomSpacing.md),
          decoration: BoxDecoration(
            color: _themeMode.surface,
            borderRadius: BorderRadius.circular(ReadingRoomRadii.standard),
            border: Border.all(color: _themeMode.border),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(
              block.text,
              style: GoogleFonts.firaCode(
                fontSize: _fontSize * 0.85,
                color: _themeMode.text,
                height: 1.5,
              ),
            ),
          ),
        );

      case ArticleBlockType.list:
        return Padding(
          padding: const EdgeInsets.only(bottom: ReadingRoomSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: block.listItems
                .asMap()
                .entries
                .map((MapEntry<int, String> entry) {
              final String prefix =
                  block.isOrdered ? '${entry.key + 1}. ' : '• ';
              return Padding(
                padding: const EdgeInsets.only(bottom: ReadingRoomSpacing.xs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      prefix,
                      style: _getTextStyle(_themeMode, weight: FontWeight.bold),
                    ),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: _getTextStyle(_themeMode),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );

      case ArticleBlockType.image:
        if (block.imageUrl == null || block.imageUrl!.isEmpty) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: ReadingRoomSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(ReadingRoomRadii.standard),
                child: Image.network(
                  block.imageUrl!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
              if (block.caption != null &&
                  block.caption!.isNotEmpty) ...<Widget>[
                const SizedBox(height: 6),
                Text(
                  block.caption!,
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: _themeMode.subtext,
                  ),
                ),
              ],
            ],
          ),
        );
    }
  }
}
