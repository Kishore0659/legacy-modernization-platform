import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../../services/qr_service.dart';

/// Generates a printable QR code for each table. Each code encodes a deep
/// link (restaurant://menu?table=N) that the customer's phone camera or
/// the in-app scanner resolves to open the menu directly for that table.
class QrGeneratorScreen extends StatelessWidget {
  const QrGeneratorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Table QR Codes')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        itemCount: AppConstants.totalTables,
        itemBuilder: (context, index) {
          final tableId = '${index + 1}';
          final link = QrService.buildLink(tableId);
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  QrImageView(
                    data: link,
                    version: QrVersions.auto,
                    size: 140,
                    gapless: false,
                  ),
                  const SizedBox(height: 12),
                  Text('Table $tableId',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(
                    link,
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
