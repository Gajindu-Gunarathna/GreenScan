import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/treatment_model.dart';

class TreatmentService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<TreatmentModel?> getTreatment(String diseaseId) async {
    final doc = await _db.collection('treatments').doc(diseaseId).get();

    if (!doc.exists) return null;
    return TreatmentModel.fromMap(doc.data()!);
  }
}
