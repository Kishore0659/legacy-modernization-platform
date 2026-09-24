/// Represents a physical restaurant table identified via QR code.
class TableModel {
  final String tableId; // e.g. "1", "2", "3", "4"
  final String qrCode;  // e.g. "restaurant://menu?table=1"
  final String status;  // "available" | "occupied" | "reserved"

  const TableModel({
    required this.tableId,
    required this.qrCode,
    required this.status,
  });

  factory TableModel.fromMap(Map<String, dynamic> map, String id) {
    return TableModel(
      tableId: id,
      qrCode: map['qrCode'] ?? 'restaurant://menu?table=$id',
      status: map['status'] ?? 'available',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'qrCode': qrCode,
      'status': status,
    };
  }
}
