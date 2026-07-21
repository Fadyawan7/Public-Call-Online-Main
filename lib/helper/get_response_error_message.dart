String getErrorMessage(dynamic responseBody) {
  if (responseBody is Map) {
    final errors = responseBody['errors'];

    if (errors is Map && errors.isNotEmpty) {
      final firstError = errors.values.first;
      return firstError?.toString() ?? 'An error occurred';
    }

    if (errors is List && errors.isNotEmpty) {
      return errors.first?.toString() ?? 'An error occurred';
    }

    final message = responseBody['message'];
    if (message != null && message.toString().isNotEmpty) {
      return message.toString();
    }

    return 'An error occurred';
  }

  if (responseBody is List && responseBody.isNotEmpty) {
    return responseBody.first?.toString() ?? 'An error occurred';
  }

  if (responseBody != null && responseBody.toString().isNotEmpty) {
    return responseBody.toString();
  }

  return 'An error occurred';
}
