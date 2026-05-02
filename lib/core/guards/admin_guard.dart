import 'package:flutter/material.dart';
import 'package:market_world/core/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class AdminGuard extends StatelessWidget {
  const AdminGuard({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: context.read<AuthProvider>().isAdmin(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.data!) {
          return const Scaffold(
            body: Center(
              child: Text('Access denied'),
            ),
          );
        }

        return child;
      },
    );
  }
}
