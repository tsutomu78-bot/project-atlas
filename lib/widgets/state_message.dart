import 'package:flutter/material.dart';
import '../models/result.dart';

/// Centered icon + message, used for empty/error/sign-in states across the
/// user-data screens. Every Result case maps to a specific honest message
/// (Engineering Value #1: truth over completeness) — never a blank screen.
class StateMessage extends StatelessWidget {
  final IconData icon;
  final String message;
  const StateMessage({super.key, required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

String resultMessage(Result<Object?> result) {
  return switch (result) {
    Offline() => 'Offline · Showing nothing rather than guessing',
    PermissionDenied() => 'Sign in to see this.',
    NotFound() => 'Nothing found.',
    ConnectorUnavailable() => 'This source is unavailable right now.',
    Failure(message: final m) => m,
    Success() => '',
  };
}

String formatAgo(DateTime t) {
  final d = DateTime.now().difference(t);
  if (d.inMinutes < 1) return 'just now';
  if (d.inMinutes < 60) return '${d.inMinutes} min ago';
  if (d.inHours < 24) return '${d.inHours} hr ago';
  return '${d.inDays} day(s) ago';
}
