import 'package:flutter/material.dart';

class VehicleModelInfo {
  final String name;
  // Bu jenerasyonun üretime başladığı yıl — yıl seçicisinin alt sınırı.
  final int startYear;
  // Gerçek bir .glb dosyası eklenmemişse null — bu durumda ortak
  // placeholder (Khronos'un CC0 lisanslı "ToyCar" örnek modeli) gösterilir.
  final String? _realModelAsset;

  const VehicleModelInfo(this.name, this.startYear, {String? modelAsset})
      : _realModelAsset = modelAsset;

  String get modelAsset => _realModelAsset ?? _placeholderModelAsset;
}

const String _placeholderModelAsset = 'assets/vehicle_models/generic_car.glb';

// Backend'deki MockListingSource.Catalog ile eşleşiyor — buradaki
// marka/model çiftleri dışındaki seçimler hiçbir mock ilanla eşleşmez.
const Map<String, List<VehicleModelInfo>> vehicleCatalog = {
  'Toyota': [
    VehicleModelInfo(
      'Corolla',
      2017,
      modelAsset: 'assets/vehicle_models/toyota-corolla-e170-2017.glb',
    ),
    VehicleModelInfo('Yaris', 2020),
  ],
  'Volkswagen': [VehicleModelInfo('Golf', 2019), VehicleModelInfo('Passat', 2014)],
  'Renault': [VehicleModelInfo('Clio', 2019), VehicleModelInfo('Megane', 2016)],
  'Fiat': [VehicleModelInfo('Egea', 2015), VehicleModelInfo('Panda', 2011)],
  'Ford': [VehicleModelInfo('Focus', 2018), VehicleModelInfo('Fiesta', 2017)],
  'Honda': [VehicleModelInfo('Civic', 2016), VehicleModelInfo('CR-V', 2017)],
  'Hyundai': [VehicleModelInfo('i20', 2020), VehicleModelInfo('Tucson', 2020)],
  'Opel': [VehicleModelInfo('Astra', 2015), VehicleModelInfo('Corsa', 2019)],
};

const List<String> vehicleBrands = [
  'Toyota',
  'Volkswagen',
  'Renault',
  'Fiat',
  'Ford',
  'Honda',
  'Hyundai',
  'Opel',
];

// Yıl seçicisinin üst sınırı — en güncel model yılını temsil eder.
const int vehicleCatalogMaxYear = 2026;

const Map<String, String> _brandLogoAssetKeys = {
  'Toyota': 'toyota',
  'Volkswagen': 'volkswagen',
  'Renault': 'renault',
  'Fiat': 'fiat',
  'Ford': 'ford',
  'Honda': 'honda',
  'Hyundai': 'hyundai',
  'Opel': 'opel',
};

// Markaların gerçek logoları — Wikimedia Commons'tan indirilip
// assets/brand_logos/ altına SVG olarak gömüldü.
String brandLogoAsset(String brand) {
  final key = _brandLogoAssetKeys[brand];
  return 'assets/brand_logos/$key.svg';
}

const List<Color> _brandPalette = [
  Color(0xFFEF4444),
  Color(0xFF3B82F6),
  Color(0xFF10B981),
  Color(0xFFF59E0B),
  Color(0xFF8B5CF6),
  Color(0xFFEC4899),
  Color(0xFF06B6D4),
  Color(0xFF6366F1),
];

Color colorForBrand(String brand) {
  return _brandPalette[brand.hashCode.abs() % _brandPalette.length];
}
