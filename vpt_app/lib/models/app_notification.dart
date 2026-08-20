// Flutter'ın kendi 'Notification' sınıfıyla (widget bildirimleri) çakışmaması
// için bu modele AppNotification adı verildi.
class AppNotification {
  final int id;
  final String message;
  final DateTime createdAt;
  final int listingId;
  final String brand;
  final String model;
  final int year;
  final double price;
  final String? url;

  AppNotification({
    required this.id,
    required this.message,
    required this.createdAt,
    required this.listingId,
    required this.brand,
    required this.model,
    required this.year,
    required this.price,
    this.url,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as int,
      message: json['message'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      listingId: json['listingId'] as int,
      brand: json['brand'] as String,
      model: json['model'] as String,
      year: json['year'] as int,
      price: (json['price'] as num).toDouble(),
      url: json['url'] as String?,
    );
  }
}
