import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import '../presentation/widgets/receipt_image_widget.dart';
import 'store_settings_service.dart';
import '../../transaction/data/transaction_service.dart';

class ReceiptImageService {
  static Future<void> shareAsImage({
    required TransactionResult transaction,
    StoreSettings? storeSettings,
  }) async {
    final controller = ScreenshotController();

    final Uint8List imageBytes = await controller.captureFromWidget(
      MediaQuery(
        data: const MediaQueryData(),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: ReceiptImageWidget(transaction: transaction, storeSettings: storeSettings),
        ),
      ),
      pixelRatio: 2.5,
    );

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/struk_${transaction.invoiceNumber}.png');
    await file.writeAsBytes(imageBytes);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text: 'Struk ${transaction.invoiceNumber}',
      ),
    );
  }
}