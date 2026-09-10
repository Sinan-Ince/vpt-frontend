import 'package:flutter/material.dart';

import '../api/api_client.dart';
import '../navigation/cinematic_route.dart';
import '../services/session_store.dart';
import '../theme/app_theme.dart';
import '../widgets/brand_model_year_picker.dart';
import '../widgets/cinematic_background.dart';
import '../widgets/glass_panel.dart';
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

  final _maxMileageController = TextEditingController();
  final _maxPriceController = TextEditingController();
  final _fuelTypeController = TextEditingController();

  VehicleSelection? _vehicleSelection;
  bool _isSubmitting = false;
  bool _showAdvanced = false;
  String? _errorMessage;

  @override
  void dispose() {
    _maxMileageController.dispose();
    _maxPriceController.dispose();
    _fuelTypeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _vehicleSelection == null) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final selection = _vehicleSelection!;
      final search = await _apiClient.createVehicleSearch(
        userId: widget.userId,
        brand: selection.brand,
        model: selection.model,
        minYear: selection.minYear,
        maxYear: selection.maxYear,
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
        cinematicRoute(
          ResultsScreen(
            userId: widget.userId,
            searchId: search.id,
            brand: selection.brand,
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

    Navigator.of(
      context,
    ).pushAndRemoveUntil(cinematicRoute(const LoginScreen()), (route) => false);
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
      body: CinematicBackground(
        child: Center(
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
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.white54),
                ),
                const SizedBox(height: 16),
                GlassPanel(
                  glowColor: AppTheme.accentColor,
                  padding: const EdgeInsets.all(18),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        BrandModelYearPicker(
                          onChanged: (selection) {
                            _vehicleSelection = selection;
                          },
                        ),
                        const SizedBox(height: 16),
                        InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () => setState(() => _showAdvanced = !_showAdvanced),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.tune,
                                  size: 18,
                                  color: Colors.white54,
                                ),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'Diğer tercihler (opsiyonel)',
                                    style: TextStyle(color: Colors.white54),
                                  ),
                                ),
                                AnimatedRotation(
                                  turns: _showAdvanced ? 0.5 : 0,
                                  duration: const Duration(milliseconds: 250),
                                  child: const Icon(
                                    Icons.expand_more,
                                    color: Colors.white54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOutCubic,
                          child: _showAdvanced
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
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
                                        if (value == null || value.trim().isEmpty) {
                                          return null;
                                        }
                                        if (int.tryParse(value.trim()) == null) {
                                          return 'Geçerli bir sayı gir';
                                        }
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
                                        if (value == null || value.trim().isEmpty) {
                                          return null;
                                        }
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
                                  ],
                                )
                              : const SizedBox(width: double.infinity),
                        ),
                        const SizedBox(height: 20),
                        if (_errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(color: AppTheme.errorColor),
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
                                    color: AppTheme.onAccentColor,
                                  ),
                                )
                              : const Icon(Icons.search),
                          label: const Text('Ara'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
