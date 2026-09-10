import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../data/vehicle_catalog.dart';
import 'swipeable_card_selector.dart';
import 'vehicle_viewer.dart';

class VehicleSelection {
  final String brand;
  final String model;
  final int minYear;
  final int maxYear;

  const VehicleSelection({
    required this.brand,
    required this.model,
    required this.minYear,
    required this.maxYear,
  });
}

class BrandModelYearPicker extends StatefulWidget {
  final ValueChanged<VehicleSelection> onChanged;

  const BrandModelYearPicker({super.key, required this.onChanged});

  @override
  State<BrandModelYearPicker> createState() => _BrandModelYearPickerState();
}

class _BrandModelYearPickerState extends State<BrandModelYearPicker> {
  int _brandIndex = 0;
  int _modelIndex = 0;
  int _selectedMinYear = vehicleCatalogMaxYear;
  int _selectedMaxYear = vehicleCatalogMaxYear;

  List<VehicleModelInfo> get _models =>
      vehicleCatalog[vehicleBrands[_brandIndex]]!;

  VehicleModelInfo get _selectedModel => _models[_modelIndex];

  void _notify() {
    widget.onChanged(
      VehicleSelection(
        brand: vehicleBrands[_brandIndex],
        model: _selectedModel.name,
        minYear: _selectedMinYear,
        maxYear: _selectedMaxYear,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _selectedMinYear = _selectedModel.startYear;
    WidgetsBinding.instance.addPostFrameCallback((_) => _notify());
  }

  void _clampYearRangeToSelectedModel() {
    final floor = _selectedModel.startYear;
    if (_selectedMinYear < floor) _selectedMinYear = floor;
    if (_selectedMaxYear < floor) _selectedMaxYear = floor;
    if (_selectedMinYear > vehicleCatalogMaxYear) {
      _selectedMinYear = vehicleCatalogMaxYear;
    }
    if (_selectedMaxYear > vehicleCatalogMaxYear) {
      _selectedMaxYear = vehicleCatalogMaxYear;
    }
    if (_selectedMinYear > _selectedMaxYear) {
      _selectedMinYear = _selectedMaxYear;
    }
  }

  void _onBrandChanged(int index) {
    setState(() {
      _brandIndex = index;
      _modelIndex = 0;
      _clampYearRangeToSelectedModel();
    });
    _notify();
  }

  void _onModelChanged(int index) {
    setState(() {
      _modelIndex = index;
      _clampYearRangeToSelectedModel();
    });
    _notify();
  }

  Widget _buildBrandCard(BuildContext context, String brand) {
    final color = colorForBrand(brand);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 96,
          height: 96,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: SvgPicture.asset(
            brandLogoAsset(brand),
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  brand.substring(0, 1),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          brand,
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Model'in görseli artık yukarıdaki büyük 3D önizlemede gösterildiği
  // için bu kart sadece isim/seçim amaçlı — küçük bir "chip" gibi.
  Widget _buildModelCard(BuildContext context, VehicleModelInfo model) {
    final color = colorForBrand(vehicleBrands[_brandIndex]);
    final isSelected = model.name == _selectedModel.name;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: isSelected ? color.withValues(alpha: 0.14) : null,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? color : Colors.grey.withValues(alpha: 0.3),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Text(
        model.name,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? color : null,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final modelFloorYear = _selectedModel.startYear;
    final catalogMaxYear = vehicleCatalogMaxYear;
    final hasYearRange = catalogMaxYear > modelFloorYear;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Marka', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 4),
        Text(
          'Kaydırarak markanı seç',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        SwipeableCardSelector<String>(
          items: vehicleBrands,
          selectedIndex: _brandIndex,
          onSelected: _onBrandChanged,
          itemBuilder: _buildBrandCard,
          height: 150,
        ),
        const SizedBox(height: 20),
        Text('Model', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 4),
        Text(
          'Kaydırarak modelini seç',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        SwipeableCardSelector<VehicleModelInfo>(
          // Marka değişince model listesi de değiştiği için key şart —
          // yoksa PageView eski sayfa indeksini yeni (daha kısa) listeye
          // uygulamaya çalışıp hataya düşebilir.
          key: ValueKey(_brandIndex),
          items: _models,
          selectedIndex: _modelIndex,
          onSelected: _onModelChanged,
          itemBuilder: _buildModelCard,
          height: 70,
        ),
        const SizedBox(height: 16),
        VehicleViewer(
          assetPath: _selectedModel.modelAsset,
          alt: '${vehicleBrands[_brandIndex]} ${_selectedModel.name} 3D model',
          height: 380,
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              Icons.info_outline,
              size: 14,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                'Yer tutucu 3D model — gerçek marka/model modelleri eklenene kadar tüm araçlar bu genel modeli gösterir. Sürükleyerek döndürebilirsin.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Yıl aralığı', style: Theme.of(context).textTheme.labelLarge),
            Text(
              '$_selectedMinYear – $_selectedMaxYear',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorForBrand(vehicleBrands[_brandIndex]),
              ),
            ),
          ],
        ),
        Text(
          '${_selectedModel.name}, $modelFloorYear\'ten beri üretiliyor',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        RangeSlider(
          // Model değişince (farklı bir başlangıç yılı varsa) key
          // değişmeli, yoksa RangeSlider eski min/max aralığından
          // türetilmiş bir değeri yeni aralığa uygulamaya çalışıp hata
          // verebilir.
          key: ValueKey('${_brandIndex}_$_modelIndex'),
          values: RangeValues(
            _selectedMinYear.toDouble(),
            _selectedMaxYear.toDouble(),
          ),
          min: modelFloorYear.toDouble(),
          max: catalogMaxYear.toDouble(),
          divisions: hasYearRange ? catalogMaxYear - modelFloorYear : null,
          labels: RangeLabels('$_selectedMinYear', '$_selectedMaxYear'),
          onChanged: hasYearRange
              ? (values) {
                  setState(() {
                    _selectedMinYear = values.start.round();
                    _selectedMaxYear = values.end.round();
                  });
                  _notify();
                }
              : null,
        ),
      ],
    );
  }
}
