import 'package:flutter/material.dart';
import '../models/scan_model.dart';
import '../services/scan_service.dart';
import '../services/local_storage_service.dart';
import '../utils/app_constants.dart';

enum ScanState { idle, loading, success, error }

class ScanProvider extends ChangeNotifier {
  final ScanService _scanService = ScanService();

  ScanState _state = ScanState.idle;
  ScanModel? _currentScan;
  List<ScanModel> _scanHistory = [];
  String _errorMessage = '';

  ScanState get state => _state;
  ScanModel? get currentScan => _currentScan;
  List<ScanModel> get scanHistory => _scanHistory;
  String get errorMessage => _errorMessage;

  // Called when user captures/picks an image
  Future<void> scanLeaf({
    required String imagePath,
    required String userId,
    required String district,
    double? latitude,
    double? longitude,
    required bool isOnline,
  }) async {
    _state = ScanState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      if (!isOnline) {
        // Save locally, mark as unsynced
        _errorMessage = 'No internet. Scan saved — will sync when online.';
        _state = ScanState.error;
        notifyListeners();
        return;
      }

      final scan = await _scanService.scanLeaf(
        imagePath: imagePath,
        userId: userId,
        district: district,
        latitude: latitude,
        longitude: longitude,
      );

      _currentScan = scan;

      // Cache locally
      LocalStorageService.save(AppConstants.scansBox, scan.id, scan.toMap());

      _scanHistory.insert(0, scan);
      _state = ScanState.success;
    } catch (e) {
      _errorMessage = 'Scan failed: ${e.toString()}';
      _state = ScanState.error;
    }

    notifyListeners();
  }

  // Load history from local cache
  void loadScanHistory() {
    final raw = LocalStorageService.getAll(AppConstants.scansBox);
    _scanHistory = raw.map((e) => ScanModel.fromMap(e)).toList();
    _scanHistory.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    notifyListeners();
  }

  void clearCurrentScan() {
    _currentScan = null;
    _state = ScanState.idle;
    notifyListeners();
  }
}
