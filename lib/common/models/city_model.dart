class CityModel {
  int? _id;
  String? _countryId;
  String? _cityName;

  CityModel(
      {int? id,
        String? countryName,
        String? countryId,

      }) {
    _id = id;
    _cityName = cityName;
    _countryId = countryId;
  }

  int? get id => _id;
  String? get cityName => _cityName;
  String? get countryId => _countryId;

  CityModel.fromJson(Map<String, dynamic> json) {
    _id = json['id'] ?? 0;
    _cityName = json['name'] ?? '';
    _countryId = json['country_id'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = _id;
    data['name'] = _cityName;
    data['country_id'] = _countryId;
    return data;
  }
}
