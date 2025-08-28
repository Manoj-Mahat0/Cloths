import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'dashboard/admin_dashboard.dart';
import 'dashboard/user_dashboard.dart';
import 'dashboard/warehouse_dashboard.dart';

class PostLoginRouter extends StatelessWidget {
  const PostLoginRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: AuthService().fetchCurrentUserAndPersist(),
      builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>?> snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        // Prefer API role if available; otherwise fallback to cached role
        final String apiRole = (snapshot.hasData && snapshot.data != null && snapshot.data!['role'] is String)
            ? (snapshot.data!['role'] as String)
            : '';
        return FutureBuilder<String?>(
          future: AuthService.getStoredRole(),
          builder: (BuildContext context, AsyncSnapshot<String?> stored) {
            final String cachedRole = (stored.data ?? '').toLowerCase();
            final String effectiveRole = (apiRole.isNotEmpty ? apiRole : cachedRole).toLowerCase();
            switch (effectiveRole) {
              case 'admin':
                return const AdminDashboard();
              case 'warehouse':
                return const WarehouseDashboard();
              case 'user':
              default:
                return const UserDashboard();
            }
          },
        );
      },
    );
  }
}


