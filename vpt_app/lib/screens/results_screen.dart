import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../api/api_client.dart';
import '../models/vehicle_match.dart';
import 'notifications_screen.dart';
import 'search_screen.dart';

class ResultsScreen extends StatefulWidget {
  final int userId;
  final int searchId;

  const ResultsScreen({
    super.key,
    required this.userId,
    required this.searchId,
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
    if (score >= 70) return Colors.green;
    if (score >= 40) return Colors.orange;
    return Colors.red;
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
                MaterialPageRoute(
                  builder: (context) =>
                      NotificationsScreen(searchId: widget.searchId),
                ),
              );
            },
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'Bildirimler',
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => SearchScreen(userId: widget.userId),
                ),
              );
            },
            icon: const Icon(Icons.add),
            tooltip: 'Yeni arama',
          ),
        ],
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(12),
            child: SwitchListTile(
              title: const Text('Bu aramayı canlı takibe al'),
              subtitle: const Text(
                'Yeni bir eşleşme çıktığında bildirim oluşturulur',
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
                            style: const TextStyle(color: Colors.red),
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
                    itemCount: matches.length,
                    itemBuilder: (context, index) {
                      final match = matches[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _scoreColor(match.matchScore),
                            child: Text(
                              '${match.matchScore.round()}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            '${match.brand} ${match.model} (${match.year})',
                          ),
                          subtitle: Text(
                            '${_numberFormat.format(match.mileage)} km  •  '
                            '${_numberFormat.format(match.price)} TL',
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
    );
  }
}
