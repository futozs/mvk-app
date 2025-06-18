import 'package:flutter/material.dart';
import '../services/app_cache_service.dart';

/// Debug widget a cache állapotának megjelenítéséhez
/// A fejlesztők számára hasznos a cache működésének ellenőrzésére
class CacheDebugWidget extends StatefulWidget {
  const CacheDebugWidget({super.key});

  @override
  State<CacheDebugWidget> createState() => _CacheDebugWidgetState();
}

class _CacheDebugWidgetState extends State<CacheDebugWidget> {
  final AppCacheService _cacheService = AppCacheService();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.cached, color: Colors.green, size: 16),
              const SizedBox(width: 4),
              const Text(
                'Cache Debug',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white, size: 16),
                onPressed: () => setState(() {}),
                tooltip: 'Refresh',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 4),
          _buildStatusRow('Initialized', _cacheService.isInitialized),
          _buildStatusRow('Preloading', _cacheService.isPreloading),
          _buildStatusRow('Preload Complete', _cacheService.isPreloadCompleted),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    await _cacheService.clearCache();
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cache cleared!')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                  ),
                  child: const Text(
                    'Clear Cache',
                    style: TextStyle(fontSize: 10, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    await _cacheService.resetForNewUser();
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Reset for new user!')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                  ),
                  child: const Text(
                    'Reset App',
                    style: TextStyle(fontSize: 10, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, bool status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: status ? Colors.green : Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
