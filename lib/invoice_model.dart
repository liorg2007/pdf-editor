/// Invoice data model
class InvoiceData {
  // Company details
  final String companyName;
  final String companyAddress;
  final String companyPhone;
  final String companyFax;
  final String taxNumber;

  // Customer details
  final String customerName;
  final String customerAddress;
  final String customerCity;
  final String customerPostalCode;
  final String customerPhone;
  final String? customerTaxNumber;

  // Invoice details
  final String invoiceNumber;
  final InvoiceType invoiceType;
  final DateTime date;
  final String time;
  final String accountNumber;
  final String? agentNumber;
  final String? forCustomer; // עבור field

  // Line items
  final List<InvoiceLineItem> items;

  // Tax settings
  final double taxRate; // e.g., 18.0 for 18%

  InvoiceData({
    required this.companyName,
    required this.companyAddress,
    required this.companyPhone,
    required this.companyFax,
    required this.taxNumber,
    required this.customerName,
    required this.customerAddress,
    required this.customerCity,
    required this.customerPostalCode,
    required this.customerPhone,
    this.customerTaxNumber,
    required this.invoiceNumber,
    required this.invoiceType,
    required this.date,
    required this.time,
    required this.accountNumber,
    this.agentNumber,
    this.forCustomer,
    required this.items,
    this.taxRate = 18.0,
  });

  // Calculate totals
  double get subtotal {
    return items.fold(0.0, (sum, item) => sum + item.total);
  }

  double get taxAmount {
    return subtotal * (taxRate / 100);
  }

  double get total {
    return subtotal + taxAmount;
  }

  // Factory constructor for easy testing
  factory InvoiceData.example() {
    return InvoiceData(
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
  }

  factory InvoiceData.dealExample() {
    return InvoiceData(
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
      date: DateTime.now(),
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
  }
}

/// Line item in an invoice
class InvoiceLineItem {
  final int itemNumber;
  final String catalogNumber;
  final String description;
  final int quantity;
  final double unitPrice;
  final double discount; // percentage

  InvoiceLineItem({
    required this.itemNumber,
    required this.catalogNumber,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.discount,
  });

  double get total {
    final subtotal = quantity * unitPrice;
    final discountAmount = subtotal * (discount / 100);
    return subtotal - discountAmount;
  }
}

/// Invoice type enum
enum InvoiceType {
  priceQuote,    // הצעת מחיר
  dealInvoice,   // חשבון עיסקה
}

extension InvoiceTypeExtension on InvoiceType {
  String get hebrewName {
    switch (this) {
      case InvoiceType.priceQuote:
        return 'הצעת מחיר מספר';
      case InvoiceType.dealInvoice:
        return 'חשבון עיסקה מספר';
    }
  }

  String get copyLabel {
    switch (this) {
      case InvoiceType.priceQuote:
        return '****מקור****';
      case InvoiceType.dealInvoice:
        return '****העתק 1****';
    }
  }
}
