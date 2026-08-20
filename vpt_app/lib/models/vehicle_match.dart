class VehicleMatch {
  final int id;
  final int listingId;
  final double matchScore;
  final DateTime matchedAt;
  final String brand;
  final String model;
  final int year;
  final int mileage;
  final double price;
  final String? url;

  VehicleMatch({
    required this.id,
    required this.listingId,
    required this.matchScore,
    required this.matchedAt,
    required this.brand,
    required this.model,
    required this.year,
    required this.mileage,
    required this.price,
    this.url,
  });

  factory VehicleMatch.fromJson(Map<String, dynamic> json) {
    return VehicleMatch(
      id: json['id'] as int,
      listingId: json['listingId'] as int,
      matchScore: (json['matchScore'] as num).toDouble(),
      matchedAt: DateTime.parse(json['matchedAt'] as String),
      brand: json['brand'] as String,
      model: json['model'] as String,
      year: json['year'] as int,
      mileage: json['mileage'] as int,
      price: (json['price'] as num).toDouble(),
      url: json['url'] as String?,
    );
  }
}
