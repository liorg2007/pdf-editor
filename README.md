# Hebrew Invoice PDF Generator for Flutter

A complete Flutter solution for generating professional Hebrew invoices as PDF documents, matching the style of your provided templates.

## Features

- ✅ Full RTL (Right-to-Left) Hebrew text support
- ✅ Multiple invoice types (Price Quote, Deal Invoice, Invoice, Receipt)
- ✅ Professional table layout with borders
- ✅ Automatic tax calculations (VAT/מע"מ)
- ✅ Support for discounts and multiple line items
- ✅ Customizable company and customer information
- ✅ Easy-to-use data model
- ✅ Fully programmatic - edit and generate on the fly

## Installation

### 1. Add Dependencies

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  pdf: ^3.10.7
  intl: ^0.18.1
  path_provider: ^2.1.1
  share_plus: ^7.2.1  # Optional: for sharing PDFs
  open_file: ^3.3.2   # Optional: for opening PDFs
```

### 2. Download Hebrew Font

You need a Hebrew font for proper text rendering. I recommend **Noto Sans Hebrew**:

1. Download from [Google Fonts](https://fonts.google.com/noto/specimen/Noto+Sans+Hebrew)
2. Extract the font files
3. Create `assets/fonts/` directory in your Flutter project
4. Copy `NotoSansHebrew-Regular.ttf` and `NotoSansHebrew-Bold.ttf` to this folder

### 3. Update pubspec.yaml

```yaml
flutter:
  assets:
    - assets/fonts/
    
  fonts:
    - family: Hebrew
      fonts:
        - asset: assets/fonts/NotoSansHebrew-Regular.ttf
        - asset: assets/fonts/NotoSansHebrew-Bold.ttf
          weight: 700
```

### 4. Add the Files

Copy these files to your Flutter project:

- `invoice_model.dart` - Data models
- `invoice_pdf_generator.dart` - PDF generation logic
- `invoice_example_usage.dart` - Usage examples

## Quick Start

### Basic Example

```dart
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;

// Load Hebrew font
final fontData = await rootBundle.load('assets/fonts/NotoSansHebrew-Regular.ttf');
final hebrewFont = pw.Font.ttf(fontData);

// Create invoice data
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
  date: DateTime.now(),
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

// Generate PDF
final file = await InvoicePdfGenerator.generatePdf(
  invoice,
  outputPath: '/path/to/output/invoice.pdf',
  hebrewFont: hebrewFont,
);

print('PDF generated: ${file.path}');
```

### Multiple Items Example

```dart
final invoice = InvoiceData(
  // ... company and customer details ...
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
  ],
);
```

## Invoice Types

The system supports four invoice types:

```dart
enum InvoiceType {
  priceQuote,    // הצעת מחיר
  dealInvoice,   // חשבון עיסקה
  invoice,       // חשבונית
  receipt,       // קבלה
}
```

## Data Model

### InvoiceData

Main invoice container with all information:

- Company details (name, address, phone, fax, tax number)
- Customer details (name, address, phone, tax number)
- Invoice metadata (number, type, date, time)
- Line items
- Tax rate

### InvoiceLineItem

Individual items in the invoice:

- Item number
- Catalog number
- Description
- Quantity
- Unit price
- Discount percentage

## Automatic Calculations

The system automatically calculates:

- **Line item totals**: `(quantity × unitPrice) - discount`
- **Subtotal**: Sum of all line items
- **Tax amount**: `subtotal × (taxRate / 100)`
- **Total**: `subtotal + taxAmount`

## Complete App Integration Example

```dart
class InvoiceScreen extends StatefulWidget {
  @override
  _InvoiceScreenState createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  Future<void> _generateAndShareInvoice() async {
    try {
      // Load font
      final fontData = await rootBundle.load(
        'assets/fonts/NotoSansHebrew-Regular.ttf'
      );
      final hebrewFont = pw.Font.ttf(fontData);

      // Create invoice (from your form data)
      final invoice = _buildInvoiceFromForm();

      // Generate PDF in app's documents directory
      final directory = await getApplicationDocumentsDirectory();
      final outputPath = '${directory.path}/invoice_${invoice.invoiceNumber}.pdf';

      final file = await InvoicePdfGenerator.generatePdf(
        invoice,
        outputPath: outputPath,
        hebrewFont: hebrewFont,
      );

      // Share or open the PDF
      await Share.shareXFiles([XFile(file.path)]);
      // Or: await OpenFile.open(file.path);

    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  InvoiceData _buildInvoiceFromForm() {
    // Build from your form controllers/state
    return InvoiceData(
      // ... fill in with form data ...
    );
  }
}
```

## Customization

### Changing Layout

Edit `invoice_pdf_generator.dart` to modify:

- Table structure in `_buildItemsTable()`
- Header design in `_buildHeader()`
- Font sizes and styles
- Spacing and padding
- Border styles

### Adding Fields

1. Add field to `InvoiceData` class in `invoice_model.dart`
2. Update the generator in `invoice_pdf_generator.dart` to display it
3. Update your UI to collect the data

### Changing Tax Rate

```dart
final invoice = InvoiceData(
  // ...
  taxRate: 17.0, // Change from default 18.0%
);
```

## File Structure

```
lib/
├── models/
│   └── invoice_model.dart          # Data models
├── services/
│   └── invoice_pdf_generator.dart  # PDF generation logic
├── screens/
│   └── invoice_screen.dart         # UI for creating invoices
└── main.dart

assets/
└── fonts/
    ├── NotoSansHebrew-Regular.ttf
    └── NotoSansHebrew-Bold.ttf
```

## Important Notes

### Hebrew Font Requirement

Hebrew text **requires** a proper Hebrew font. Without it, the text will appear as empty boxes. Make sure to:

1. Include the font files in your assets
2. Load the font before generating PDFs
3. Pass the font to the generator

### RTL Support

The PDF is automatically configured for Right-to-Left text direction. All text alignment and layout flows from right to left.

### Number Formatting

Numbers are formatted with thousand separators (e.g., 5,000.00) for better readability.

## Testing

Use the provided example factory methods:

```dart
// Test with pre-filled data
final invoice = InvoiceData.example();
final dealInvoice = InvoiceData.dealExample();
```

## Troubleshooting

### Font not displaying

- Verify font files are in `assets/fonts/`
- Check `pubspec.yaml` fonts configuration
- Run `flutter clean` and rebuild

### PDF not generating

- Check file write permissions
- Verify output path exists
- Ensure font is loaded successfully

### Layout issues

- Adjust column widths in `_buildItemsTable()`
- Modify spacing in individual widgets
- Check page margins in `pw.Page`

## License

This is a template for your use. Modify as needed for your application.

## Support

For issues or questions:
1. Check the example usage file
2. Review the inline documentation
3. Test with the example factory methods

## Future Enhancements

Potential additions:
- [ ] Logo support
- [ ] Multiple currencies
- [ ] Email integration
- [ ] Barcode/QR code support
- [ ] Custom themes/templates
- [ ] Digital signatures
- [ ] Multi-page invoices
