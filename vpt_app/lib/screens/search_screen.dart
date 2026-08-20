import 'package:flutter/material.dart';

import '../api/api_client.dart';
import '../services/session_store.dart';
import 'login_screen.dart';
import 'results_screen.dart';

class SearchScreen extends StatefulWidget {
  final int userId;

  const SearchScreen({super.key, required this.userId});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiClient _apiClient = ApiClient();
  final SessionStore _sessionStore = SessionStore();

  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _maxMileageController = TextEditingController();
  final _maxPriceController = TextEditingController();
  final _fuelTypeController = TextEditingController();

  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _maxMileageController.dispose();
    _maxPriceController.dispose();
    _fuelTypeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final search = await _apiClient.createVehicleSearch(
        userId: widget.userId,
        brand: _brandController.text.trim(),
        model: _modelController.text.trim(),
        year: int.parse(_yearController.text.trim()),
        maxMileage: _maxMileageController.text.trim().isEmpty
            ? null
            : int.parse(_maxMileageController.text.trim()),
        maxPrice: _maxPriceController.text.trim().isEmpty
            ? null
            : double.parse(_maxPriceController.text.trim()),
        fuelType: _fuelTypeController.text.trim().isEmpty
            ? null
            : _fuelTypeController.text.trim(),
      );

      if (!mounted) return;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ResultsScreen(
            userId: widget.userId,
            searchId: search.id,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    await _sessionStore.clear();

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Araç Arama'),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Çıkış yap',
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Aradığın aracın özelliklerini gir',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'İlanlar bulunan araçları yüzdelik uyum sırasına göre listeleyeceğiz.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _brandController,
                          decoration: const InputDecoration(
                            labelText: 'Marka',
                            prefixIcon: Icon(Icons.directions_car_outlined),
                          ),
                          textInputAction: TextInputAction.next,
                          validator: (value) => (value == null || value.trim().isEmpty)
                              ? 'Marka zorunlu'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _modelController,
                          decoration: const InputDecoration(
                            labelText: 'Model',
                            prefixIcon: Icon(Icons.style_outlined),
                          ),
                          textInputAction: TextInputAction.next,
                          validator: (value) => (value == null || value.trim().isEmpty)
                              ? 'Model zorunlu'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _yearController,
                          decoration: const InputDecoration(
                            labelText: 'Yıl',
                            prefixIcon: Icon(Icons.calendar_today_outlined),
                          ),
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) return 'Yıl zorunlu';
                            if (int.tryParse(value.trim()) == null) return 'Geçerli bir yıl gir';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _maxMileageController,
                          decoration: const InputDecoration(
                            labelText: 'Maksimum km (opsiyonel)',
                            prefixIcon: Icon(Icons.speed_outlined),
                          ),
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) return null;
                            if (int.tryParse(value.trim()) == null) return 'Geçerli bir sayı gir';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _maxPriceController,
                          decoration: const InputDecoration(
                            labelText: 'Maksimum fiyat (opsiyonel)',
                            prefixIcon: Icon(Icons.payments_outlined),
                            suffixText: 'TL',
                          ),
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) return null;
                            if (double.tryParse(value.trim()) == null) {
                              return 'Geçerli bir sayı gir';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _fuelTypeController,
                          decoration: const InputDecoration(
                            labelText: 'Yakıt tipi (opsiyonel)',
                            prefixIcon: Icon(Icons.local_gas_station_outlined),
                          ),
                          textInputAction: TextInputAction.done,
                        ),
                        const SizedBox(height: 20),
                        if (_errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        FilledButton.icon(
                          onPressed: _isSubmitting ? null : _submit,
                          icon: _isSubmitting
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.search),
                          label: const Text('Ara'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
