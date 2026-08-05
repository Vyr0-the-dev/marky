/// Base application exception with optional user-facing message.
class AppException implements Exception {
  /// Creates an [AppException].
  const AppException({
    this.message,
    this.code,
    this.cause,
  });

  /// Human-readable error message.
  final String? message;

  /// Optional error code for categorization.
  final String? code;

  /// Underlying cause of this exception.
  final Object? cause;

  @override
  String toString() {
    final StringBuffer buffer = StringBuffer('AppException');
    if (code != null) buffer.write(' [$code]');
    if (message != null) buffer.write(': $message');
    if (cause != null) buffer.write(' (caused by $cause)');
    return buffer.toString();
  }
}

/// Exception thrown when a database operation fails.
class DatabaseException extends AppException {
  /// Creates a [DatabaseException].
  const DatabaseException({super.message, super.cause})
      : super(code: 'DATABASE_ERROR');
}

/// Exception thrown when a network operation fails.
class NetworkException extends AppException {
  /// Creates a [NetworkException].
  const NetworkException({super.message, super.cause})
      : super(code: 'NETWORK_ERROR');
}

/// Exception thrown when a scraping operation fails.
class ScrapingException extends AppException {
  /// Creates a [ScrapingException].
  const ScrapingException({super.message, super.cause})
      : super(code: 'SCRAPING_ERROR');
}

/// Exception thrown when vault security check fails.
class VaultException extends AppException {
  /// Creates a [VaultException].
  const VaultException({super.message, super.cause})
      : super(code: 'VAULT_ERROR');
}
