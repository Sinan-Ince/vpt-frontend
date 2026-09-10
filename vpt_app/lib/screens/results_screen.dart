import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../api/api_client.dart';
import '../data/vehicle_catalog.dart';
import '../models/vehicle_match.dart';
import '../navigation/cinematic_route.dart';
import '../theme/app_theme.dart';
import '../widgets/cinematic_background.dart';
import '../widgets/glass_panel.dart';
import '../widgets/score_gauge.dart';
import '../widgets/staggered_fade_in.dart';
import 'notifications_screen.dart';
import 'search_screen.dart';

class ResultsScreen extends StatefulWidget {
  final int userId;
  final int searchId;
  // HomeScreen'den açıldığında verilir — üstteki marka logosunu ve
  // HomeScreen kartındaki logoyla aynı Hero geçişini gösterebilmek için.
  // SearchScreen'den (yeni arama) açıldığında da veriliyor ama orada
  // eşleşen bir kaynak Hero olmadığı için sadece statik görünür.
  final String? brand;

  const ResultsScreen({
    super.key,
    required this.userId,
    required this.searchId,
    this.brand,
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  final ApiClient _apiClient = ApiClient();
  final NumberFormat _numberFormat = NumberFormat.decimalPattern('tr_TR');

  late Future<List<VehicleMatch>> _matchesFuture;

  bool _isTracking = false;
  bool _isTrackingLoading = true;

  @override
  void initState() {
    super.initState();
    _matchesFuture = _apiClient.getMatches(widget.searchId);
    _loadTrackingStatus();
  }

  Future<void> _loadTrackingStatus() async {
    try {
      final tracking = await _apiClient.getTracking(widget.searchId);
      if (!mounted) return;
      setState(() {
        _isTracking = tracking.isActive;
        _isTrackingLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isTrackingLoading = false;
      });
    }
  }

  Future<void> _toggleTracking(bool value) async {
    setState(() {
      _isTrackingLoading = true;
    });

    try {
      final tracking = await _apiClient.setTracking(widget.searchId, value);
      if (!mounted) return;
      setState(() {
        _isTracking = tracking.isActive;
        _isTrackingLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isTrackingLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Takip güncellenemedi: $e')),
      );
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _matchesFuture = _apiClient.getMatches(widget.searchId);
    });
    await _matchesFuture;
  }

  Color _scoreColor(double score) {
    if (score >= 70) return const Color(0xFF4ADE80);
    if (score >= 40) return AppTheme.accentColor;
    return AppTheme.errorColor;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eşleşmeler'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                cinematicRoute(NotificationsScreen(searchId: widget.searchId)),
              );
            },
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'Bildirimler',
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                cinematicRoute(SearchScreen(userId: widget.userId)),
              );
            },
            icon: const Icon(Icons.add),
            tooltip: 'Yeni arama',
          ),
        ],
      ),
      body: CinematicBackground(
        child: Column(
          children: [
            if (widget.brand != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: Row(
                  children: [
                    Hero(
                      tag: 'brand-logo-${widget.searchId}',
                      child: Container(
                        width: 52,
                        height: 52,
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: SvgPicture.asset(
                          brandLogoAsset(widget.brand!),
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.directions_car_outlined),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(widget.brand!, style: Theme.of(context).textTheme.titleLarge),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
              child: GlassPanel(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Bu aramayı canlı takibe al'),
                  subtitle: const Text(
                    'Yeni bir eşleşme çıktığında bildirim oluşturulur',
                    style: TextStyle(color: Colors.white54),
                  ),
                  value: _isTracking,
                  onChanged: _isTrackingLoading ? null : _toggleTracking,
                  secondary: _isTrackingLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          _isTracking
                              ? Icons.notifications_active
                              : Icons.notifications_none,
                          color: _isTracking ? AppTheme.accentColor : Colors.white54,
                        ),
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: FutureBuilder<List<VehicleMatch>>(
                  future: _matchesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return ListView(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              'Hata: ${snapshot.error}',
                              style: TextStyle(color: AppTheme.errorColor),
                            ),
                          ),
                        ],
                      );
                    }

                    final matches = snapshot.data ?? [];

                    if (matches.isEmpty) {
                      return ListView(
                        children: const [
                          Padding(
                            padding: EdgeInsets.all(32),
                            child: Center(
                              child: Text('Bu arama için henüz bir eşleşme yok.'),
                            ),
                          ),
                        ],
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 6, 12, 24),
                      itemCount: matches.length,
                      itemBuilder: (context, index) {
                        final match = matches[index];
                        final color = _scoreColor(match.matchScore);
                        return StaggeredFadeIn(
                          index: index,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: GlassPanel(
                              glowColor: color,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  ScoreGauge(score: match.matchScore, color: color),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${match.brand} ${match.model} (${match.year})',
                                          style: Theme.of(context).textTheme.titleMedium,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${_numberFormat.format(match.mileage)} km  •  '
                                          '${_numberFormat.format(match.price)} TL',
                                          style: const TextStyle(color: Colors.white54),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
