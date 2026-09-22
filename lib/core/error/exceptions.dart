class ServerException implements Exception {
  final String title;
  final String message;

  ServerException({required this.message, required this.title});

  // factory ServerException.fromJson(Map<String, dynamic>? json) {
  //   if (json != null && json.isNotEmpty) {
  //     return ServerException(message: json.toString(), title: 'Something went wrong');
  //     // return ServerException(message: json['data'], title: json['status']);
  //   } else {
  //     return ServerException(
  //         message: 'Something went wrong', title: 'Server Error');
  //   }
  // }

  factory ServerException.fromJson(dynamic responseBody) {
    try {
      if (responseBody is Map<String, dynamic>) {
        // errors ichidagi non_field_errors tekshirish
        if (responseBody.containsKey('errors') &&
            responseBody['errors'] is Map<String, dynamic>) {
          final errors = responseBody['errors'] as Map<String, dynamic>;

          if (errors.containsKey('non_field_errors')) {
            final nonFieldErrors = errors['non_field_errors'];
            final message = nonFieldErrors is List && nonFieldErrors.isNotEmpty
                ? nonFieldErrors.first.toString()
                : nonFieldErrors.toString();
            return ServerException(
              message: message,
              title: 'Xatolik',
            );
          }

          // boshqa field errorlarini tekshirish (email, password, etc.)
          final errorMessages = <String>[];
          errors.forEach((key, value) {
            if (value is List && value.isNotEmpty) {
              errorMessages.add(value.first.toString());
            } else {
              errorMessages.add(value.toString());
            }
          });

          if (errorMessages.isNotEmpty) {
            return ServerException(
              message: errorMessages.join('\n'),
              title: 'Xatolik',
            );
          }
        }

        // to'g'ridan-to'g'ri non_field_errors tekshirish
        if (responseBody.containsKey('non_field_errors')) {
          final errors = responseBody['non_field_errors'];
          final message = errors is List && errors.isNotEmpty
              ? errors.first.toString()
              : errors.toString();
          return ServerException(
            message: message,
            title: 'Xatolik',
          );
        }

        // detail field tekshirish
        if (responseBody.containsKey('detail')) {
          return ServerException(
            message: responseBody['detail'].toString(),
            title: 'Xatolik',
          );
        }

        // data va status fieldlari (eski variant)
        return ServerException(
          message: responseBody['data']?.toString() ?? responseBody.toString(),
          title: responseBody['status']?.toString() ?? 'Server Error',
        );
      } else if (responseBody is String) {
        // agar backend html yoki oddiy text qaytargan bo'lsa
        if (responseBody.trim().startsWith('<!DOCTYPE html>')) {
          return ServerException(
            message: 'Server returned HTML error page',
            title: 'Server Error',
          );
        }
        return ServerException(
          message: responseBody,
          title: 'Unexpected response',
        );
      } else {
        return ServerException(
          message: 'Unknown error format',
          title: 'Server Error',
        );
      }
    } catch (e) {
      return ServerException(
        message: 'Failed to parse server response: $e',
        title: 'Server Error',
      );
    }
  }

}

class NoInternetException implements Exception {}

class CacheException implements Exception {
  final String message;
  final String title;

  CacheException({required this.message, required this.title});

  @override
  String toString() {
    return message;
  }
}
