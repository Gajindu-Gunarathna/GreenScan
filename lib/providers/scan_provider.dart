import 'package:flutter/material.dart';
import '../models/scan_model.dart';
import '../services/scan_service.dart';
import '../services/local_storage_service.dart';
import '../utils/app_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/map_service.dart';

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
        _errorMessage = 'No internet. Connect to scan.';
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

      // Save to local cache
      LocalStorageService.save(
        AppConstants.scansBox,
        '${scan.userId}_${scan.id}',
        scan.toMap(),
      );

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('scans')
          .doc(scan.id)
          .set(scan.copyWith(isSynced: true).toMap());

      // Update district stats
      await MapService().updateDistrictCount(
        district: district,
        diseaseName: scan.diseaseName,
      );

      _scanHistory.insert(0, scan);
      _state = ScanState.success;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _state = ScanState.error;
    }

    notifyListeners();
  }

  // Load history from local cache
  void loadScanHistory(String userId) {
    final raw = LocalStorageService.getAll(AppConstants.scansBox);
    _scanHistory = raw
        .map((e) => ScanModel.fromMap(e))
        .where((scan) => scan.userId == userId)
        .toList();
    _scanHistory.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    notifyListeners();
  }

  void clearCurrentScan() {
    _currentScan = null;
    _state = ScanState.idle;
    notifyListeners();
  }
}
