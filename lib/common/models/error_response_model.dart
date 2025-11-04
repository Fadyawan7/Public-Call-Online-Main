library;

class ErrorResponseModel {
  List<Errors>? _errors;

  List<Errors>? get errors => _errors;

  ErrorResponseModel({List<Errors>? errors}) {
    _errors = errors;
  }

  ErrorResponseModel.fromJson(dynamic json) {
    final data = json["errors"];

    if (data is List) {
      // ✅ Normal case
      _errors = data.map((v) => Errors.fromJson(v)).toList();
    } else if (data is Map) {
      // ⚙️ API returned a single object instead of a list
      _errors = [Errors.fromJson(data)];
    } else if (data is String) {
      // ⚙️ API returned just a string
      _errors = [Errors(message: data)];
    } else {
      _errors = [];
    }
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_errors != null) {
      map["errors"] = _errors!.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class Errors {
  String? _code;
  String? _message;

  String? get code => _code;
  String? get message => _message;

  Errors({String? code, String? message}) {
    _code = code;
    _message = message;
  }

  Errors.fromJson(dynamic json) {
    _code = json["code"]?.toString();
    _message = json["message"]?.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      "code": _code,
      "message": _message,
    };
  }
}
