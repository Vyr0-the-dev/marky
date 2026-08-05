import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:marky/app/theme/app_colors.dart';
import 'package:marky/app/theme/app_shapes.dart';
import 'package:marky/app/theme/app_typography.dart';
import 'package:marky/features/vault/presentation/providers/vault_providers.dart';

/// The sole gate to vault content.
///
/// Triggers biometric authentication on first build. Displays a
/// pitch-black luxury lock screen while idle, a loading indicator
/// during auth, and navigates to [VaultFeedScreen] on success.
///
/// Error states (unavailable biometrics, user cancellation, or
/// unexpected failures) are surfaced with explicit messaging and
/// a retry affordance.
class VaultAuthScreen extends ConsumerStatefulWidget {
  /// Creates the [VaultAuthScreen].
  const VaultAuthScreen({super.key});

  @override
  ConsumerState<VaultAuthScreen> createState() => _VaultAuthScreenState();
}

class _VaultAuthScreenState extends ConsumerState<VaultAuthScreen> {
  bool _hasAttemptedAuth = false;

  @override
  void initState() {
    super.initState();
    // Defer the auth attempt to the next frame so the widget tree is
    // fully mounted before any provider mutations trigger rebuilds.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _attemptAuth();
    });
  }

  void _attemptAuth() {
    if (_hasAttemptedAuth) return;
    _hasAttemptedAuth = true;
    ref.read(vaultAuthStateProvider.notifier).authenticate();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(vaultAuthStateProvider, (AsyncValue<bool>? previous, AsyncValue<bool> next) {
      next.whenOrNull(
        data: (bool isAuthenticated) {
          if (isAuthenticated) {
            context.go('/vault/feed');
          }
        },
      );
    });

    final AsyncValue<bool> authState = ref.watch(vaultAuthStateProvider);

    return Scaffold(
      backgroundColor: AppColors.base,
      body: SafeArea(
        child: authState.when(
          loading: () => const _LoadingState(),
          error: (Object error, StackTrace? _) => _ErrorState(
            error: error,
            onRetry: _attemptAuth,
          ),
          data: (bool isAuthenticated) {
            if (isAuthenticated) {
              // Navigation is handled by ref.listen; show a brief
              // transition state to avoid a flash of the idle UI.
              return const _LoadingState();
            }
            return _IdleState(onUnlock: _attemptAuth);
          },
        ),
      ),
    );
  }
}

// ─── Sub-states ────────────────────────────────────────────────────────

/// Idle lock screen shown before authentication is attempted or after
/// an explicit lock action.
class _IdleState extends StatelessWidget {
  const _IdleState({required this.onUnlock});

  final VoidCallback onUnlock;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppShapes.screenPaddingInsets,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Lock icon with luxe accent ring
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.surface2,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.accentLuxe.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.lock_outline,
                size: 40,
                color: AppColors.accentLuxe,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Vault',
              style: AppTypography.display.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your most sensitive bookmarks, protected.',
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            _UnlockButton(onTap: onUnlock),
          ],
        ),
      ),
    );
  }
}

/// Loading state shown while the biometric prompt is active.
class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.accentLuxe,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Authenticating...',
            style: AppTypography.body,
          ),
        ],
      ),
    );
  }
}

/// Error state with a retry affordance.
class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.error,
    required this.onRetry,
  });

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final String message = error is VaultAuthException
        ? (error as VaultAuthException).message
        : 'Something went wrong. Please try again.';

    return Center(
      child: Padding(
        padding: AppShapes.screenPaddingInsets,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(
              Icons.error_outline,
              size: 56,
              color: AppColors.danger,
            ),
            const SizedBox(height: 24),
            Text(
              'Authentication Failed',
              style: AppTypography.sectionTitle.copyWith(fontSize: 20),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: AppTypography.body,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _UnlockButton(onTap: onRetry),
          ],
        ),
      ),
    );
  }
}

// ─── Shared widgets ────────────────────────────────────────────────────

/// Primary unlock action button used in both idle and error states.
class _UnlockButton extends StatelessWidget {
  const _UnlockButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.accentLuxe.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(AppShapes.radiusStandard),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppShapes.radiusStandard),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 32,
            vertical: 16,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.fingerprint,
                color: AppColors.accentLuxe,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                'Unlock with Biometrics',
                style: AppTypography.label.copyWith(
                  color: AppColors.accentLuxe,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
