import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:logger/logger.dart';

import 'package:marky/app/providers/app_providers.dart';
import 'package:marky/core/database/isar_service.dart';
import 'package:marky/core/search/models/search_query.dart';
import 'package:marky/features/search/domain/use_cases/search_bookmarks_use_case.dart';
import 'package:marky/features/vault/data/repositories/vault_config_repository_impl.dart';
import 'package:marky/features/vault/domain/repositories/vault_config_repository.dart';
import 'package:marky/features/vault/domain/services/vault_security_service.dart';
import 'package:marky/shared/models/bookmark_item.dart';
import 'package:marky/shared/models/vault_config.dart';

// ─── Repository provider ───────────────────────────────────────────────

/// Provider that exposes the live [VaultConfigRepository].
///
/// Throws [StateError] if the database has not been opened yet.
final Provider<VaultConfigRepository> vaultConfigRepositoryProvider =
    Provider<VaultConfigRepository>((Ref ref) {
  final Isar? isar = IsarService.instance.isar;
  if (isar == null) {
    throw StateError(
      'Isar database not initialized. '
      'Ensure IsarService.instance.open() is called during app bootstrap.',
    );
  }
  return VaultConfigRepositoryImpl(isar: isar);
});

// ─── Config provider ───────────────────────────────────────────────────

/// Provider that loads the current [VaultConfig] from Isar.
///
/// Returns `null` when no config has been saved yet.
final FutureProvider<VaultConfig?> vaultConfigProvider =
    FutureProvider<VaultConfig?>((Ref ref) async {
  final VaultConfigRepository repository = ref.watch(vaultConfigRepositoryProvider);
  return repository.getConfig();
});

// ─── Auth state notifier ───────────────────────────────────────────────

/// Notifier that manages vault authentication state.
///
/// State transitions:
/// - `AsyncValue.data(false)` — idle / locked.
/// - `AsyncValue.loading()` — biometric prompt in progress.
/// - `AsyncValue.data(true)` — successfully authenticated.
/// - `AsyncValue.error(err, stack)` — biometric unavailable or failed.
class VaultAuthNotifier extends StateNotifier<AsyncValue<bool>> {
  VaultAuthNotifier({
    required VaultSecurityService securityService,
    required VaultConfigRepository configRepository,
  })  : _securityService = securityService,
        _configRepository = configRepository,
        super(const AsyncValue.data(false));

  final VaultSecurityService _securityService;
  final VaultConfigRepository _configRepository;
  final Logger _logger = Logger();

  /// Triggers biometric authentication.
  ///
  /// On success updates [VaultConfig.lastUnlockAt] and emits
  /// `AsyncValue.data(true)`. On any failure emits
  /// `AsyncValue.error(...)` with a user-facing message.
  Future<void> authenticate() async {
    if (state.isLoading) return;

    state = const AsyncValue.loading();

    try {
      final bool supported = await _securityService.isDeviceSupported();
      if (!supported) {
        _logger.w('Vault auth unavailable — device does not support biometrics');
        state = AsyncValue.error(
          const VaultAuthException('Biometric authentication is not available on this device.'),
          StackTrace.current,
        );
        return;
      }

      final bool hasBiometrics =
          (await _securityService.getAvailableBiometrics()).isNotEmpty;
      if (!hasBiometrics) {
        _logger.w('Vault auth unavailable — no biometrics enrolled');
        state = AsyncValue.error(
          const VaultAuthException('No biometrics are enrolled on this device.'),
          StackTrace.current,
        );
        return;
      }

      final bool success = await _securityService.authenticate();

      if (success) {
        _logger.i('Vault auth succeeded');
        await _recordUnlock();
        state = const AsyncValue.data(true);
      } else {
        _logger.w('Vault auth failed — user cancellation or system rejection');
        state = AsyncValue.error(
          const VaultAuthException('Authentication failed. Please try again.'),
          StackTrace.current,
        );
      }
    } catch (err, stack) {
      _logger.e('Vault auth unexpected error', error: err, stackTrace: stack);
      state = AsyncValue.error(
        VaultAuthException('Something went wrong: $err'),
        stack,
      );
    }
  }

  /// Locks the vault, clearing the authenticated state.
  void lock() {
    _logger.i('Vault locked');
    state = const AsyncValue.data(false);
  }

  /// Resets the notifier to its idle (locked) state.
  void reset() {
    state = const AsyncValue.data(false);
  }

  Future<void> _recordUnlock() async {
    try {
      final VaultConfig? config = await _configRepository.getConfig();
      final VaultConfig updated = (config ?? VaultConfig()).copyWith(
        lastUnlockAt: DateTime.now(),
        failedAttemptCount: 0,
      );
      await _configRepository.saveConfig(updated);
    } on Object catch (e, stackTrace) {
      _logger.w(
        'Failed to persist unlock timestamp',
        error: e,
        stackTrace: stackTrace,
      );
      // Non-fatal: auth succeeded even if persistence failed.
    }
  }
}

/// Provider that exposes the vault authentication state.
final StateNotifierProvider<VaultAuthNotifier, AsyncValue<bool>>
    vaultAuthStateProvider =
    StateNotifierProvider<VaultAuthNotifier, AsyncValue<bool>>((Ref ref) {
  return VaultAuthNotifier(
    securityService: VaultSecurityService.instance,
    configRepository: ref.watch(vaultConfigRepositoryProvider),
  );
});

// ─── Vault items provider ──────────────────────────────────────────────

/// Provider that loads vault bookmarks via the search infrastructure.
///
/// Uses the `in:vault` operator so vault items are positively selected.
/// Returns an empty list when the user is not authenticated — this is
/// the critical gate that prevents vault content from leaking before auth.
final FutureProvider<List<BookmarkItem>> vaultItemsProvider =
    FutureProvider<List<BookmarkItem>>((Ref ref) async {
  final AsyncValue<bool> authState = ref.watch(vaultAuthStateProvider);

  // Gate: never fetch vault content before successful authentication.
  final bool isAuthenticated = authState.valueOrNull ?? false;
  if (!isAuthenticated) {
    return <BookmarkItem>[];
  }

  final SearchBookmarksUseCase useCase = ref.watch(searchBookmarksUseCaseProvider);
  return useCase.execute(
    const SearchQuery(
      operators: <String, List<String>>{'in': <String>['vault']},
    ),
  );
});

// ─── Exception ─────────────────────────────────────────────────────────

/// Exception type for vault authentication failures.
///
/// Carries a user-facing message that can be displayed directly in UI.
class VaultAuthException implements Exception {
  /// Creates a [VaultAuthException] with the given [message].
  const VaultAuthException(this.message);

  /// Human-readable explanation of the failure.
  final String message;

  @override
  String toString() => 'VaultAuthException: $message';
}
