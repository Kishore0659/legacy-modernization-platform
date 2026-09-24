import 'package:flutter/material.dart';
import '../../models/table_model.dart';
import '../../repositories/table_repository.dart';
import '../../services/firestore_service.dart';
import '../../core/widgets/loading_indicator.dart';

/// Admin screen to view & update table status (available/occupied/reserved).
class ManageTablesScreen extends StatelessWidget {
  const ManageTablesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = TableRepository(FirestoreService());
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Tables')),
      body: StreamBuilder<List<TableModel>>(
        stream: repo.streamTables(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const LoadingIndicator();
          final tables = snapshot.data!;
          return ListView.builder(
            itemCount: tables.length,
            itemBuilder: (context, i) {
              final table = tables[i];
              return ListTile(
                leading: const Icon(Icons.table_bar),
                title: Text('Table ${table.tableId}'),
                subtitle: Text(table.qrCode),
                trailing: DropdownButton<String>(
                  value: table.status,
                  items: const [
                    DropdownMenuItem(value: 'available', child: Text('Available')),
                    DropdownMenuItem(value: 'occupied', child: Text('Occupied')),
                    DropdownMenuItem(value: 'reserved', child: Text('Reserved')),
                  ],
                  onChanged: (v) {
                    if (v != null) repo.setStatus(table.tableId, v);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
