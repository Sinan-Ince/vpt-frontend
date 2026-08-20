class VehicleSearch {
  final int id;
  final int userId;
  final String brand;
  final String model;
  final int year;
  final int? maxMileage;
  final double? maxPrice;
  final String? fuelType;

  VehicleSearch({
    required this.id,
    required this.userId,
    required this.brand,
    required this.model,
    required this.year,
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
      year: json['year'] as int,
      maxMileage: json['maxMileage'] as int?,
      maxPrice: (json['maxPrice'] as num?)?.toDouble(),
      fuelType: json['fuelType'] as String?,
    );
  }
}
