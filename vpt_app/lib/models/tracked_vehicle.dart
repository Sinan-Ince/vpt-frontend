class TrackedVehicle {
  final int vehicleSearchId;
  final String brand;
  final String model;
  final int year;
  final int? maxMileage;
  final double? maxPrice;
  final String? fuelType;
  final DateTime? lastCheckedAt;
  final DateTime? nextCheckAt;
  final int matchCount;

  TrackedVehicle({
    required this.vehicleSearchId,
    required this.brand,
    required this.model,
    required this.year,
    this.maxMileage,
    this.maxPrice,
    this.fuelType,
    this.lastCheckedAt,
    this.nextCheckAt,
    required this.matchCount,
  });

  factory TrackedVehicle.fromJson(Map<String, dynamic> json) {
    return TrackedVehicle(
      vehicleSearchId: json['vehicleSearchId'] as int,
      brand: json['brand'] as String,
      model: json['model'] as String,
      year: json['year'] as int,
      maxMileage: json['maxMileage'] as int?,
      maxPrice: (json['maxPrice'] as num?)?.toDouble(),
      fuelType: json['fuelType'] as String?,
      lastCheckedAt: json['lastCheckedAt'] == null
          ? null
          : DateTime.parse(json['lastCheckedAt'] as String),
      nextCheckAt: json['nextCheckAt'] == null
          ? null
          : DateTime.parse(json['nextCheckAt'] as String),
      matchCount: json['matchCount'] as int,
    );
  }
}
