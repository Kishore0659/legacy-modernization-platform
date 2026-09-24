import '../core/constants/app_constants.dart';
import '../models/table_model.dart';
import '../services/firestore_service.dart';

class TableRepository {
  final FirestoreService _service;
  TableRepository(this._service);

  Stream<List<TableModel>> streamTables() {
    return _service
        .streamCollection(AppConstants.tablesCollection)
        .map((snap) =>
        snap.docs.map((d) => TableModel.fromMap(d.data(), d.id)).toList());
  }

  Future<TableModel?> getTable(String tableId) async {
    final doc = await _service
        .collection(AppConstants.tablesCollection)
        .doc(tableId)
        .get();
    if (!doc.exists) return null;
    return TableModel.fromMap(doc.data()!, doc.id);
  }

  Future<void> setStatus(String tableId, String status) {
    return _service.update(
      AppConstants.tablesCollection,
      tableId,
      {'status': status},
    );
  }
}
