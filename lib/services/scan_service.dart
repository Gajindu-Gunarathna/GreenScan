import '../models/scan_model.dart';

class ScanService {
  Future<ScanModel> scanLeaf({
    required String imagePath,
    required String userId,
    required String district,
    double? latitude,
    double? longitude,
  }) async {
    // TODO: implement FastAPI call
    throw UnimplementedError('ScanService.scanLeaf not implemented yet');
  }
}
