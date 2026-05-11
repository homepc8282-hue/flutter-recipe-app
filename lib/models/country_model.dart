class CountryModel {
  final String countryId;
  final String countryName;
  final String countryImage;

  CountryModel({
    required this.countryId,
    required this.countryName,
    required this.countryImage,
  });

  factory CountryModel.fromMap(Map<String, dynamic> map) {
    return CountryModel(
      countryId: map["countryId"] ?? "",
      countryName: map["countryName"] ?? "",
      countryImage: map["countryImage"] ?? "",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "countryId": countryId,
      "countryName": countryName,
      "countryImage": countryImage,
    };
  }
}
