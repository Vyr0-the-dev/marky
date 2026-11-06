import 'package:flutter/material.dart';

import 'package:marky/shared/errors/safe_error_details.dart';
import 'package:marky/shared/widgets/marky_error_state.dart';

class MarkyErrorBoundary extends StatelessWidget {
  const MarkyErrorBoundary({
    this.error,
    this.stackTrace,
    super.key,
  });

  final Object? error;
  final StackTrace? stackTrace;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        child: MarkyErrorState(
          title: 'Something went wrong',
          body: 'Marky kept running. You can retry or reopen this screen.',
          detail: debugOnlyErrorDetails(error, stackTrace: stackTrace),
        ),
      ),
    );
  }
}
