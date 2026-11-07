import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:marky/app/theme/reading_room_theme.dart';
import 'package:marky/core/database/enums/bookmark_source_type.dart';
import 'package:marky/features/dashboard/data/dashboard_providers.dart';
import 'package:marky/features/dashboard/domain/dashboard_stats.dart';
import 'package:marky/features/dashboard/presentation/dashboard_screen.dart';
import 'package:marky/l10n/app_localizations.dart';

void main() {
  testWidgets(
    'DashboardScreen renders hero reading progress card, metric grid, timeline, and ranked sections',
    (WidgetTester tester) async {
      final DashboardStats stats = DashboardStats(
        totalBookmarks: 24,
        unreadCount: 6,
        favoritesCount: 5,
        archivedCount: 3,
        addedThisWeek: 8,
        topHosts: const <HostCount>[
          HostCount('github.com', 10),
          HostCount('flutter.dev', 6),
        ],
        topTags: const <TagCount>[
          TagCount('architecture', 7),
          TagCount('dart', 4),
        ],
        sourceBreakdown: const <SourceTypeCount>[
          SourceTypeCount(BookmarkSourceType.share, 14),
          SourceTypeCount(BookmarkSourceType.manual, 10),
        ],
        timeline: <TimelineBucket>[
          TimelineBucket(DateTime(2026, 11), 2),
          TimelineBucket(DateTime(2026, 11, 2), 6),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            dashboardStatsProvider.overrideWith((_) async => stats),
          ],
          child: MaterialApp(
            theme: ReadingRoomTheme.build(ReadingRoomVariant.light),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const DashboardScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('KÜTÜPHANE GENEL BAKIŞI'), findsOneWidget);
      expect(find.text('%75 Okundu'), findsOneWidget);
      expect(find.text('18'), findsOneWidget); // Read count (24 - 6)
      expect(find.text('24'), findsWidgets);
      expect(find.text('Bu Hafta'), findsOneWidget);
      expect(find.text('Son 7 Günlük Hareket'), findsOneWidget);
      expect(find.text('8 kayıt'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Popüler Etiketler'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('En Çok Okunan Kaynaklar'), findsOneWidget);
      expect(find.text('github.com'), findsWidgets);
      expect(find.text('Kaynak Dağılımı'), findsOneWidget);
      expect(find.text('Popüler Etiketler'), findsOneWidget);
      expect(find.text('architecture'), findsOneWidget);
    },
  );
}
