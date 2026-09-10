import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../api/api_client.dart';
import '../models/app_notification.dart';
import '../theme/app_theme.dart';
import '../widgets/cinematic_background.dart';
import '../widgets/glass_panel.dart';
import '../widgets/staggered_fade_in.dart';

class NotificationsScreen extends StatefulWidget {
  final int searchId;

  const NotificationsScreen({super.key, required this.searchId});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final ApiClient _apiClient = ApiClient();
  final NumberFormat _priceFormat = NumberFormat.decimalPattern('tr_TR');

  late Future<List<AppNotification>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _notificationsFuture = _apiClient.getNotifications(widget.searchId);
  }

  void _refresh() {
    setState(() {
      _notificationsFuture = _apiClient.getNotifications(widget.searchId);
    });
  }

  String _relativeTime(DateTime dateTime) {
    final diff = DateTime.now().toUtc().difference(dateTime.toUtc());

    if (diff.inMinutes < 1) return 'az önce';
    if (diff.inMinutes < 60) return '${diff.inMinutes} dakika önce';
    if (diff.inHours < 24) return '${diff.inHours} saat önce';
    return '${diff.inDays} gün önce';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirimler'),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
            tooltip: 'Yenile',
          ),
        ],
      ),
      body: CinematicBackground(
        child: RefreshIndicator(
          onRefresh: () async => _refresh(),
          child: FutureBuilder<List<AppNotification>>(
            future: _notificationsFuture,
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

              final notifications = snapshot.data ?? [];

              if (notifications.isEmpty) {
                return ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Text(
                          'Henüz bir bildirim yok.\nCanlı takibi açıp biraz bekleyin — '
                          'yeni bir eşleşme çıktığında burada görünecek.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white54),
                        ),
                      ),
                    ),
                  ],
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return StaggeredFadeIn(
                    index: index,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GlassPanel(
                        glowColor: AppTheme.accentColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.notifications_active,
                              color: AppTheme.accentColor,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    notification.message,
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${notification.brand} ${notification.model} (${notification.year}) • '
                                    '${_priceFormat.format(notification.price)} TL',
                                    style: const TextStyle(color: Colors.white54),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _relativeTime(notification.createdAt),
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(color: Colors.white38),
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
    );
  }
}
