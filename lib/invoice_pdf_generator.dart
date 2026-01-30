import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'invoice_model.dart';

class InvoicePdfGenerator {
  /// Generate a PDF invoice from the provided data
  static Future<File> generatePdf(
    InvoiceData invoice, {
    required String outputPath,
    pw.Font? hebrewFont,
  }) async {
    final pdf = pw.Document();

    // Add page
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        textDirection: pw.TextDirection.rtl,
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              // Vertical text on the left margin
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _buildHeader(invoice, hebrewFont),
                  pw.SizedBox(height: 15),
                  _buildInvoiceTitle(invoice, hebrewFont),
                  pw.SizedBox(height: 15),
                  _buildMiddleSection(invoice, hebrewFont),
                  pw.SizedBox(height: 15),
                  _buildItemsTable(invoice, hebrewFont),
                  pw.SizedBox(height: 15),
                  _buildTotals(invoice, hebrewFont),
                  pw.Spacer(),
                  _buildFooter(hebrewFont),
                ],
              ),
            ],
          );
        },
      ),
    );

    // Save PDF
    final file = File(outputPath);
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  /// Build company header
  static pw.Widget _buildHeader(InvoiceData invoice, pw.Font? font) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 1),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
      ),
      child: pw.Center(
        child: pw.Column(
          children: [
            pw.Text(
              invoice.companyName,
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                font: font,
              ),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              invoice.companyAddress,
              style: pw.TextStyle(fontSize: 10, font: font),
            ),
            pw.Text(
              'אשדוד',
              style: pw.TextStyle(fontSize: 10, font: font),
            ),
            pw.Text(
              'טלפונים - ${invoice.companyPhone} פקס - ${invoice.companyFax}',
              style: pw.TextStyle(fontSize: 10, font: font),
            ),
            pw.Text(
              'עוסק מורשה מס. - ${invoice.taxNumber}',
              style: pw.TextStyle(fontSize: 10, font: font),
            ),
          ],
        ),
      ),
    );
  }

  /// Build invoice title section
  static pw.Widget _buildInvoiceTitle(InvoiceData invoice, pw.Font? font) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Center(
          child: pw.Text(
            '${invoice.invoiceType.hebrewName} - ${invoice.invoiceNumber}',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              font: font,
            ),
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Center(
          child: pw.Text(
            invoice.invoiceType.copyLabel,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              font: font,
            ),
          ),
        ),
      ],
    );
  }

  /// Build middle section with two columns
  static pw.Widget _buildMiddleSection(InvoiceData invoice, pw.Font? font) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Right Column (Customer Box) - First in RTL Row
        pw.Expanded(
          flex: 2,
          child: pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.black, width: 1),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  children: [
                    pw.Container(
                      width: 150, // Give enough space for common names
                      child: pw.Row(
                        children: [
                          pw.Text('לכ: ', style: pw.TextStyle(fontSize: 10, font: font)),
                          pw.Text(invoice.customerName, style: pw.TextStyle(fontSize: 10, font: font, fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                    ),
                    pw.SizedBox(width: 10),
                    pw.Row(
                      children: [
                        pw.Text('עבור ', style: pw.TextStyle(fontSize: 10, font: font)),
                        pw.Text(invoice.forCustomer ?? '', style: pw.TextStyle(fontSize: 10, font: font, fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 5),
                pw.Align(
                  alignment: pw.Alignment.topRight,
                  child: pw.Text(
                    invoice.customerAddress,
                    style: pw.TextStyle(fontSize: 10, font: font),
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Row(
                  children: [
                    pw.Expanded(
                      child: _buildMetadataRow(invoice.customerPhone, 'טלפון - ', font, isMetadataColumn: false),
                    ),
                    pw.Expanded(
                      child: _buildMetadataRow('', 'פקס', font, isMetadataColumn: false),
                    ),
                  ],
                ),
                pw.Row(
                  children: [
                    pw.Expanded(
                      child: _buildMetadataRow(invoice.customerTaxNumber ?? '', 'מ.ע/ת.ז', font, isMetadataColumn: false),
                    ),
                    pw.Expanded(
                      child: _buildMetadataRow(invoice.customerPostalCode, 'ח-ן הלקוח: ', font, isMetadataColumn: false),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        pw.SizedBox(width: 40),
        // Left Column (Invoice Metadata) - Second in RTL Row
        pw.Expanded(
          flex: 1,
          child: pw.Padding(
            padding: const pw.EdgeInsets.only(top: 10),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                 _buildMetadataRow(dateFormat.format(invoice.date), 'התאריך', font, isMetadataColumn: true),
                 _buildMetadataRow(invoice.time, 'שעה', font, isMetadataColumn: true),
                 pw.SizedBox(height: 10),
                 _buildMetadataRow(invoice.accountNumber, 'ח-ן מכירות', font, isMetadataColumn: true),
                 _buildMetadataRow(invoice.agentNumber ?? '', 'סוכן', font, isMetadataColumn: true),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildMetadataRow(String value, String label, pw.Font? font, {bool isMetadataColumn = true}) {
    return pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Text(label, style: pw.TextStyle(fontSize: 10, font: font)),
        pw.SizedBox(width: isMetadataColumn ? 10 : 2),
        pw.Text(value, style: pw.TextStyle(fontSize: 10, font: font)),
      ],
    );
  }

  /// Build items table - matches original layout exactly
  static pw.Widget _buildItemsTable(InvoiceData invoice, pw.Font? font) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.black, width: 1),
      columnWidths: {
        0: const pw.FixedColumnWidth(25),  // ##
        1: const pw.FixedColumnWidth(70),  // מס. קטלוגי
        2: const pw.FlexColumnWidth(3),    // תאור
        3: const pw.FixedColumnWidth(45),  // כמות
        4: const pw.FixedColumnWidth(80),  // מחיר יחידה
        5: const pw.FixedColumnWidth(50),  // %הנחה
        6: const pw.FixedColumnWidth(80),  // סה'כ
      },
      children: [
        // Header row
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _buildHeaderCell('##', font),
            _buildHeaderCell('מס. קטלוגי', font),
            _buildHeaderCell('תאור', font),
            _buildHeaderCell('כמות', font),
            _buildHeaderCell('מחיר יחידה', font),
            _buildHeaderCell('%הנחה', font),
            _buildHeaderCell('סה\'כ', font),
          ],
        ),
        // Item rows
        ...invoice.items.map((item) {
          return pw.TableRow(
            children: [
              _buildDataCell(item.itemNumber.toString(), font, align: pw.TextAlign.center),
              _buildDataCell(item.catalogNumber, font, align: pw.TextAlign.center),
              _buildDataCell(item.description, font, align: pw.TextAlign.right),
              _buildDataCell(item.quantity.toString(), font, align: pw.TextAlign.center),
              _buildDataCell(_formatCurrency(item.unitPrice), font, align: pw.TextAlign.right),
              _buildDataCell(item.discount > 0 ? item.discount.toStringAsFixed(0) : '', font, align: pw.TextAlign.center),
              _buildDataCell(_formatCurrency(item.total), font, align: pw.TextAlign.right),
            ],
          );
        }).toList(),
        // Padding rows
        ...List.generate(5, (index) => pw.TableRow(
          children: List.generate(7, (i) => _buildDataCell('', font)),
        )),
      ],
    );
  }

  static pw.Widget _buildHeaderCell(String text, pw.Font? font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 9, font: font, fontWeight: pw.FontWeight.bold),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static pw.Widget _buildDataCell(String text, pw.Font? font, {pw.TextAlign align = pw.TextAlign.left, bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9, 
          font: font, 
          fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: align,
      ),
    );
  }

  static pw.Widget _buildTotals(InvoiceData invoice, pw.Font? font) {
    return pw.Container(
      width: 170, // Matches width from image
      child: pw.Table(
        border: pw.TableBorder.all(color: PdfColors.black, width: 1),
        children: [
          pw.TableRow(
            children: [
              _buildDataCell(_formatCurrency(invoice.subtotal), font, align: pw.TextAlign.right),
              _buildDataCell('סה\'כ חייב מע\'מ', font, align: pw.TextAlign.center),
            ],
          ),
          pw.TableRow(
            children: [
              _buildDataCell(_formatCurrency(invoice.taxAmount), font, align: pw.TextAlign.right),
              _buildDataCell('מע\'מ ${invoice.taxRate.toStringAsFixed(1)}%', font, align: pw.TextAlign.center),
            ],
          ),
          pw.TableRow(
            children: [
              _buildDataCell(_formatCurrency(invoice.total), font, align: pw.TextAlign.right, isBold: true),
              _buildDataCell('סה\'כ לתשלום בש\'ח', font, align: pw.TextAlign.center, isBold: true),
            ],
          ),
        ],
      ),
    );
  }

  /// Build footer
  static pw.Widget _buildFooter(pw.Font? font) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          'ט.ל.ח',
          style: pw.TextStyle(fontSize: 9, font: font),
        ),
        pw.Text(
          'המסמך הופק ע"י :',
          style: pw.TextStyle(fontSize: 9, font: font),
        ),
        pw.Text(
          'חתימה : _____________________________________',
          style: pw.TextStyle(fontSize: 9, font: font),
        ),
      ],
    );
  }

  /// Format currency with thousand separators
  static String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return formatter.format(amount);
  }
}
