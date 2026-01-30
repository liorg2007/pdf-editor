import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'invoice_model.dart';
import 'invoice_pdf_generator.dart';

/// Example usage of the invoice PDF generator
class InvoiceExample {
  /// Generate a sample price quote (הצעת מחיר)
  static Future<File> generatePriceQuote() async {
    // Load Hebrew font (you need to add this to your assets)
    final hebrewFont = await _loadHebrewFont();

    final invoice = InvoiceData(
      companyName: 'אלכס גלייזר הנדסה אזרחית בע"מ',
      companyAddress: 'הציונות 69/10\nאשדוד',
      companyPhone: '052-2417376',
      companyFax: '15322417376',
      taxNumber: '514174721',
      customerName: 'משה אביטל',
      customerAddress: 'הרצליה',
      customerCity: '',
      customerPostalCode: '21466',
      customerPhone: '050-5270190',
      invoiceNumber: '43',
      invoiceType: InvoiceType.priceQuote,
      date: DateTime(2026, 1, 30),
      time: '12:23',
      accountNumber: '6007',
      items: [
        InvoiceLineItem(
          itemNumber: 1,
          catalogNumber: '',
          description: 'שירות מהנדס',
          quantity: 1,
          unitPrice: 5000.00,
          discount: 0,
        ),
      ],
      taxRate: 18.0,
    );

    return InvoicePdfGenerator.generatePdf(
      invoice,
      outputPath: '/tmp/price_quote_43.pdf',
      hebrewFont: hebrewFont,
    );
  }

  /// Generate a sample deal invoice (חשבון עיסקה)
  static Future<File> generateDealInvoice() async {
    final hebrewFont = await _loadHebrewFont();

    final invoice = InvoiceData(
      companyName: 'אלכס גלייזר הנדסה אזרחית בע"מ',
      companyAddress: 'הציונות 69/10\nאשדוד',
      companyPhone: '052-2417376',
      companyFax: '15322417376',
      taxNumber: '514174721',
      customerName: 'רחמני ד. עבודות עפר בע"מ',
      customerAddress: 'אלמוג',
      customerCity: 'עפולה',
      customerPostalCode: 'מנחם בגין',
      customerPhone: '04-6427223',
      customerTaxNumber: '514109800',
      invoiceNumber: '16',
      invoiceType: InvoiceType.dealInvoice,
      date: DateTime(2026, 1, 30),
      time: '12:21',
      accountNumber: '6007',
      agentNumber: '11',
      forCustomer: '',
      items: [
        InvoiceLineItem(
          itemNumber: 1,
          catalogNumber: '',
          description: 'שירות הנדסי',
          quantity: 1,
          unitPrice: 5000.00,
          discount: 0,
        ),
      ],
      taxRate: 18.0,
    );

    return InvoicePdfGenerator.generatePdf(
      invoice,
      outputPath: '/tmp/deal_invoice_16.pdf',
      hebrewFont: hebrewFont,
    );
  }

  /// Generate a more complex invoice with multiple items
  static Future<File> generateComplexInvoice() async {
    final hebrewFont = await _loadHebrewFont();

    final invoice = InvoiceData(
      companyName: 'אלכס גלייזר הנדסה אזרחית בע"מ',
      companyAddress: 'הציונות 69/10\nאשדוד',
      companyPhone: '052-2417376',
      companyFax: '15322417376',
      taxNumber: '514174721',
      customerName: 'חברת דוגמא בע"מ',
      customerAddress: 'רחוב ראשי 123',
      customerCity: 'תל אביב',
      customerPostalCode: '12345',
      customerPhone: '03-1234567',
      customerTaxNumber: '123456789',
      invoiceNumber: '100',
      invoiceType: InvoiceType.invoice,
      date: DateTime.now(),
      time: TimeOfDay.now().format(context), // You'll need to pass context
      accountNumber: '6007',
      items: [
        InvoiceLineItem(
          itemNumber: 1,
          catalogNumber: 'ENG-001',
          description: 'ייעוץ הנדסי - שעה',
          quantity: 10,
          unitPrice: 500.00,
          discount: 10, // 10% discount
        ),
        InvoiceLineItem(
          itemNumber: 2,
          catalogNumber: 'ENG-002',
          description: 'בדיקת תוכניות',
          quantity: 1,
          unitPrice: 2500.00,
          discount: 0,
        ),
        InvoiceLineItem(
          itemNumber: 3,
          catalogNumber: 'ENG-003',
          description: 'דוח מסכם',
          quantity: 1,
          unitPrice: 1500.00,
          discount: 5,
        ),
      ],
      taxRate: 18.0,
    );

    return InvoicePdfGenerator.generatePdf(
      invoice,
      outputPath: '/tmp/complex_invoice_100.pdf',
      hebrewFont: hebrewFont,
    );
  }

  /// Load Hebrew font from assets
  /// You need to add a Hebrew font file to your pubspec.yaml:
  /// 
  /// flutter:
  ///   assets:
  ///     - assets/fonts/
  ///   fonts:
  ///     - family: Hebrew
  ///       fonts:
  ///         - asset: assets/fonts/NotoSansHebrew-Regular.ttf
  ///         - asset: assets/fonts/NotoSansHebrew-Bold.ttf
  ///           weight: 700
  static Future<pw.Font> _loadHebrewFont() async {
    // Load from assets
    final fontData = await rootBundle.load('assets/fonts/NotoSansHebrew-Regular.ttf');
    return pw.Font.ttf(fontData);
  }

  /// Alternative: Load Hebrew font from file system (for testing)
  static Future<pw.Font?> _loadHebrewFontFromFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        return pw.Font.ttf(bytes.buffer.asByteData());
      }
    } catch (e) {
      print('Error loading font: $e');
    }
    return null;
  }
}

/// Widget example showing how to integrate in a Flutter app
class InvoiceGeneratorWidget extends StatefulWidget {
  @override
  _InvoiceGeneratorWidgetState createState() => _InvoiceGeneratorWidgetState();
}

class _InvoiceGeneratorWidgetState extends State<InvoiceGeneratorWidget> {
  bool _isGenerating = false;
  String? _generatedFilePath;

  Future<void> _generateInvoice() async {
    setState(() {
      _isGenerating = true;
      _generatedFilePath = null;
    });

    try {
      // Create invoice data from your form/UI
      final invoice = InvoiceData.example(); // Or build from user input

      // Load Hebrew font
      final fontData = await rootBundle.load('assets/fonts/NotoSansHebrew-Regular.ttf');
      final hebrewFont = pw.Font.ttf(fontData);

      // Generate PDF
      final file = await InvoicePdfGenerator.generatePdf(
        invoice,
        outputPath: '/tmp/invoice_${invoice.invoiceNumber}.pdf',
        hebrewFont: hebrewFont,
      );

      setState(() {
        _generatedFilePath = file.path;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF נוצר בהצלחה!')),
      );
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('שגיאה ביצירת PDF: $e')),
      );
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('מחולל חשבוניות'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isGenerating)
              CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: _generateInvoice,
                child: Text('צור חשבונית'),
              ),
            if (_generatedFilePath != null) ...[
              SizedBox(height: 20),
              Text('הקובץ נוצר בהצלחה:'),
              Text(_generatedFilePath!),
            ],
          ],
        ),
      ),
    );
  }
}
