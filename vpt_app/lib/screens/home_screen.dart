import 'package:flutter/material.dart';

import '../api/api_client.dart';
import '../models/tracked_vehicle.dart';
import '../services/session_store.dart';
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
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SearchScreen(userId: widget.userId),
      ),
    );
    _refresh();
  }

  Future<void> _openResults(TrackedVehicle tracked) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ResultsScreen(
          userId: widget.userId,
          searchId: tracked.vehicleSearchId,
        ),
      ),
    );
    _refresh();
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
        title: const Text('Canlı Takiplerim'),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Çıkış yap',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openSearch,
        icon: const Icon(Icons.search),
        label: const Text('Araç Ara'),
      ),
      body: RefreshIndicator(
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
                      style: const TextStyle(color: Colors.red),
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
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.notifications_none,
                          size: 48,
                          color: Theme.of(context).colorScheme.outline,
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
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            return ListView(
              padding: const EdgeInsets.only(bottom: 96),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: Text(
                    'Aktif takip: ${tracked.length}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                for (final item in tracked)
                  Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.directions_car_outlined),
                      ),
                      title: Text('${item.brand} ${item.model} (${item.year})'),
                      subtitle: Text(
                        item.matchCount > 0
                            ? '${item.matchCount} eşleşme bulundu'
                            : 'Henüz eşleşme yok',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _openResults(item),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
