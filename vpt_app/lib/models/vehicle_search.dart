class VehicleSearch {
  final int id;
  final int userId;
  final String brand;
  final String model;
  final int minYear;
  final int maxYear;
  final int? maxMileage;
  final double? maxPrice;
  final String? fuelType;

  VehicleSearch({
    required this.id,
    required this.userId,
    required this.brand,
    required this.model,
    required this.minYear,
    required this.maxYear,
    this.maxMileage,
    this.maxPrice,
    this.fuelType,
  });

  factory VehicleSearch.fromJson(Map<String, dynamic> json) {
    return VehicleSearch(
      id: json['id'] as int,
      userId: json['userId'] as int,
      brand: json['brand'] as String,
      model: json['model'] as String,
      minYear: json['minYear'] as int,
      maxYear: json['maxYear'] as int,
      maxMileage: json['maxMileage'] as int?,
      maxPrice: (json['maxPrice'] as num?)?.toDouble(),
      fuelType: json['fuelType'] as String?,
    );
  }
}
