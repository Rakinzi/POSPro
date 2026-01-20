import 'package:flutter/material.dart';
import 'package:mobile_pos/Services/connectivity_service.dart';
import 'package:mobile_pos/Services/sync_service.dart';

/// A widget that displays the current sync status and pending items count
///
/// Usage:
/// ```dart
/// SyncStatusIndicator()
/// ```
///
/// This can be placed in your app bar or anywhere in your UI to show:
/// - Number of items pending sync
/// - Sync in progress indicator
class SyncStatusIndicator extends StatefulWidget {
  const SyncStatusIndicator({super.key});

  @override
  State<SyncStatusIndicator> createState() => _SyncStatusIndicatorState();
}

class _SyncStatusIndicatorState extends State<SyncStatusIndicator> {
  final ConnectivityService _connectivityService = ConnectivityService();
  final SyncService _syncService = SyncService();

  int _pendingCount = 0;

  @override
  void initState() {
    super.initState();
    _loadSyncStatus();

    // Listen to connectivity changes
    _connectivityService.connectivityStream.listen((isConnected) {
      if (mounted) {
        setState(() {
        });
        _loadSyncStatus();
      }
    });
  }

  Future<void> _loadSyncStatus() async {
    final count = await _syncService.getPendingSyncCount();
    if (mounted) {
      setState(() {
        _pendingCount = count;
      });
    }
  }

  Future<void> _manualSync() async {
    // Silently attempt sync without notifying the user
    if (!_connectivityService.isConnected || _pendingCount == 0) {
      return;
    }

    await _syncService.syncAll();
    await _loadSyncStatus();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _manualSync,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.orange,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.sync,
              size: 16,
              color: Colors.orange,
            ),
            if (_pendingCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$_pendingCount',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
