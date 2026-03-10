import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../models/dashboard_stats_model.dart';

final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final client = ref.read(apiClientProvider);
  final res    = await client.get(ApiEndpoints.dashboardStats);
  return DashboardStats.fromJson(
    res.data['stats'] as Map<String, dynamic>,
  );
});
