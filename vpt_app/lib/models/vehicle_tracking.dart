class VehicleTracking {
  final int vehicleSearchId;
  final bool isActive;
  final DateTime? lastCheckedAt;
  final DateTime? nextCheckAt;

  VehicleTracking({
    required this.vehicleSearchId,
    required this.isActive,
    this.lastCheckedAt,
    this.nextCheckAt,
  });

  factory VehicleTracking.fromJson(Map<String, dynamic> json) {
    return VehicleTracking(
      vehicleSearchId: json['vehicleSearchId'] as int,
      isActive: json['isActive'] as bool,
      lastCheckedAt: json['lastCheckedAt'] == null
          ? null
          : DateTime.parse(json['lastCheckedAt'] as String),
      nextCheckAt: json['nextCheckAt'] == null
          ? null
          : DateTime.parse(json['nextCheckAt'] as String),
    );
  }
}
