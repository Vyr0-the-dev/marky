import 'package:share_plus/share_plus.dart';

/// Abstract platform wrapper around share_plus for testability.
///
/// Follows the injectable platform wrapper pattern (MEM041):
/// business logic never calls share_plus static methods directly.
// ignore: one_member_abstracts
abstract class SharePlatform {
  /// Share a file at [path] with an optional [subject].
  Future<void> shareFile(String path, {String? subject});
}

/// Production implementation that delegates to [Share.shareXFiles].
class SharePlatformImpl implements SharePlatform {
  const SharePlatformImpl();

  @override
  Future<void> shareFile(String path, {String? subject}) async {
    final xFile = XFile(path);
    await Share.shareXFiles(
      [xFile],
      subject: subject,
    );
  }
}
