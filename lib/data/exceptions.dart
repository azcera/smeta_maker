import 'package:flutter/material.dart';

/// Custom exceptions for better error handling and debugging
class SmetaException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const SmetaException(this.message, {this.code, this.originalError});

  @override
  String toString() {
    if (code != null) {
      return 'SmetaException [$code]: $message';
    }
    return 'SmetaException: $message';
  }
}

/// Specific exceptions for different operations
class FileOperationException extends SmetaException {
  const FileOperationException(
    super.message, {
    super.code,
    super.originalError,
  });
}

class ValidationException extends SmetaException {
  const ValidationException(super.message, {super.code, super.originalError});
}

class NetworkException extends SmetaException {
  const NetworkException(super.message, {super.code, super.originalError});
}

/// Error handling utilities
class ErrorHandler {
  /// Logs error and returns user-friendly message
  static String handleError(dynamic error, {String? fallbackMessage}) {
    String message = fallbackMessage ?? 'Произошла неизвестная ошибка';

    if (error is SmetaException) {
      message = error.message;
    } else if (error is Exception) {
      message = error.toString();
    }

    // Log error for debugging
    print('Error: $error');

    return message;
  }

  /// Shows error dialog to user
  static void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ошибка'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
