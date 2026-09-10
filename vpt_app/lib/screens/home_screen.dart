import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../api/api_client.dart';
import '../data/vehicle_catalog.dart';
import '../models/tracked_vehicle.dart';
import '../navigation/cinematic_route.dart';
import '../services/session_store.dart';
import '../theme/app_theme.dart';
import '../widgets/cinematic_background.dart';
import '../widgets/count_up_text.dart';
import '../widgets/glass_panel.dart';
import '../widgets/staggered_fade_in.dart';
import 'login_screen.dart';
import 'results_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  final int userId;

  const HomeScreen({super.key, required this.userId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiClient _apiClient = ApiClient();
  final SessionStore _sessionStore = SessionStore();

  late Future<List<TrackedVehicle>> _trackedFuture;

  @override
  void initState() {
    super.initState();
    _trackedFuture = _apiClient.getTrackedVehicles(widget.userId);
  }

  Future<void> _refresh() async {
    setState(() {
      _trackedFuture = _apiClient.getTrackedVehicles(widget.userId);
    });
    await _trackedFuture;
  }

  Future<void> _openSearch() async {
    await Navigator.of(
      context,
    ).push(cinematicRoute(SearchScreen(userId: widget.userId)));
    _refresh();
  }

  Future<void> _openResults(TrackedVehicle tracked) async {
    await Navigator.of(context).push(
      cinematicRoute(
        ResultsScreen(
          userId: widget.userId,
          searchId: tracked.vehicleSearchId,
          brand: tracked.brand,
        ),
      ),
    );
    _refresh();
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
        title: const Text('Canlı Takiplerim'),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Çıkış yap',
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openSearch,
        backgroundColor: AppTheme.accentColor,
        foregroundColor: AppTheme.onAccentColor,
        icon: const Icon(Icons.search),
        label: const Text('Araç Ara'),
      ),
      body: CinematicBackground(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: FutureBuilder<List<TrackedVehicle>>(
              future: _trackedFuture,
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

                final tracked = snapshot.data ?? [];

                if (tracked.isEmpty) {
                  return ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(32, 96, 32, 32),
                        child: Column(
                          children: [
                            Icon(
                              Icons.notifications_none,
                              size: 48,
                              color: Colors.white.withValues(alpha: 0.4),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Henüz canlı takibe aldığın bir araç yok.',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Sağ alttaki "Araç Ara" butonuyla arama yapıp '
                              'sonuçlardan bir aracı canlı takibe alabilirsin.',
                              textAlign: TextAlign.center,
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(color: Colors.white54),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }

                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 88, 16, 96),
                  children: [
                    RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.titleMedium,
                        children: [
                          const TextSpan(text: 'Aktif takip: '),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.baseline,
                            baseline: TextBaseline.alphabetic,
                            child: CountUpText(
                              value: tracked.length,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppTheme.accentColor,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    for (final (index, item) in tracked.indexed)
                      StaggeredFadeIn(
                        index: index,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _TrackedVehicleCard(
                            item: item,
                            onTap: () => _openResults(item),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _TrackedVehicleCard extends StatelessWidget {
  final TrackedVehicle item;
  final VoidCallback onTap;

  const _TrackedVehicleCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final brandColor = colorForBrand(item.brand);

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: GlassPanel(
        glowColor: brandColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Hero(
              tag: 'brand-logo-${item.vehicleSearchId}',
              child: Container(
                width: 52,
                height: 52,
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(
                  brandLogoAsset(item.brand),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.directions_car_outlined),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${item.brand} ${item.model}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.minYear == item.maxYear
                        ? '${item.minYear}'
                        : '${item.minYear}–${item.maxYear}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.white54),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.matchCount > 0
                        ? '${item.matchCount} eşleşme bulundu'
                        : 'Henüz eşleşme yok',
                    style: TextStyle(
                      color: item.matchCount > 0 ? brandColor : Colors.white38,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white38),
          ],
        ),
      ),
    );
  }
}
