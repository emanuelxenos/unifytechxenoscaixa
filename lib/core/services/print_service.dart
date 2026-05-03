import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final printServiceProvider = Provider((ref) => PrintService());

class PrintService {
  Future<bool> printReceipt(String? text) async {
    if (text == null || text.isEmpty) return false;

    try {
      final doc = pw.Document();
      
      // Usamos RobotoMono para garantir que as colunas fiquem alinhadas
      final font = await PdfGoogleFonts.robotoMonoRegular();

      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.roll80,
          margin: const pw.EdgeInsets.all(10),
          build: (pw.Context context) {
            return pw.Text(
              text,
              style: pw.TextStyle(
                font: font,
                fontSize: 8,
                lineSpacing: 1,
              ),
            );
          },
        ),
      );

      // Busca a lista de impressoras e tenta encontrar a padrão
      final printers = await Printing.listPrinters();
      if (printers.isEmpty) {
        debugPrint('Nenhuma impressora encontrada');
        return false;
      }

      // Tenta pegar a padrão, se não tiver, pega a primeira da lista
      final printer = printers.firstWhere((p) => p.isDefault, orElse: () => printers.first);

      // Envia para a impressora encontrada
      await Printing.directPrintPdf(
        printer: printer,
        onLayout: (PdfPageFormat format) => doc.save(),
        name: 'Cupom de Venda',
      );
      
      return true;
    } catch (e) {
      debugPrint('Erro ao imprimir: $e');
      return false;
    }
  }

  /// Abre o diálogo de impressão caso o usuário queira escolher a impressora
  Future<void> showPrintDialog(String text) async {
    final doc = pw.Document();
    final font = await PdfGoogleFonts.robotoMonoRegular();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        margin: const pw.EdgeInsets.all(10),
        build: (pw.Context context) {
          return pw.Text(
            text,
            style: pw.TextStyle(
              font: font,
              fontSize: 8,
              lineSpacing: 1,
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) => doc.save(),
      name: 'Cupom de Venda',
    );
  }
}
