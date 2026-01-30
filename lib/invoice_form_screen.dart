import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'invoice_model.dart';
import 'invoice_pdf_generator.dart';

/// A complete form for creating invoices
class InvoiceFormScreen extends StatefulWidget {
  const InvoiceFormScreen({Key? key}) : super(key: key);

  @override
  State<InvoiceFormScreen> createState() => _InvoiceFormScreenState();
}

class _InvoiceFormScreenState extends State<InvoiceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Company controllers
  final _companyNameController = TextEditingController(
    text: 'אלכס גלייזר הנדסה אזרחית בע"מ',
  );
  final _companyAddressController = TextEditingController(
    text: 'הציונות 69/10\nאשדוד',
  );
  final _companyPhoneController = TextEditingController(text: '052-2417376');
  final _companyFaxController = TextEditingController(text: '15322417376');
  final _companyTaxController = TextEditingController(text: '514174721');

  // Customer controllers
  final _customerNameController = TextEditingController();
  final _customerAddressController = TextEditingController();
  final _customerCityController = TextEditingController();
  final _customerPostalController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _customerTaxController = TextEditingController();
  final _forCustomerController = TextEditingController();

  // Invoice controllers
  final _accountNumberController = TextEditingController(text: '6007');
  final _agentNumberController = TextEditingController();

  InvoiceType _selectedType = InvoiceType.priceQuote;
  double _taxRate = 18.0;
  int _invoiceCounter = 1;

  // Line items
  final List<LineItemData> _items = [
    LineItemData(),
  ];

  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _loadCounter();
    _loadCompanyDetails();
  }

  Future<void> _loadCompanyDetails() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _companyNameController.text = prefs.getString('company_name') ?? _companyNameController.text;
      _companyAddressController.text = prefs.getString('company_address') ?? _companyAddressController.text;
      _companyPhoneController.text = prefs.getString('company_phone') ?? _companyPhoneController.text;
      _companyFaxController.text = prefs.getString('company_fax') ?? _companyFaxController.text;
      _companyTaxController.text = prefs.getString('company_tax') ?? _companyTaxController.text;
    });
  }

  Future<void> _saveCompanyDetails() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('company_name', _companyNameController.text);
    await prefs.setString('company_address', _companyAddressController.text);
    await prefs.setString('company_phone', _companyPhoneController.text);
    await prefs.setString('company_fax', _companyFaxController.text);
    await prefs.setString('company_tax', _companyTaxController.text);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('פרטי החברה נשמרו בהצלחה!')),
      );
    }
  }

  Future<void> _loadCounter() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _invoiceCounter = prefs.getInt('invoice_counter') ?? 1;
    });
  }

  Future<void> _incrementCounter() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _invoiceCounter++;
      prefs.setInt('invoice_counter', _invoiceCounter);
    });
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _companyAddressController.dispose();
    _companyPhoneController.dispose();
    _companyFaxController.dispose();
    _companyTaxController.dispose();
    _customerNameController.dispose();
    _customerAddressController.dispose();
    _customerCityController.dispose();
    _customerPostalController.dispose();
    _customerPhoneController.dispose();
    _customerTaxController.dispose();
    _forCustomerController.dispose();
    _accountNumberController.dispose();
    _agentNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('יצירת חשבונית'),
          actions: [
            if (_isGenerating)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              )
            else
              IconButton(
                icon: const Icon(Icons.picture_as_pdf),
                onPressed: _generateInvoice,
                tooltip: 'צור PDF',
              ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSection('פרטי החברה', [
                _buildTextField('שם החברה', _companyNameController),
                _buildTextField('כתובת', _companyAddressController, maxLines: 2),
                _buildTextField('טלפון', _companyPhoneController),
                _buildTextField('פקס', _companyFaxController),
                _buildTextField('מס\' עוסק', _companyTaxController),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton.icon(
                    onPressed: _saveCompanyDetails,
                    icon: const Icon(Icons.save),
                    label: const Text('שמור פרטי חברה'),
                  ),
                ),
              ]),
              const SizedBox(height: 24),
              _buildSection('פרטי הלקוח', [
                _buildTextField('שם הלקוח', _customerNameController),
                _buildTextField('כתובת', _customerAddressController),
                _buildTextField('עיר', _customerCityController),
                _buildTextField('מיקוד', _customerPostalController),
                _buildTextField('טלפון', _customerPhoneController),
                _buildTextField('ח.פ/ת.ז', _customerTaxController),
                _buildTextField('עבור', _forCustomerController),
              ]),
              const SizedBox(height: 24),
              _buildSection('פרטי חשבונית', [
                _buildDropdown(),
                _buildTextField('חשבון מכירות', _accountNumberController),
                _buildTextField('מספר סוכן', _agentNumberController),
                _buildTaxRateField(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'מספר מסמך הבא: $_invoiceCounter',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'תאריך: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
                  ),
                ),
              ]),
              const SizedBox(height: 24),
              _buildItemsSection(),
              const SizedBox(height: 16),
              _buildTotalsSection(),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _addItem,
          child: const Icon(Icons.add),
          tooltip: 'הוסף פריט',
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        maxLines: maxLines,
        keyboardType: keyboardType,
        textDirection: ui.TextDirection.rtl,
      ),
    );
  }

  Widget _buildDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<InvoiceType>(
        value: _selectedType,
        decoration: const InputDecoration(
          labelText: 'סוג מסמך',
          border: OutlineInputBorder(),
        ),
        items: InvoiceType.values.map((type) {
          return DropdownMenuItem(
            value: type,
            child: Text(type.hebrewName),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _selectedType = value;
            });
          }
        },
      ),
    );
  }


  Widget _buildTaxRateField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        initialValue: _taxRate.toString(),
        decoration: const InputDecoration(
          labelText: 'אחוז מע"מ',
          border: OutlineInputBorder(),
          suffixText: '%',
        ),
        keyboardType: TextInputType.number,
        onChanged: (value) {
          setState(() {
            _taxRate = double.tryParse(value) ?? 18.0;
          });
        },
      ),
    );
  }

  Widget _buildItemsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'פריטים',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),
            ..._items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return _buildItemCard(index, item);
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(int index, LineItemData item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'פריט ${index + 1}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (_items.length > 1)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        _items.removeAt(index);
                      });
                    },
                  ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: item.catalogNumber,
              decoration: const InputDecoration(
                labelText: 'מס\' קטלוגי',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => item.catalogNumber = value,
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: item.description,
              decoration: const InputDecoration(
                labelText: 'תיאור',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => item.description = value,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: item.quantity.toString(),
                    decoration: const InputDecoration(
                      labelText: 'כמות',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        item.quantity = int.tryParse(value) ?? 1;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: item.unitPrice.toStringAsFixed(2),
                    decoration: const InputDecoration(
                      labelText: 'מחיר יחידה',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        item.unitPrice = double.tryParse(value) ?? 0;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: item.discount.toStringAsFixed(0),
                    decoration: const InputDecoration(
                      labelText: 'הנחה %',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        item.discount = double.tryParse(value) ?? 0;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'סה"כ: ${_formatCurrency(item.total)}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalsSection() {
    final subtotal = _items.fold(0.0, (sum, item) => sum + item.total);
    final taxAmount = subtotal * (_taxRate / 100);
    final total = subtotal + taxAmount;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTotalRow('סה"כ חייב מע"מ', subtotal),
            _buildTotalRow('מע"מ ${_taxRate.toStringAsFixed(1)}%', taxAmount),
            const Divider(),
            _buildTotalRow('סה"כ לתשלום', total, isBold: true),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalRow(String label, double amount, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            _formatCurrency(amount),
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  void _addItem() {
    setState(() {
      _items.add(LineItemData());
    });
  }

  Future<void> _generateInvoice() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      // Load Hebrew font
      final fontData = await rootBundle.load(
        'assets/fonts/NotoSansHebrew-Regular.ttf',
      );
      final hebrewFont = pw.Font.ttf(fontData);

      // Build invoice data
      final now = DateTime.now();
      final invoice = InvoiceData(
        companyName: _companyNameController.text,
        companyAddress: _companyAddressController.text,
        companyPhone: _companyPhoneController.text,
        companyFax: _companyFaxController.text,
        taxNumber: _companyTaxController.text,
        customerName: _customerNameController.text,
        customerAddress: _customerAddressController.text,
        customerCity: _customerCityController.text,
        customerPostalCode: _customerPostalController.text,
        customerPhone: _customerPhoneController.text,
        customerTaxNumber: _customerTaxController.text.isEmpty
            ? null
            : _customerTaxController.text,
        invoiceNumber: _invoiceCounter.toString(),
        invoiceType: _selectedType,
        date: now,
        time: DateFormat('HH:mm').format(now),
        accountNumber: _accountNumberController.text,
        forCustomer: _forCustomerController.text,
        agentNumber: _agentNumberController.text.isEmpty
            ? null
            : _agentNumberController.text,
        items: _items
            .asMap()
            .entries
            .map((e) => InvoiceLineItem(
                  itemNumber: e.key + 1,
                  catalogNumber: e.value.catalogNumber,
                  description: e.value.description,
                  quantity: e.value.quantity,
                  unitPrice: e.value.unitPrice,
                  discount: e.value.discount,
                ))
            .toList(),
        taxRate: _taxRate,
      );

      // Get output path
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'invoice_${invoice.invoiceNumber}_${DateFormat('yyyyMMdd').format(now)}.pdf';
      final outputPath = '${directory.path}/$fileName';

      // Generate PDF
      final file = await InvoicePdfGenerator.generatePdf(
        invoice,
        outputPath: outputPath,
        hebrewFont: hebrewFont,
      );

      // Increment counter after successful generation
      await _incrementCounter();

      // Share the PDF
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'חשבונית ${invoice.invoiceNumber}',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('החשבונית נוצרה בהצלחה!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('שגיאה: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  String _formatCurrency(double amount) {
    return '₪${amount.toStringAsFixed(2)}';
  }
}

/// Helper class for line item data
class LineItemData {
  String catalogNumber = '';
  String description = '';
  int quantity = 1;
  double unitPrice = 0;
  double discount = 0;

  double get total {
    final subtotal = quantity * unitPrice;
    final discountAmount = subtotal * (discount / 100);
    return subtotal - discountAmount;
  }
}
